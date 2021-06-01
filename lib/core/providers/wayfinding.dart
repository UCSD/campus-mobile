import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/wayfinding_constants.dart';
import 'package:campus_mobile_experimental/core/providers/location.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/wayfinding.dart';
import 'package:campus_mobile_experimental/core/utils/maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bluetooth.dart';

enum ScannedDevice {
  SCANNED_DEVICE_ID,
  SCANNED_DEVICE_TYPE,
  SCANNED_DEVICE_ADVERTISEMENT_ID,
  SCANNED_DEVICE_DETECT_START,
  SCANNED_DEVICE_DETECT_SIGNAL_STRENGTH,
  SCANNED_DEVICE_DETECT_DISTANCE
}

/// A file that handles AdvancedWayfinding feature to scan and identify nearby BT devices.
class WayfindingProvider extends ChangeNotifier {
  /// A structured model to simplify constants management and UCSD-ITS configurations.
  late WayfindingConstantsModel _wayfindingConstantsModel;

  /// A service for fetching UCSD-ITS configurations from network.
  late WayfindingService _wayfindingService;

  /// Responsible for managing the broadcasting of [advertisementValue].
  late BeaconSingleton beaconSingleton;

  /// Distinguishes running in the background vs having app open.
  bool inBackground = false;

  /// Advertisement string
  String? advertisementValue;

  /// Operating system of device
  String? operatingSystem;

  /// Confirms that this is the first instance of the Wayfinding feature, preventing parallel scanning.
  bool firstInstance = true;

  bool advancedWayfindingEnabled = false;

  /// Access previous bt setting/permissions
  late SharedPreferences sharedPreferences;

  /// Ensures AdvancedWayfinding is disabled when location & BT are unavailable.
  bool forceOff = false;

  /// Provides location of device for logging scans.
  Coordinates? _coordinates;

  /// Not directly accessed but used to check permissions
  LocationDataProvider? _locationDataProvider;

  /// Keeps track of scanned unique BT devices.
  HashMap<String, BluetoothDeviceProfile> scannedObjects = new HashMap();

  /// Instance of FlutterBlue library to handle raw BT processing.
  FlutterBlue flutterBlueInstance = FlutterBlue.instance;

  /// Stores data from background scans to preserve scan continuation.
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Holds header for mobile logger POST.
  Map<String, String>? loggerHeader;

  /// Holds header for user token retrieval.
  final Map<String, String> tokenHeader = {
    "accept": "application/json",
  };

  /// Provides specialized support for requests to WSO2 APIs.
  final NetworkHelper _networkHelper = NetworkHelper();

  /// Endpoint used to send device logs to ITS specified destination.
  String mobileLoggerEndpoint =
      "https://api-qa.ucsd.edu:8243/mobileapplogger/v1.1.0/log?type=WAYFINDING";

  //Thresholds for logging location
  int qualifiedDevicesThreshold = 0;
  int distanceThreshold = 10; // default in ZenHub
  int scanIntervalAllowance = 0;
  int? backgroundScanInterval = 15; // Minutes
  int? deletionInterval = 30; // Minutes
  double milesFromPriceCenter = 5;
  int dwellTimeThreshold = 200; // In seconds (10 minutes -> 600 seconds)

  /// Keep track of devices that meet our requirements
  int qualifyingDevices = 0;

  /// Default constant for scans
  int scanDuration = 2; //Seconds
  int waitTime = 15; // Minutes
  int dwellMinutes = 30;

  /// Coordinates for Price Center
  final double pcLongitude = -117.237006;
  final double pcLatitude = 32.880006;
  late double distanceFromPriceCenter;

  /// Allows for continuous scan
  Timer? ongoingScanner;

  /// Displays BT devices that have been scanned (only for debugger view).
  List loggedItems = [];

  /// Gives an unfiltered list of scanned devices.
  static List<List<Object>> unprocessedDevices = [];
  List<Map> displayingDevices = [];
  var btStream;

