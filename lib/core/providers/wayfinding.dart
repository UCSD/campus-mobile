import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:background_fetch/background_fetch.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/providers/location.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:location/location.dart';
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

class AdvancedWayfindingSingleton extends ChangeNotifier{
//  LocationDataProvider _locationDataProvider;

  Coordinates _coordinates;

   // Variable holds the current state of scans
  bool inBackground = false;

  // Instance variable for starting beacon singleton
  BeaconSingleton beaconSingleton;

  // Advertisement string
  String advertisementValue;

  // Operating system of device
  String operatingSystem;

  // List of devices that can be used towards achieving the threshold
  List allowableDevices = [];

  // Booleans for instantiating permissions
  bool firstInstance = true;
  bool advancedWayfindingEnabled = false;

  //Access previous bt setting
  SharedPreferences sharedPreferences;

  // Hashmap to track time stamps
  HashMap<String, BluetoothDeviceProfile> scannedObjects = new HashMap();

  // Internal Declaration
  static final AdvancedWayfindingSingleton _bluetoothSingleton =
      AdvancedWayfindingSingleton._internal();

  //Flutter blue instance for scanning
  FlutterBlue flutterBlueInstance = FlutterBlue.instance;

  // Will add at the end, slows down scans
  final _storage = FlutterSecureStorage();

  /// Initialize headers
  Map<String, String> offloadDataHeader;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  // Holders for api calls
  final NetworkHelper _networkHelper = NetworkHelper();
  String bluetoothConstantsEndpoint =
      "https://api-qa.ucsd.edu:8243/bluetoothscanningcharacteristics/v1.0/constants";
  String bluetoothCharacteristicsEndpoint =
      "https://api-qa.ucsd.edu:8243/bluetoothdevicecharacteristic/v1.0.0/servicenames/1";
  String offloadLoggerEndpoint =
      "https://api-qa.ucsd.edu:8243/mobileapplogger/v1.0.0/log";

  //Thresholds for logging location
  int qualifiedDevicesThreshold = 0;
  int distanceThreshold = 10; // default in ZenHub
  int scanIntervalAllowance = 0;
  int backgroundScanInterval = 15; // Minutes
  int deletionInterval = 30; // Minutes

  // Keep track of devices that meet our requirements
  int qualifyingDevices = 0;

  // Dwell time threshold (10 minutes -> 600 seconds;
  int dwellTimeThreshold = 200; // In seconds

  // Default constant for scans
  int scanDuration = 2; //Seconds
  int waitTime = 15; // Minutes
  int dwellMinutes = 30;

  // Allows for continuous scan
  Timer ongoingScanner;

  // Lists for displaying scan results
  List loggedItems = [];
  static List<List<Object>> bufferList = [];

  //initialize location and permissions to be checked
//  Location location = Location();
    double userLatitude;
    double userLongitude;
    // Device Types
  Map<String, dynamic> deviceTypes = {};

  // Access user's data to offload data
  UserDataProvider userDataProvider;

  // Allows singleton functionality
  factory AdvancedWayfindingSingleton() {
    return _bluetoothSingleton;
  }

  // Initial method for scan set up
  Future<bool> init() async {
    if (userDataProvider.isLoggedIn) {
      //Instantiate access token for logged in user
      offloadDataHeader = {
        'Authorization':
            'Bearer ${userDataProvider?.authenticationModel?.accessToken}'
      };
    }

    //Check previous bluetooth setting
    await checkAdvancedWayfindingEnabled();

    userLongitude = _coordinates.lon;
    userLatitude = _coordinates.lat;

    // Only start scanning when permissions granted
    await flutterBlueInstance.isAvailable.then((value) {
      flutterBlueInstance.state.listen((event) async {
        // Identifies bluetooth as active
        if (event.index == 4) {
          advancedWayfindingEnabled = true;
          sharedPreferences.setBool("advancedWayfindingEnabled", true);
          //Use a try catch to avoid fetch errors, will use defaults.
          await extractAPIConstants();

          // Set up broadcasting for UCSD Identification
          startBeaconBroadcast();

          // Set up background scanning
          backgroundFetchSetUp();

          // Set bluetooth singleton as already started
          firstInstance = false;

          // Set the minimum change to activate a new scan.
          //location.changeSettings(accuracy: LocationAccuracy.low);

          // Enable location listening
          //checkLocationPermission();

          // Enable continuous scan
          enableScanning();

          return true;
        }
      });
    });
    return false;
  }

