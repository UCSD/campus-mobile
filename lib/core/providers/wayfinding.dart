import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:background_fetch/background_fetch.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/wayfinding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_mobile_experimental/core/models/wayfinding_constants.dart';

import 'bluetooth.dart';
/// A file that handles AdvancedWayfinding feature to scan and identify nearby BT devices.
class WayfindingProvider extends ChangeNotifier {

  /// A structured model to simplify constants management and UCSD-ITS configurations.
  WayfindingConstantsModel _wayfindingConstantsModel;

  /// A service for fetching UCSD-ITS configurations from network.
  WayfindingService _wayfindingService;

  /// Responsible for managing the broadcasting of [advertisementValue].
  BeaconSingleton beaconSingleton;

  /// Distinguishes running in the background vs having app open.
  bool inBackground = false;

  /// Randomized sequence used to differentiate user devices while preserving user privacy.
  String advertisementValue;

  /// Identifies devices as Android or iOS.
  String operatingSystem;

  /// Confirms that this is the first instance of the Wayfinding feature, preventing parallel scanning.
  bool firstInstance = true;

  /// Confirms user's permission selection for AdvancedWayfinding feature.
  bool advancedWayfindingEnabled = false;

  /// Ensures AdvancedWayfinding is disabled when location & BT are unavailable.
  bool forceOff = false;

  /// Recalls past user permission selection for AdvancedWayfinding feature.
  SharedPreferences sharedPreferences;

  /// Provides location of device for logging scans.
  Coordinates _coordinates;

  /// Keeps track of scanned unique BT devices.
  HashMap<String, BluetoothDeviceProfile> scannedObjects = new HashMap();

  /// Instance of FlutterBlue library to handle raw BT processing.
  FlutterBlue flutterBlueInstance = FlutterBlue.instance;

  /// Stores data from background scans to preserve scan continuation.
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Holds header for mobile logger POST.
  Map<String, String> loggerHeader;
  
  /// Holds header for user token retrieval.
  final Map<String, String> tokenHeader = {
    "accept": "application/json",
  };

  /// Provides specialized support for requests to WSO2 APIs.
  final NetworkHelper _networkHelper = NetworkHelper();

  /// Endpoint used to send device logs to ITS specified destination.
  String mobileLoggerEndpoint =
      "https://api-qa.ucsd.edu:8243/mobileapplogger/v1.0.0/log";

  /// Responsible for recurrent scans after a certain time interval.
  Timer ongoingScanner;

  /// Displays BT devices that have been scanned (only for debugger view).
  List loggedItems = [];

  /// Gives an unfiltered list of scanned devices.
  static List<List<Object>> unprocessedDevices = [];

  /// Initialize location and permissions to be checked
  Location location = Location();

  /// Accesses user's profile to retrieve necessary tokens.
  UserDataProvider userDataProvider;
  
  /// Provides sole instance of AdvancedWayfinding feature.
  static final WayfindingProvider _bluetoothSingleton = WayfindingProvider._internal();
  
  /// Constructor for AdvancedWayfinding feature and prevents multiple instances.
  factory WayfindingProvider() {
    return _bluetoothSingleton;
  }