  /// Device types list for local caching
  Map<String, dynamic>? deviceTypes = {};
  // initialize location and permissions to be checked
  double? userLatitude;
  double? userLongitude;

  /// Access user's profile to offload data
  UserDataProvider? userDataProvider;

  /// Provides sole instance of AdvancedWayfinding feature.
  static final WayfindingProvider _bluetoothSingleton =
      WayfindingProvider._internal();

  /// Constructor for AdvancedWayfinding feature and prevents multiple instances.
  factory WayfindingProvider() {
    return _bluetoothSingleton;
  }

  /// Runs if AdvancedWayfinding was turned on.
  void init() async {
    btStream = Stream<List<Map>>.periodic(
        Duration(seconds: 1), (x) => displayingDevices);
    checkAdvancedWayfindingEnabled();
    userLongitude = (_coordinates == null) ? null : _coordinates!.lon;
    userLatitude = (_coordinates == null) ? null : _coordinates!.lat;


    // Verify that BT module is present in this device.
    await flutterBlueInstance.isAvailable.then((value) {
      flutterBlueInstance.state.listen((event) async {
        // Verify BT is available to start scanning.
        if (event.index == 4) {
          notifyListeners();
          // Set Wayfinding preferences
          advancedWayfindingEnabled = true;
          sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setBool("advancedWayfindingEnabled", true);

          // Fetch UCSD_ITS scanning configurations.
          _wayfindingService = WayfindingService();
          await _wayfindingService.fetchData();
          _wayfindingConstantsModel =
              _wayfindingService.wayfindingConstantsModel!;

          // Set up broadcasting for UCSD App Identification
          startBeaconBroadcast();

          // Set the minimum change to activate a new scan.
          //location.changeSettings(accuracy: LocationAccuracy.low);

          // Enable location listening
          checkLocationPermission();

          // Enable continuous scan
          enableScanning();
        }
      });
    });
  }

  /// Enables periodic scanning based on [_wayfindingConstantsModel.scanWaitTime].
  enableScanning() {
    // Start the initial scan
    startScan();

    // Enable timer and  wait duration before starting next scan.
    ongoingScanner = new Timer.periodic(
        Duration(minutes: _wayfindingConstantsModel.scanWaitTime!),
        (Timer t) => startScan());
  }

  /// Scans for BT LE devices and processes them to send to ITS specified destination.
  ///
  /// Short circuits when not within ITS defined distance of UCSD.
  startScan() async {
    //Ensure that we are still within X miles of Price Center
    if (userLongitude != null && userLatitude != null) {
      _wayfindingConstantsModel.userDistanceFromPriceCenter =
          getHaversineDistance(
              _wayfindingConstantsModel.pcLatitude,
              _wayfindingConstantsModel.pcLongitude,
              userLatitude,
              userLongitude);

      // Convert km to miles
      _wayfindingConstantsModel.userDistanceFromPriceCenter =
          _wayfindingConstantsModel.userDistanceFromPriceCenter! / 1.609;
    }

    //prevent scanning if not within boundaries
    if (_wayfindingConstantsModel.userDistanceFromPriceCenter! >
        _wayfindingConstantsModel.milesFromPC!) {
      return;
    }

    flutterBlueInstance.startScan(
        timeout: Duration(seconds: 2), allowDuplicates: false);

    // Process the scan results (synchronously)
    flutterBlueInstance.scanResults.listen((results) {
      for (ScanResult scanResult in results) {
        String? calculatedUUID;

        // Identify possible advertisement ID
        calculatedUUID = extractAdvertisementUUID(scanResult);

        //Create BT objects to check continuity and store data
        identifyDevices(scanResult);

        // Filter out duplicated devices
        bool repeatedDevice = checkForDuplicates(scanResult);

        // Determines threshold qualifying devices and connects to devices when necessary
        bluetoothLogAnalysis(repeatedDevice, scanResult, calculatedUUID);
      }
    });

    // Remove objects that are no longer continuous found (+ grace period)
    removeNoncontinuousDevices();

    // Include device type for threshold
    List<Map> processedDevices = identifyDeviceTypes();
    // Remove objects that are no longer continuous found (+ grace period)
    removeNoncontinuousDevices();

    displayingDevices = List.of(processedDevices);
    notifyListeners();
    // If there are more than three devices, log location
    processOffloadingLogs(List.of(processedDevices));

    // Close on going scan in case it has not time out
    flutterBlueInstance.stopScan();

    // If app is not open, send logs when scanned
    if (inBackground) {
      _storage.deleteAll();
      await _storage.write(
          key: "lastBackgroundScan", value: DateTime.now().toString());

      // Reset dwell times
      resetDevices();
      _wayfindingConstantsModel.qualifyingDevices = 0;

      //LOG VALUE
      Map log = {
        "SOURCE_DEVICE_ADVERTISEMENT_ID": this.advertisementValue,
        "SOURCE": "$operatingSystem-UCSDMobileApp",
        "OPERATING_SYSTEM": operatingSystem,
        "LAT": (userLatitude == null) ? 0 : userLatitude,
        "LONG": (userLongitude == null) ? 0 : userLongitude,
        "DEVICE_LIST": processedDevices
      };

      // Send logs to API
      sendLogs(log);
      return;
    }

    // Write scannedObjects to storage
    scannedObjects.forEach((key, value) {
      _storage.write(key: key, value: jsonEncode(value));
    });

    // Clear previous scan results
    unprocessedDevices.clear();
    processedDevices.clear();
  }