  /// This function starts continuous scan (when permission is authorized)
  enableScanning() {
    //Start the initial scan
    startScan();

    // Enable timer, must wait duration before next method execution
    ongoingScanner = new Timer.periodic(
        Duration(seconds: 15), (Timer t) => startScan());
  }

  // Start a bluetooth scan of determined second duration and listen to results
  startScan() async {
    print("Scanning..");
    // String previousState = await _storage.read(key: "previousState");
    //
    // if (inBackground) {
    //   await instantiateScannedObjects();
    // } else if (!inBackground && previousState == "background") {
    //   await instantiateScannedObjects();
    // }

    flutterBlueInstance.startScan(
        timeout: Duration(seconds: 2), allowDuplicates: false);

    // Process the scan results (synchronously)
    flutterBlueInstance.scanResults.listen((results) {
      for (ScanResult scanResult in results) {
        String calculatedUUID;

        calculatedUUID = extractAdvertisementUUID(scanResult, calculatedUUID);
        //Create BT Objects to check continuity and store data
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

    // // If scanning from foreground, clear secure storage
    // if (!inBackground) {
    //   await _storage.deleteAll();
    //   await _storage.write(key: "previousState", value: "foreground");
    // }
    // // Otherwise, let next scan know last scan was background
    // else {
    //   await _storage.write(key: "previousState", value: "background");
    //   await _storage.write(
    //       key: "lastBackgroundScan", value: DateTime.now().toString());
    // }
    //
    // // Write timestamp to storage
    // await _storage.write(key: "storageTime", value: getCurrentTimeOfDay());
    //
    // // Write scannedObjects to storage
    // scannedObjects.forEach((key, value) {
    //   _storage.write(key: key, value: jsonEncode(value));
    // });

    // Clear previous scan results
    bufferList.clear();
    newBufferList.clear();
  }

  void processOffloadingLogs(List<Map> newBufferList) {
    if (Platform.isAndroid) {
      operatingSystem = "Android";
    } else if (Platform.isIOS) {
      operatingSystem = "iOS";
    }
//    qualifiedDevicesThreshold = 0; // Todo: Comment out to test sending logs to test DB
    if (qualifyingDevices < qualifiedDevicesThreshold) {
      inBackground = false;
    }
    if (qualifyingDevices >= qualifiedDevicesThreshold) {
      double lat;
      double long;

      // Reset dwell times
      resetDevices();
      qualifyingDevices = 0;

      //LOG VALUE
      Map log = {
        "SOURCE_DEVICE_ADVERTISEMENT_ID": this.advertisementValue,
        "SOURCE": "${operatingSystem}-UCSDMobileApp",
        "OPERATING_SYSTEM": operatingSystem,
        "LAT": (userLatitude == null) ? 0 : userLatitude,
        "LONG": (userLongitude == null) ? 0 : userLongitude,
        "DEVICE_LIST": newBufferList
      };
      sendLogs(log);

//      Map testLog = {
//        "Time": DateTime.fromMillisecondsSinceEpoch(
//            DateTime.now().millisecondsSinceEpoch)
//            .toString(),
//        "SOURCE_DEVICE_ADVERTISEMENT_ID": this.advertisementValue,
//        "SOURCE": "UCSDMobileApp",
//        "LAT": (userLatitude == null) ? 0 : userLatitude.toString(),
//        "LONG": (userLongitude == null) ? 0 : userLongitude.toString(),
//        "DEVICE_LIST": newBufferList
//      };
//      new Dio().post(
//          "https://7pfm2wuasb.execute-api.us-west-2.amazonaws.com/qa",
//          data: json.encode(testLog));
    }
  }

  void sendLogs(Map log) {
    if (userDataProvider.isLoggedIn) {
      print("Offload data header: " + offloadDataHeader.toString());
      if (offloadDataHeader == null) {
        offloadDataHeader = {
          'Authorization':
              'Bearer ${userDataProvider?.authenticationModel?.accessToken}'
        };
      }
      print("AFTER GETTING ACCESS TOKEN" + offloadDataHeader.toString());
      // Send to offload API
      try {
        var response = _networkHelper
            .authorizedPost(
                offloadLoggerEndpoint, offloadDataHeader, json.encode(log))
            .then((value) {
          print("RESPONSE: ${value.toString()}");
        });
      } catch (Exception) {
        if (Exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          userDataProvider.silentLogin();
          offloadDataHeader = {
            'Authorization':
                'Bearer ${userDataProvider?.authenticationModel?.accessToken}'
          };
          _networkHelper.authorizedPost(
              offloadLoggerEndpoint, offloadDataHeader, json.encode(log));
        }
      }
    } else {
      try {
        var response = _networkHelper.authorizedPost(
            offloadLoggerEndpoint, headers, json.encode(log));
      } catch (Exception) {
        getNewToken();
        var response = _networkHelper.authorizedPost(
            offloadLoggerEndpoint, headers, json.encode(log));
      }
    }
  }

  String extractAdvertisementUUID(
      ScanResult scanResult, String calculatedUUID) {
    scanResult.advertisementData.manufacturerData.forEach((key, decimalArray) {
      calculatedUUID = calculateHexFromArray(
          decimalArray); //https://stackoverflow.com/questions/60902976/flutter-ios-to-ios-broadcast-beacon-not-working
    });
    return calculatedUUID;
  }

// Identify types of device, currently working for Apple devices and some android
  List<Map> identifyDeviceTypes() {
    List<Map> formattedLists = [];
    List<List<Object>> newBufferList = [];
    for (List<Object> deviceEntry in bufferList) {
      // Handle differences among platform
      if (Platform.isIOS) {
        deviceEntry.insert(
            1,
            ((scannedObjects[(deviceEntry[0].toString().substring(0, 36))]
                        .deviceType !=
                    "")
                ? "${getAppleClassification(scannedObjects[deviceEntry[0].toString().substring(0, 36)].deviceType)}"
                : "Unavailable"));
      } else if (Platform.isAndroid) {
        deviceEntry.insert(
            1,
            ((scannedObjects[deviceEntry[0].toString().substring(0, 17)]
                        .deviceType !=
                    "")
                ? "${getAppleClassification(scannedObjects[deviceEntry[ScannedDevice.SCANNED_DEVICE_ID.index].toString().substring(0, 17)].deviceType)}"
                : "Unavailable"));
      }

      // Add identified device to temporary log
      newBufferList.add(deviceEntry);
    }

    // Format Map for each device
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
            deviceEntry[ScannedDevice.SCANNED_DEVICE_DETECT_DISTANCE.index]
      };
      formattedLists.add(deviceLog);
    }
    return formattedLists;
  }

  // Reset device dwell time when used to track user's location
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
          dwellTimeThreshold;
    }
    return currentMinutes - device.scanTimeMinutes < dwellTimeThreshold;
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
    bufferList.forEach((element) {
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
          value.scanIntervalAllowancesUsed >= scanIntervalAllowance) {
        return true;
      } else if (!isDeviceContinuous &&
          value.scanIntervalAllowancesUsed < scanIntervalAllowance) {
        value.scanIntervalAllowancesUsed++;
      }
      return false;
    });

    List<String> objectsToRemove = [];
    scannedObjects.forEach((key, value) {
      if (!value.continuousDuration &&
          value.scanIntervalAllowancesUsed > scanIntervalAllowance) {
        objectsToRemove.add(key);
      } else if (!value.continuousDuration &&
          value.scanIntervalAllowancesUsed <= scanIntervalAllowance) {
        value.scanIntervalAllowancesUsed++;
      }
    });
    objectsToRemove.forEach((element) {
      scannedObjects.remove(element);
    });
  }

  // Determine if we use the type to log location
  bool eligibleType(String manufacturerName) {
    return allowableDevices
            .contains(getAppleClassification(manufacturerName)) ||
        allowableDevices.contains(manufacturerName);
  }

  // Originally for on screen rendering but also calculates devices that meet our requirements
  void bluetoothLogAnalysis(
      bool repeatedDevice, ScanResult scanResult, String calculatedUUID) {
    if (!repeatedDevice) {
      scannedObjects[scanResult.device.id.toString()].dwellTime +=
          (waitTime * 60); //account for seconds
      scannedObjects[scanResult.device.id.toString()].distance =
          getDistance(scanResult.rssi);
      if (scannedObjects[scanResult.device.id.toString()].dwellTime >=
              dwellTimeThreshold){
        // Remove to reinstate thresholds
        // &&
          // scannedObjects[scanResult.device.id.toString()].distance <=
          //     distanceThreshold &&
          // eligibleType(
          //     scannedObjects[scanResult.device.id.toString()].deviceType)) {
        qualifyingDevices += 1; // Add the # of unique devices detected
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

      bufferList.add(actualDeviceLog);

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
                        deviceTypes.containsKey(deviceType.toString())
                            ? deviceTypes[deviceType.toString()]
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
//  void checkLocationPermission() async {
//    print('Location Permission Request: advanced_wayfinding_singleton');
//    // Set up new location object to get current location
//    location = Location();
//    location.changeSettings(accuracy: LocationAccuracy.low);
//    PermissionStatus hasPermission;
//    bool _serviceEnabled;
//
//    // check if gps service is enabled
//    _serviceEnabled = await location.serviceEnabled();
//    if (!_serviceEnabled) {
//      _serviceEnabled = await location.requestService();
//      if (!_serviceEnabled) {
//        return;
//      }
//    }
//    //check if permission is granted
//    hasPermission = await location.hasPermission();
//    if (hasPermission == PermissionStatus.denied) {
//      hasPermission = await location.requestPermission();
//      if (hasPermission != PermissionStatus.granted) {
//        return;
//      }
//    }
//  }

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
  AdvancedWayfindingSingleton._internal();

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
    inBackground = true;
    String lastTimeStamp = await _storage.read(key: "lastBackgroundScan");

    // Start a background scan
    if (lastTimeStamp == null ||
        DateTime.now().difference(DateTime.parse(lastTimeStamp)).inMinutes >
            backgroundScanInterval) {
      inBackground = true;
      startScan();
    }
    BackgroundFetch.finish(taskID);
  }

  // Set background tasks
  void backgroundFetchSetUp() {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: backgroundScanInterval,
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

      headers["Authorization"] = "Bearer " + response["access_token"];

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map> fetchData() async {
    final response = await _networkHelper.authorizedFetch(
        bluetoothCharacteristicsEndpoint, headers);

    return json.decode(response);
  }

  void stopScans() {
    if (ongoingScanner != null) {
      ongoingScanner.cancel();
    }
    flutterBlueInstance.stopScan();
    flutterBlueInstance.scanResults.listen((event) {}).cancel();
    beaconSingleton.beaconBroadcast.stop();
  }

  //Get constants for scanning
  Future<void> getData() async {
    String _response = await _networkHelper.authorizedFetch(
        bluetoothConstantsEndpoint, headers);

    final _json = json.decode(_response);
    qualifiedDevicesThreshold = int.parse(_json["uniqueDevices"]);
    distanceThreshold = int.parse(_json["distanceThreshold"]);
    dwellTimeThreshold = int.parse(_json["dwellTimeThreshold"]);
    scanDuration = int.parse(_json["scanDuration"]);
    waitTime = int.parse(_json["waitTime"]);
    scanIntervalAllowance = int.parse(_json["scanIntervalAllowance"]);
    var jsonArr = _json["deviceCharacteristics"];
    allowableDevices = List.from(jsonArr);
    backgroundScanInterval = _json["backgroundScanInterval"];
    deletionInterval = _json["deletionInterval"];
  }

  Future extractAPIConstants() async {
    try {
      await getNewToken();
      deviceTypes = await fetchData();
      // Fetch parameters for scanning
      await getData();
      // Get device constants
    } catch (Exception) {}
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
  set coordinates(Coordinates value) {
    _coordinates = value;
  }
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