 /// Runs if AdvancedWayfinding was turned on.
  void init() async {

    // Verify that BT module is present in this device.
    await flutterBlueInstance.isAvailable.then((value) {
      flutterBlueInstance.state.listen((event) async {

        // Verify BT is available to start scanning.
        if (event.index == 4) {

          // Set Wayfinding preferences
          advancedWayfindingEnabled = true;
          sharedPreferences.setBool("advancedWayfindingEnabled", true);

          // Fetch UCSD_ITS scanning configurations.
          _wayfindingService = WayfindingService();
          await _wayfindingService.fetchData();
          _wayfindingConstantsModel = _wayfindingService.wayfindingConstantsModel;

          // Set up broadcasting for UCSD App Identification
          startBeaconBroadcast();

          // Set up background scanning
          backgroundFetchSetUp();

          // Set the minimum change to activate a new scan.
          location.changeSettings(accuracy: LocationAccuracy.low);

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
        Duration(minutes: _wayfindingConstantsModel.scanWaitTime), (Timer t) => startScan());
  }

  /// Scans for BT LE devices and processes them to send to ITS specified destination.
  ///
  /// Short circuits when not within ITS defined distance of UCSD.
  startScan() async {
    //Ensure that we are still within X miles of Price Center
    await location.getLocation().then((location) {
      _wayfindingConstantsModel.userDistanceFromPriceCenter = getHaversineDistance(
          _wayfindingConstantsModel.pcLatitude, _wayfindingConstantsModel.pcLongitude, location.latitude, location.longitude);

      // Convert km to miles
      _wayfindingConstantsModel.userDistanceFromPriceCenter = _wayfindingConstantsModel.userDistanceFromPriceCenter / 1.609;
    });
    print("Distance from PC: ${_wayfindingConstantsModel.userDistanceFromPriceCenter}");
    print("Miles from PC: ${_wayfindingConstantsModel.milesFromPC}");

    //prevent scanning if not within boundaries
    if (_wayfindingConstantsModel.userDistanceFromPriceCenter > _wayfindingConstantsModel.milesFromPC) {
      return;
    }

    flutterBlueInstance.startScan(
        timeout: Duration(seconds: 2), allowDuplicates: false);

    // Process the scan results (synchronously)
    flutterBlueInstance.scanResults.listen((results) {
      for (ScanResult scanResult in results) {
        String calculatedUUID;

        // Identify possible advertisement ID
        calculatedUUID = extractAdvertisementUUID(scanResult, calculatedUUID);

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
    List<Map> newBufferList = identifyDeviceTypes();

    // Remove objects that are no longer continuous found (+ grace period)
    removeNoncontinuousDevices();

    // If there are more than three devices, log location
    processOffloadingLogs(List.of(newBufferList));

    // Close on going scan in case it has not time out
    flutterBlueInstance.stopScan();

    // If scanning from foreground, send logs
    if (inBackground) {
      _storage.deleteAll();
      await _storage.write(
          key: "lastBackgroundScan", value: DateTime.now().toString());
      double lat;
      double long;
      checkLocationPermission();
      location.getLocation().then((value) {
        lat = value.latitude;
        long = value.longitude;

        // Reset dwell times
        resetDevices();
        _wayfindingConstantsModel.qualifyingDevices = 0;

        //LOG VALUE
        Map log = {
          "SOURCE_DEVICE_ADVERTISEMENT_ID": this.advertisementValue,
          "SOURCE": "$operatingSystem-UCSDMobileApp",
          "OPERATING_SYSTEM": operatingSystem,
          "LAT": (lat == null) ? 0 : lat,
          "LONG": (long == null) ? 0 : long,
          "DEVICE_LIST": newBufferList
        };

        // Send logs to API
        sendLogs(log);
        return;
      });
    }

    // Write scannedObjects to storage
    scannedObjects.forEach((key, value) {
      _storage.write(key: key, value: jsonEncode(value));
    });

    // Clear previous scan results
    unprocessedDevices.clear();
    newBufferList.clear();
  }

  /// Gathers location data and prepares log to offload
  ///
  /// Will only send logs if threshold is met
  void processOffloadingLogs(List<Map> newBufferList) {
    // Identify OS of scanning device
    if (Platform.isAndroid) {
      operatingSystem = "Android";
    } else if (Platform.isIOS) {
      operatingSystem = "iOS";
    }
    if (_wayfindingConstantsModel.qualifyingDevices >= _wayfindingConstantsModel.qualifiedDevicesThreshold) {
      double lat;
      double long;
      checkLocationPermission();
      location.getLocation().then((value) {
        lat = value.latitude;
        long = value.longitude;

        // Reset dwell times
        resetDevices();
        _wayfindingConstantsModel.qualifyingDevices = 0;

        //LOG VALUE
        Map log = {
          "SOURCE_DEVICE_ADVERTISEMENT_ID": this.advertisementValue,
          "SOURCE": "$operatingSystem-UCSDMobileApp",
          "OPERATING_SYSTEM": operatingSystem,
          "LAT": (lat == null) ? 0 : lat,
          "LONG": (long == null) ? 0 : long,
          "DEVICE_LIST": newBufferList
        };
        // Send logs to API
        sendLogs(log);
      });
    }
  }

  /// Sends BT LE logs to API
  ///
  /// Will attach access token if logged in
  void sendLogs(Map log) {
    // Attach token from user if logged in
    if (userDataProvider.isLoggedIn) {
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
                mobileLoggerEndpoint, loggerHeader, json.encode(log))
            .then((value) {});
      } catch (Exception) {
        // Silent login if access token is expired
        if (Exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          userDataProvider.silentLogin();
          loggerHeader = {
            'Authorization':
                'Bearer ${userDataProvider?.authenticationModel?.accessToken}'
          };
          _networkHelper.authorizedPost(
              mobileLoggerEndpoint, loggerHeader, json.encode(log));
        }
      }
    } else {
      // Send logs to API for visitors
      try {
        _networkHelper.authorizedPost(
            mobileLoggerEndpoint, tokenHeader, json.encode(log));
      } catch (Exception) {
        getNewToken();
        _networkHelper.authorizedPost(
            mobileLoggerEndpoint, tokenHeader, json.encode(log));
      }
    }
  }

  /// Calculates Advertisement ID if one is available
  String extractAdvertisementUUID(
      ScanResult scanResult, String calculatedUUID) {
    scanResult.advertisementData.manufacturerData.forEach((key, decimalArray) {
      calculatedUUID = calculateHexFromArray(
          decimalArray); //https://stackoverflow.com/questions/60902976/flutter-ios-to-ios-broadcast-beacon-not-working
    });
    return calculatedUUID;
  }

  /// Identify types of device, most reliable for Apple devices
  List<Map> identifyDeviceTypes() {
    bool iOSDevice = false;
    List<Map> formattedLists = [];
    List<List<Object>> newBufferList = [];
    for (List<Object> deviceEntry in unprocessedDevices) {
      // Handle differences among platform
      if (Platform.isIOS) {
        deviceEntry.insert(
            1,
            ((scannedObjects[(deviceEntry[0].toString().substring(0, 36))]
                        .deviceType !=
                    "")
                ? "${getAppleClassification(scannedObjects[deviceEntry[0].toString().substring(0, 36)].deviceType)}"
                : "Unavailable"));
        if (getAppleClassification(
                scannedObjects[deviceEntry[0].toString().substring(0, 36)]
                    .deviceType) !=
            "") {
          iOSDevice = true;
        }
      } else if (Platform.isAndroid) {
        deviceEntry.insert(
            1,
            ((scannedObjects[deviceEntry[0].toString().substring(0, 17)]
                        .deviceType !=
                    "")
                ? "${getAppleClassification(scannedObjects[deviceEntry[ScannedDevice.SCANNED_DEVICE_ID.index].toString().substring(0, 17)].deviceType)}"
                : "Unavailable"));
        if (getAppleClassification(scannedObjects[
                    deviceEntry[ScannedDevice.SCANNED_DEVICE_ID.index]
                        .toString()
                        .substring(0, 17)]
                .deviceType) !=
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
      if (currentMinutes < value.scanTimeMinutes) {
        return (currentMinutes + 60) - value.scanTimeMinutes >= 2;
      }
      return currentMinutes - value.scanTimeMinutes >= 2;
    });
  }

  bool checkDeviceDwellTime(BluetoothDeviceProfile device) {
    int currentMinutes = getMinutesTimeOfDay();
    if (currentMinutes < device.scanTimeMinutes) {
      return (currentMinutes + 60) - device.scanTimeMinutes <
          _wayfindingConstantsModel.dwellTimeThreshold;
    }
    return currentMinutes - device.scanTimeMinutes < _wayfindingConstantsModel.dwellTimeThreshold;
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
          value.scanIntervalAllowancesUsed >= _wayfindingConstantsModel.scanIntervalAllowance) {
        return true;
      } else if (!isDeviceContinuous &&
          value.scanIntervalAllowancesUsed < _wayfindingConstantsModel.scanIntervalAllowance) {
        value.scanIntervalAllowancesUsed++;
      }
      return false;
    });

    List<String> objectsToRemove = [];
    scannedObjects.forEach((key, value) {
      if (!value.continuousDuration &&
          value.scanIntervalAllowancesUsed > _wayfindingConstantsModel.scanIntervalAllowance) {
        objectsToRemove.add(key);
      } else if (!value.continuousDuration &&
          value.scanIntervalAllowancesUsed <= _wayfindingConstantsModel.scanIntervalAllowance) {
        value.scanIntervalAllowancesUsed++;
      }
    });
    objectsToRemove.forEach((element) {
      scannedObjects.remove(element);
    });
  }

  // Determine if we use the type to log location
  bool eligibleType(String manufacturerName) {
    return _wayfindingConstantsModel.allowableDevices
            .contains(getAppleClassification(manufacturerName)) ||
        _wayfindingConstantsModel.allowableDevices.contains(manufacturerName);
  }

  // Originally for on screen rendering but also calculates devices that meet our requirements
  void bluetoothLogAnalysis(
      bool repeatedDevice, ScanResult scanResult, String calculatedUUID) {
    if (!repeatedDevice) {
      scannedObjects[scanResult.device.id.toString()].dwellTime +=
          (_wayfindingConstantsModel.scanWaitTime * 60); //account for seconds
      scannedObjects[scanResult.device.id.toString()].distance =
          getDistance(scanResult.rssi);
      if (scannedObjects[scanResult.device.id.toString()].dwellTime >=
          _wayfindingConstantsModel.dwellTimeThreshold) {
        // Remove to reinstate thresholds
        // &&
        // scannedObjects[scanResult.device.id.toString()].distance <=
        //     distanceThreshold &&
        // eligibleType(
        //     scannedObjects[scanResult.device.id.toString()].deviceType)) {
        _wayfindingConstantsModel.qualifyingDevices += 1; // Add the # of unique devices detected
      }

      // Log important information
      String deviceLog = '${scanResult.device.id}';

      if (calculatedUUID == null) {
        calculatedUUID = "";
      }
      List<Object> actualDeviceLog = [
        deviceLog,
        calculatedUUID.toString(),
        scannedObjects[scanResult.device.id.toString()]
            .timeStamps[0]
            .toString(),
        scanResult.rssi.toInt(),
        scannedObjects[scanResult.device.id.toString()].distance.toInt()
      ];

      unprocessedDevices.add(actualDeviceLog);

      if (Platform.isAndroid) {
        scannedObjects[scanResult.device.id.toString()].deviceType =
            parseForAppearance(scanResult);
      }
      // _storage.write(key: _randomValue(), value: deviceLog);
      // Optimize device connection
      if (scanResult.advertisementData.connectable &&
          scannedObjects[scanResult.device.id.toString()].deviceType == "" &&
          scanResult != null) {
        extractBTServices(scanResult);
      }
    }
  }

  String parseForAppearance(ScanResult scanResult) {
    Uint8List adData = scanResult.advertisementData.rawData;
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
                    scannedObjects[scannedDevice.id.toString()].deviceType =
                        _wayfindingConstantsModel.deviceTypes.containsKey(deviceType.toString())
                            ? _wayfindingConstantsModel.deviceTypes[deviceType.toString()]
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
                    scannedObjects[scannedDevice.id.toString()].deviceType =
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
  void checkLocationPermission() async {
    // Set up new location object to get current location
    location = Location();
    location.changeSettings(accuracy: LocationAccuracy.low);
    PermissionStatus hasPermission;
    bool _serviceEnabled;

    // check if gps service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    //check if permission is granted
    hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      hasPermission = await location.requestPermission();
      if (hasPermission != PermissionStatus.granted) {
        return;
      }
    }
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

  // Start a background scan
  void _onBackgroundFetch(String taskID) async {
    String lastTimeStamp = await _storage.read(key: "lastBackgroundScan");

    // Start a background scan
    if (lastTimeStamp == null ||
        DateTime.now().difference(DateTime.parse(lastTimeStamp)).inMinutes >
            _wayfindingConstantsModel.backgroundScanInterval) {
      inBackground = true;
      startScan();
      inBackground = false;
    }
    BackgroundFetch.finish(taskID);
  }

  // Set background tasks
  void backgroundFetchSetUp() {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: _wayfindingConstantsModel.backgroundScanInterval,
              forceAlarmManager: false,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.ANY,
            ),
            _onBackgroundFetch)
        .then((int status) {
      _storage.write(
          key: _randomValue(),
          value: '[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      _storage.write(
          key: _randomValue(), value: '[BackgroundFetch] configure ERROR: $e');
    });
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


  void stopScans() {
    print("WAYFINDING IS OFF NOW");
    if (ongoingScanner != null) {
      ongoingScanner.cancel();
    }
    flutterBlueInstance.stopScan();
    flutterBlueInstance.scanResults.listen((event) {}).cancel();
    beaconSingleton?.beaconBroadcast?.stop();
  }

  set coordinates(Coordinates value) {
    print("Coordinates set to: $value");
    _coordinates = value;
    notifyListeners();
  }

  get coordinate => _coordinates;
  set userProvider(UserDataProvider userDataProvider){
    print("UserProvider set to: ${userDataProvider.isLoggedIn}");
    userDataProvider = userDataProvider;
    notifyListeners();

  }

  Future checkAdvancedWayfindingEnabled() async {
    await SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      if (sharedPreferences.containsKey("advancedWayfindingEnabled")) {
        advancedWayfindingEnabled =
            sharedPreferences.getBool("advancedWayfindingEnabled");
      } else {
        //Write to bt value
        sharedPreferences.setBool(
            "advancedWayfindingEnabled", advancedWayfindingEnabled);
      }
    });
  }
  bool permissionState(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    checkAdvancedWayfindingEnabled();
    if (snapshot.data as BluetoothState == BluetoothState.unauthorized ||
        snapshot.data as BluetoothState == BluetoothState.off) {
      forceOff = true;
      advancedWayfindingEnabled = false;
    }else{
      forceOff = false;
    }
    if(advancedWayfindingEnabled) init();
    return advancedWayfindingEnabled;
  }

  void checkToResumeBluetooth(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("advancedWayfindingEnabled") &&
        prefs.getBool('advancedWayfindingEnabled')) {
      if (firstInstance) {
        firstInstance = false;
        init();
      }
    }
  }