  /// Gathers location data and prepares log to offload
  ///
  /// Will only send logs if threshold is met
  void processOffloadingLogs(List<Map> processedDevices) {
    // Identify OS of scanning device
    if (Platform.isAndroid) {
      operatingSystem = "Android";
    } else if (Platform.isIOS) {
      operatingSystem = "iOS";
    }
    if (_wayfindingConstantsModel.qualifyingDevices! >=
        _wayfindingConstantsModel.qualifiedDevicesThreshold!) {
      // Reset dwell times
      resetDevices();
      _wayfindingConstantsModel.qualifyingDevices = 0;

      //LOG VALUE
      Map log = {
        "SOURCE_DEVICE_ADVERTISEMENT_ID": this.advertisementValue,
        "SOURCE": "$operatingSystem-UCSDMobileApp",
        "OPERATING_SYSTEM": operatingSystem,
        "LAT": (userLatitude == null) ? 0 : userLatitude,
        "LONG": (userLongitude == null) ? 0 : userLongitude,
        "DEVICE_LIST": processedDevices
      };
      // Send logs to API
      sendLogs(log);
    }
  }

  /// Sends BT LE logs to API
  ///
  /// Will attach access token if logged in
  Future<void> sendLogs(Map log) async {
    // Attach token from user if logged in
    if (userDataProvider != null && userDataProvider!.isLoggedIn) {
      if (loggerHeader == null) {
        loggerHeader = {
          'Authorization':
              'Bearer ${userDataProvider?.authenticationModel?.accessToken}'
        };
      }

      // Send to offload API
      try {
        _networkHelper
            .authorizedPost(
                mobileLoggerEndpoint, loggerHeader, json.encode(log.toString()))
            .then((value) {});
      } catch (Exception) {
        // Silent login if access token is expired
        if (Exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          userDataProvider!.silentLogin();
          loggerHeader = {
            'Authorization':
                'Bearer ${userDataProvider?.authenticationModel?.accessToken}'
          };
          _networkHelper.authorizedPost(
              mobileLoggerEndpoint, loggerHeader, json.encode(log.toString()));
        }
      }
    } else {
      // Send logs to API for visitors
      try {
        await getNewToken();
        _networkHelper.authorizedPost(
            mobileLoggerEndpoint, tokenHeader, json.encode(log.toString()));
      } catch (Exception) {
        await getNewToken();
        _networkHelper.authorizedPost(
            mobileLoggerEndpoint, tokenHeader, json.encode(log.toString()));
      }
    }
  }