  /// permissionGranted = true
  /// forceOff (currently false)
  void startBluetooth(BuildContext context, bool permissionGranted) async {
    if(forceOff) return;
//    print("wayfinging enabled");
//    print(advancedWayfindingEnabled);
    if (permissionGranted) {
      init();
      if (!advancedWayfindingEnabled){
        forceOff = true;
      }
      if(advancedWayfindingEnabled) forceOff = false;

    }else{
      forceOff = false;
    }
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

  // From shuttle card
  double getHaversineDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double deg2rad(deg) {
    return deg * (math.pi / 180);
  }
  void setAWPreference(){
    SharedPreferences.getInstance().then((value) {
      value.setBool("advancedWayfindingEnabled", advancedWayfindingEnabled);
    });
  }
}



enum ScannedDevice {
  SCANNED_DEVICE_ID,
  SCANNED_DEVICE_TYPE,
  SCANNED_DEVICE_ADVERTISEMENT_ID,
  SCANNED_DEVICE_DETECT_START,
  SCANNED_DEVICE_DETECT_SIGNAL_STRENGTH,
  SCANNED_DEVICE_DETECT_DISTANCE
}

// Helper Class
class BluetoothDeviceProfile {
  String uuid;
  int rssi;
  String deviceType;
  List<String> timeStamps;
  bool continuousDuration;
  double distance; // Feet
  int txPowerLevel;
  double dwellTime = 0;
  int scanTimeMinutes;
  bool timeThresholdMet = false;
  int scanIntervalAllowancesUsed = 0;

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