  // Calculates Advertisement ID if one is available
  String extractAdvertisementUUID(ScanResult scanResult) {
    String calculatedUUID = "";
    scanResult.advertisementData.manufacturerData.forEach((key, decimalArray) {
      calculatedUUID = calculateHexFromArray(
          decimalArray); //https://stackoverflow.com/questions/60902976/flutter-ios-to-ios-broadcast-beacon-not-working
    });
    return calculatedUUID;
  }

  // Identify types of device, most reliable for Apple devices
  List<Map> identifyDeviceTypes() {
    bool iOSDevice = false;
    List<Map> formattedLists = [];
    List<List<Object>> newBufferList = [];
    for (List<Object> deviceEntry in unprocessedDevices) {
      // Handle differences among platform
      if (Platform.isIOS) {
        deviceEntry.insert(
            1,
            ((scannedObjects[(deviceEntry[0].toString().substring(0, 36))]!
                        .deviceType !=
                    "")
                ? "${getAppleClassification(scannedObjects[deviceEntry[0].toString().substring(0, 36)]!.deviceType!)}"
                : "Unavailable"));
        if (getAppleClassification(
                scannedObjects[deviceEntry[0].toString().substring(0, 36)]!
                    .deviceType!) !=
            "") {
          iOSDevice = true;
        }
      } else if (Platform.isAndroid) {
        deviceEntry.insert(
            1,
            ((scannedObjects[deviceEntry[0].toString().substring(0, 17)]!
                        .deviceType !=
                    "")
                ? "${getAppleClassification(scannedObjects[deviceEntry[ScannedDevice.SCANNED_DEVICE_ID.index].toString().substring(0, 17)]!.deviceType!)}"
                : "Unavailable"));
        if (getAppleClassification(scannedObjects[
                    deviceEntry[ScannedDevice.SCANNED_DEVICE_ID.index]
                        .toString()
                        .substring(0, 17)]!
                .deviceType!) !=
            "") {
          iOSDevice = true;
        }
      }

      // Add identified device to temporary log
      newBufferList.add(deviceEntry);
    }

    /// Format Map for each device
    for (List<Object> deviceEntry in newBufferList) {
      Map<String, Object> deviceLog = {
        "SCANNED_DEVICE_ADVERTISEMENT_ID":
            deviceEntry[ScannedDevice.SCANNED_DEVICE_ADVERTISEMENT_ID.index],
        "SCANNED_DEVICE_ID": deviceEntry[ScannedDevice.SCANNED_DEVICE_ID.index],
        "SCANNED_DEVICE_TYPE":
            deviceEntry[ScannedDevice.SCANNED_DEVICE_TYPE.index],
        "SCANNED_DEVICE_DETECT_START":
            deviceEntry[ScannedDevice.SCANNED_DEVICE_DETECT_START.index],
        "SCANNED_DEVICE_DETECT_CURRENT": DateTime.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch)
            .toString(),
        "SCANNED_DEVICE_DETECT_SIGNAL_STRENGTH": deviceEntry[
            ScannedDevice.SCANNED_DEVICE_DETECT_SIGNAL_STRENGTH.index],
        "SCANNED_DEVICE_DETECT_DISTANCE":
            deviceEntry[ScannedDevice.SCANNED_DEVICE_DETECT_DISTANCE.index],
        "DEVICE_OS": (iOSDevice ? "iOS" : "non-iOS")
      };
      formattedLists.add(deviceLog);
    }
    return formattedLists;
  }

  /// Reset device dwell time when used to track user's location
  void resetDevices() {
    int currentMinutes = getMinutesTimeOfDay();
    scannedObjects.removeWhere((key, value) {
      if (currentMinutes < value.scanTimeMinutes!) {
        return (currentMinutes + 60) - value.scanTimeMinutes! >= 2;
      }
      return currentMinutes - value.scanTimeMinutes! >= 2;
    });
  }

  bool checkDeviceDwellTime(BluetoothDeviceProfile device) {
    int currentMinutes = getMinutesTimeOfDay();
    if (currentMinutes < device.scanTimeMinutes!) {
      return (currentMinutes + 60) - device.scanTimeMinutes! <
          _wayfindingConstantsModel.dwellTimeThreshold!;
    }
    return currentMinutes - device.scanTimeMinutes! <
        _wayfindingConstantsModel.dwellTimeThreshold!;
  }

  //Gather information on device scanned
  void identifyDevices(ScanResult scanResult) {
    int currentMinutes = getMinutesTimeOfDay();
    scannedObjects.update(scanResult.device.id.toString(), (value) {
      value.continuousDuration = true;
      value.rssi = scanResult.rssi;
      if (scanResult.advertisementData.txPowerLevel != null) {
        value.txPowerLevel = scanResult.advertisementData.txPowerLevel;
      }
      value.scanTimeMinutes = currentMinutes;
      value.scanIntervalAllowancesUsed = 0;
      return value;
    },
        ifAbsent: () => new BluetoothDeviceProfile(
            scanResult.device.id.toString(),
            scanResult.rssi,
            "",
            new List<String>.from({
              DateTime.fromMillisecondsSinceEpoch(
                      DateTime.now().millisecondsSinceEpoch)
                  .toString()
            }),
            true,
            currentMinutes));
  }

  // Ensure we only process unique devices during one scan
  bool checkForDuplicates(ScanResult scanResult) {
    bool repeatedDevice = false;
    unprocessedDevices.forEach((element) {
      String toFind = '${scanResult.device.id}';
      if (element.contains(toFind)) {
        repeatedDevice = true;
      }
    });
    return repeatedDevice;
  }

  String getCurrentTimeOfDay() {
    TimeOfDay currentTime = TimeOfDay.now();
    return "${currentTime.hour}:${currentTime.minute}";
  }

  int getMinutesTimeOfDay() {
    TimeOfDay currentTime = TimeOfDay.now();
    return currentTime.minute;
  }

  // Identify the Apple device type
  String getAppleClassification(String manufacturerName) {
    String deviceType = "";
    if (manufacturerName.contains("Mac")) {
      deviceType = "Computer";
    } else if (manufacturerName.contains("iPhone")) {
      deviceType = "Phone";
    } else if (manufacturerName.contains("Audio")) {
      deviceType = "Audio Output";
    } else if (manufacturerName.contains("iPad")) {
      deviceType = "Tablet";
    } else if (manufacturerName.contains("Watch")) {
      deviceType = "Watch";
    }
    return deviceType;
  }

  //Remove devices that are no longer scanned
  void removeNoncontinuousDevices() {
    scannedObjects.removeWhere((key, value) {
      bool isDeviceContinuous = checkDeviceDwellTime(value);
      if (!isDeviceContinuous &&
          value.scanIntervalAllowancesUsed! >=
              _wayfindingConstantsModel.scanIntervalAllowance!) {
        return true;
      } else if (!isDeviceContinuous &&
          value.scanIntervalAllowancesUsed! <
              _wayfindingConstantsModel.scanIntervalAllowance!) {
        value.scanIntervalAllowancesUsed = value.scanIntervalAllowancesUsed! + 1;
      }
      return false;
    });

    List<String> objectsToRemove = [];
    scannedObjects.forEach((key, value) {
      if (!value.continuousDuration! &&
          value.scanIntervalAllowancesUsed! >
              _wayfindingConstantsModel.scanIntervalAllowance!) {
        objectsToRemove.add(key);
      } else if (!value.continuousDuration! &&
          value.scanIntervalAllowancesUsed! <=
              _wayfindingConstantsModel.scanIntervalAllowance!) {
        value.scanIntervalAllowancesUsed = value.scanIntervalAllowancesUsed! + 1;
      }
    });
    objectsToRemove.forEach((element) {
      scannedObjects.remove(element);
    });
  }

  // Determine if we use the type to log location
  bool eligibleType(String manufacturerName) {
    return _wayfindingConstantsModel.allowableDevices!
            .contains(getAppleClassification(manufacturerName)) ||
        _wayfindingConstantsModel.allowableDevices!.contains(manufacturerName);
  }

  // Originally for on screen rendering but also calculates devices that meet our requirements
  void bluetoothLogAnalysis(
      bool repeatedDevice, ScanResult scanResult, String? calculatedUUID) {
    if (!repeatedDevice) {
      scannedObjects[scanResult.device.id.toString()]!.dwellTime =
          scannedObjects[scanResult.device.id.toString()]!.dwellTime! +
              (_wayfindingConstantsModel.scanWaitTime !* 60); //account for seconds
      scannedObjects[scanResult.device.id.toString()]!.distance =
          getDistance(scanResult.rssi);
      if (scannedObjects[scanResult.device.id.toString()]!.dwellTime! >=
          _wayfindingConstantsModel.dwellTimeThreshold!) {
        // Remove to reinstate thresholds
        // &&
        // scannedObjects[scanResult.device.id.toString()].distance <=
        //     distanceThreshold &&
        // eligibleType(
        //     scannedObjects[scanResult.device.id.toString()].deviceType)) {
        _wayfindingConstantsModel.qualifyingDevices =
            _wayfindingConstantsModel.qualifyingDevices! + 1; // Add the # of unique devices detected
      }

      // Log important information
      String deviceLog = '${scanResult.device.id}';

      if (calculatedUUID == null) {
        calculatedUUID = "";
      }
      List<Object> actualDeviceLog = [
        deviceLog,
        calculatedUUID.toString(),
        scannedObjects[scanResult.device.id.toString()]!
            .timeStamps![0]
            .toString(),
        scanResult.rssi.toInt(),
        scannedObjects[scanResult.device.id.toString()]!.distance!.toInt()
      ];

      unprocessedDevices.add(actualDeviceLog);

      if (Platform.isAndroid) {
        scannedObjects[scanResult.device.id.toString()]!.deviceType =
            parseForAppearance(scanResult);
      }

      if (scanResult.advertisementData.connectable &&
          scannedObjects[scanResult.device.id.toString()]!.deviceType == "") {
        extractBTServices(scanResult);
      }
    }
  }

  // Parse raw BT data for advertised info.
  String parseForAppearance(ScanResult scanResult) {
    Uint8List adData = scanResult.advertisementData.rawData as Uint8List;
    int index = 0;
    String data;

    while (index < adData.length) {
      data = "0x";
      int length = adData[index++];
      if (length == 0) //check if reached end of advertisement
        break;

      if (index + length >
          adData
              .length) //check if there is not enough data in the advertisement
        break;
      int type = adData[index++];
      length--;

      switch (type) {
        case 0x19:
          int i = index + length;
          for (; (index < i); index++) {
            data += adData[index].toRadixString(16).padLeft(2, '0');
          }
          return data;
        default:
          index += length;
          break;
      }
    }
    return "";
  }

  // Extract services from connect device to identify type
  void extractBTServices(ScanResult scanResult) async {
    try {
      var scannedDevice = scanResult.device;
      scannedDevice.connect().then((value) {
        scannedDevice.discoverServices().then((discoveredServices) {
          discoveredServices.forEach((service) {
            if (service.uuid.toString().toUpperCase().contains("1800")) {
              // GAP Service
              service.characteristics.forEach((characteristic) {
                if (characteristic.toString().toUpperCase().contains("2A01")) {
                  // Appearance
                  characteristic.read().then((deviceType) {
                    scannedObjects[scannedDevice.id.toString()]!.deviceType =
                        _wayfindingConstantsModel.deviceTypes!
                                .containsKey(deviceType.toString())
                            ? _wayfindingConstantsModel
                                .deviceTypes![deviceType.toString()]
                            : " ";
                  });
                }
              });
            } else if (service.uuid.toString().toUpperCase().contains("180A")) {
              // Manufacturer Data
              service.characteristics.forEach((characteristic) {
                if (characteristic.toString().toUpperCase().contains("2A24")) {
                  // Device Type Name
                  characteristic.read().then((deviceType) {
                    scannedObjects[scannedDevice.id.toString()]!.deviceType =
                        "${ascii.decode(deviceType).toString()}";
                  });
                }
              });
            }
          });
        });
      });
    } catch (exception) {}
  }

  // Used to log current user location or enable the location change listener
  Future<PermissionStatus> checkLocationPermission() async {
    return await _locationDataProvider!.locationObject.hasPermission();
  }

  Future<bool> checkLocationService() async {
    return await _locationDataProvider!.locationObject.serviceEnabled();
  }

  // Get the rough distance from bt device
  double getDistance(int rssi) {
    var txPower = -59; //hardcoded for now
    var ratio = (rssi * 1.0) / txPower;
    if (ratio < 1.0) {
      return (math.pow(ratio, 10) *
          3.28084); //multiply by 3.. for meters to feet conversion
    } else {
      return ((0.89976 * math.pow(ratio, 7.7095) + 0.111) *
          3.28084); //https://haddadi.github.io/papers/UBICOMP2016iBeacon.pdf
    }
  }

  // Internal constructor
  WayfindingProvider._internal();

  // Key generator for storage
  String _randomValue() {
    final rand = Random();
    final codeUnits = List.generate(20, (index) {
      return rand.nextInt(26) + 65;
    });

    return String.fromCharCodes(codeUnits);
  }

  //Parse advertisement data
  String calculateHexFromArray(decimalArray) {
    String uuid = '';
    decimalArray.forEach((i) => {uuid += i.toRadixString(16).padLeft(2, '0')});
    try {
      String uuid1 = uuid.substring(4, uuid.length - 12);
      return uuid1.toUpperCase();
    } catch (Exception) {
      return uuid;
    }
  }

  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization":
          "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
    };
    try {
      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");

      tokenHeader["Authorization"] = "Bearer " + response["access_token"];

      return true;
    } catch (e) {
      return false;
    }
  }

// Stops all ongoing processes
  void stopScans() {
    if (ongoingScanner != null) {
      ongoingScanner!.cancel();
      ongoingScanner = null;
    }
    flutterBlueInstance.stopScan();
    flutterBlueInstance.scanResults.listen((event) {}).cancel();
    beaconSingleton?.beaconBroadcast?.stop();
  }

  void coordinateAndLocation(
      Coordinates value, LocationDataProvider locationDataProvider) {
    _locationDataProvider = locationDataProvider;
    // Toggle off 'force off" value
    if (_coordinates != null) {
      forceOff = false;
    }
    _coordinates = value;
    notifyListeners();
  }

  get processedDevices => displayingDevices;
  get locationDataProvider => _locationDataProvider;
  get coordinate => _coordinates;
  set userProvider(UserDataProvider userDataProvider) {
    userDataProvider = userDataProvider;
    notifyListeners();
  }

  // Check previous permissions granted
  Future checkAdvancedWayfindingEnabled() async {
    await SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      if (sharedPreferences.containsKey("advancedWayfindingEnabled")) {
        advancedWayfindingEnabled =
            sharedPreferences.getBool("advancedWayfindingEnabled")!;
      } else {
        //Write to bt value
        sharedPreferences.setBool(
            "advancedWayfindingEnabled", advancedWayfindingEnabled!);
      }
    });
  }

  // Checks bt state of the device
  bool permissionState(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    // checkAdvancedWayfindingEnabled();
    // checkAdvancedWayfindingEnabled();
    checkForceOff(snapshot);
    if (snapshot.data as BluetoothState == BluetoothState.unauthorized ||
        snapshot.data as BluetoothState == BluetoothState.off ||
        forceOff) {
      if (ongoingScanner != null) ongoingScanner = null;
      forceOff = true;
      advancedWayfindingEnabled = false;
    }

    if (advancedWayfindingEnabled) init();
    return advancedWayfindingEnabled;
  }

  // Verify permissions are enabled
  void checkToResumeBluetooth(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("advancedWayfindingEnabled") &&
        prefs.getBool('advancedWayfindingEnabled')!) {
      if (firstInstance) {
        firstInstance = false;
        init();
      }
    }
  }

  void checkForceOff(AsyncSnapshot<dynamic> snapshot) async {
    if (snapshot.data as BluetoothState == BluetoothState.unauthorized ||
        snapshot.data as BluetoothState == BluetoothState.off ||
        !(await locationDataProvider.locationObject.serviceEnabled()) ||
        (PermissionStatus.granted !=
            await locationDataProvider.locationObject.hasPermission())) {
      forceOff = true;
      if (ongoingScanner != null) ongoingScanner = null;
    } else
      forceOff = false;
  }

  /// permissionGranted = true
  /// forceOff (currently false)
  void startBluetooth(BuildContext context, bool permissionGranted,
      AsyncSnapshot<dynamic> snapshot) async {
    checkForceOff(snapshot);
    if (forceOff) {
      advancedWayfindingEnabled = false;
      notifyListeners();
      return;
    }

    if (permissionGranted) {
      advancedWayfindingEnabled = true;
      init();
      forceOff = false;
    } else {
      forceOff = false;
    }
    notifyListeners();
  }

  // Sets up signal broadcasting with a random UUID
  void startBeaconBroadcast() {
    beaconSingleton = BeaconSingleton();
    beaconSingleton.init();
    advertisementValue = beaconSingleton.advertisingUUID;
  }

  Future instantiateScannedObjects() async {
    var savedDevices = await _storage.readAll();
    savedDevices.forEach((key, value) {
      if (key == "previousState") {
      } else if (key == "lastBackgroundScan") {
      } else if (key == "storageTime") {
      } else {
        scannedObjects.update(
            key, (v) => new BluetoothDeviceProfile.fromJson(jsonDecode(value)),
            ifAbsent: () =>
                new BluetoothDeviceProfile.fromJson(jsonDecode(value)));
      }
    });
    _storage.deleteAll();
  }

  double deg2rad(deg) {
    return deg * (math.pi / 180);
  }

  void setAWPreference() {
    SharedPreferences.getInstance().then((value) {
      value.setBool("advancedWayfindingEnabled", advancedWayfindingEnabled!);
    });
  }
}

// Helper Class
class BluetoothDeviceProfile {
  String? uuid;
  int? rssi;
  String? deviceType;
  List<String>? timeStamps;
  bool? continuousDuration;
  double? distance; // Feet
  int? txPowerLevel;
  double? dwellTime = 0;
  int? scanTimeMinutes;
  bool? timeThresholdMet = false;
  int? scanIntervalAllowancesUsed = 0;

  BluetoothDeviceProfile(this.uuid, this.rssi, this.deviceType, this.timeStamps,
      this.continuousDuration, this.scanTimeMinutes);

  BluetoothDeviceProfile.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        rssi = json['rssi'],
        deviceType = json['deviceType'],
        timeStamps = json['timeStamps'].cast<String>(),
        continuousDuration = json['continuousDuration'],
        distance = json['distance'],
        txPowerLevel = json['txPowerLevel'],
        dwellTime = json['dwellTime'],
        scanTimeMinutes = json['scanTimeMinutes'],
        timeThresholdMet = json['timeThresholdMet'],
        scanIntervalAllowancesUsed = json['scanIntervalAllowancesUsed'];

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'rssi': rssi,
      'deviceType': deviceType,
      'timeStamps': timeStamps,
      'continuousDuration': continuousDuration,
      'distance': distance,
      'txPowerLevel': txPowerLevel,
      'dwellTime': dwellTime,
      'scanTimeMinutes': scanTimeMinutes,
      'timeThresholdMet': timeThresholdMet,
      'scanIntervalAllowancesUsed': scanIntervalAllowancesUsed
    };
  }
}
