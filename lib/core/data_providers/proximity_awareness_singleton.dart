import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';
import 'package:background_fetch/background_fetch.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bluetooth_broadcast_singleton.dart';

enum ScannedDevice {
  SCANNED_DEVICE_ID,
  SCANNED_DEVICE_TYPE,
  SCANNED_DEVICE_ADVERTISEMENT_ID,
  SCANNED_DEVICE_DETECT_START,
  SCANNED_DEVICE_DETECT_SIGNAL_STRENGTH,
  SCANNED_DEVICE_DETECT_DISTANCE
}

class ProximityAwarenessSingleton extends ChangeNotifier{

  // Instance variable for starting beacon singleton
  BeaconSingleton beaconSingleton;

  // Advertisement string
  String advertisementValue;

  // List of devices that can be used towards achieving the threshold
  List allowableDevices = [];

  // Booleans for instantiating permissions
  bool firstInstance = true;
  bool proximityAwarenessEnabled = false;

  //Access previous bt setting
  SharedPreferences sharedPreferences;

  // Hashmap to track time stamps
  HashMap<String, BluetoothDeviceProfile> scannedObjects = new HashMap();

  // Internal Declaration
  static final ProximityAwarenessSingleton _bluetoothSingleton =
      ProximityAwarenessSingleton._internal();

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
  int backgroundScanInterval = 15;
  int deletionInterval = 30;

  // Keep track of devices that meet our requirements
  int qualifyingDevices = 0;

  // Dwell time threshold (10 minutes -> 600 seconds;
  int dwellTimeThreshold = 200; // In seconds

  // Default constant for scans
  int scanDuration = 2; //Seconds
  int waitTime = 15; // Minutes

  // Allows for continuous scan
  Timer ongoingScanner;

  // Lists for displaying scan results
  List loggedItems = [];
  static List<List<Object>> bufferList = [];

  //initialize location and permissions to be checked
  Location location = Location();

  // Device Types
  Map<String, dynamic> deviceTypes = {};

  // Access user's data to offload data
  UserDataProvider userDataProvider;

  // Allows singleton functionality
  factory ProximityAwarenessSingleton() {
    return _bluetoothSingleton;
  }

  // Initial method for scan set up
  init() async {

    if(userDataProvider.isLoggedIn) {
      //Instantiate access token for logged in user
      offloadDataHeader = {
        'Authorization':
        'Bearer ${userDataProvider?.authenticationModel?.accessToken}'
      };
    }

    //Check previous bluetooth setting
    await checkProximityAwarenessEnabled();

    // Only start scanning when permissions granted
    await flutterBlueInstance.isAvailable.then((value) {
      flutterBlueInstance.state.listen((event) async {
        // Identifies bluetooth as active
        if (event.index == 4) {
          //Use a try catch to avoid fetch errors, will use defaults.
          await extractAPIConstants();

          // Set up broadcasting for UCSD Identification
          startBeaconBroadcast();

          // Set up background scanning
          backgroundFetchSetUp();

          // Set bluetooth singleton as already started
          firstInstance = false;

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

  /// This function starts continuous scan (when permission is authorized)
  enableScanning() {
    //Start the initial scan
    startScan();


    // Enable timer, must wait duration before next method execution
    ongoingScanner = new Timer.periodic(
        Duration(seconds: waitTime* 4), (Timer t) => startScan());
  }

  // Start a bluetooth scan of determined second duration and listen to results
  startScan() {
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

    bool offloadLog = false;
    
    // If there are more than three devices, log location
    processOffloadingLogs(offloadLog, newBufferList);

    // Close on going scan in case it has not time out
    flutterBlueInstance.stopScan();

    // Clear previous scan results
    bufferList.clear();
    newBufferList.clear();
  }

  void processOffloadingLogs(bool offloadLog, List<Map> newBufferList) {
    qualifiedDevicesThreshold = 0;
    if (qualifyingDevices >= qualifiedDevicesThreshold) {
      double lat;
      double long;
      //loggedItems.add("LOCATION LOGGED");
      checkLocationPermission();
      location.getLocation().then((value) {
        lat = value.latitude;
      });
      location.getLocation().then((value) {
        long = value.longitude;
      });
    
      // Reset dwell times
      resetDevices();
      qualifyingDevices = 0;
    
      //LOG VALUE
      Map log = {
        "SOURCE_DEVICE_ADVERTISEMENT_ID": this.advertisementValue,
        "SOURCE": "UCSDMobileApp",
        "LAT": (lat == null) ? 0 : lat,
        "LONG": (long == null) ? 0 : long,
        "DEVICE_LIST": newBufferList
      };
    

      print(log.toString());
      sendLogs( log);
    

    }
  }
  void sendLogs(Map log) {
    print("Entered log dispatch");
      if (userDataProvider.isLoggedIn) {
        print("ACCES TOKEN:" + offloadDataHeader.toString());
        // Send to offload API
        var response = _networkHelper.authorizedPost(
            offloadLoggerEndpoint, offloadDataHeader, json.encode(log));
        response.then((value) => print("Response: " + value.toString()));
      } else {

        var response = _networkHelper.authorizedPost(offloadLoggerEndpoint, headers,json.encode(log) );
        response.then((value) => print("Response: " + value));


    }
  }

  String extractAdvertisementUUID(ScanResult scanResult, String calculatedUUID) {
    scanResult.advertisementData.manufacturerData
        .forEach((item, hexcodeAsArray) => {
              calculatedUUID = calculateHexFromArray(hexcodeAsArray)
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
            ((scannedObjects[(deviceEntry[0].toString().substring(0, 36))].deviceType != "")
                ? "${getAppleClassification(scannedObjects[deviceEntry[0].toString().substring(0, 36)].deviceType)}"
                : "Unavailable"));
      } else if (Platform.isAndroid) {
        deviceEntry.insert(
            1,
            ((scannedObjects[deviceEntry[0].toString().substring(0, 17)].deviceType != "")
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
    scannedObjects.forEach((key, value) {
      if (value.timeThresholdMet) {
        value.timeThresholdMet = false;
        value.dwellTime = 0;
        value.scanIntervalAllowancesUsed = 0;
        value.distance = 0;
      }
    });
  }

  //Gather information on device scanned
  void identifyDevices(ScanResult scanResult) {
    scannedObjects.update(scanResult.device.id.toString(), (value) {
      value.continuousDuration = true;
      value.rssi = scanResult.rssi;
      if (scanResult.advertisementData.txPowerLevel != null) {
        value.txPowerLevel = scanResult.advertisementData.txPowerLevel;
      }
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
            true));
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
      scannedObjects[scanResult.device.id.toString()].dwellTime += (waitTime*60); //account for seconds
      scannedObjects[scanResult.device.id.toString()].distance =
          getDistance(scanResult.rssi);
      if (scannedObjects[scanResult.device.id.toString()].dwellTime >=
              dwellTimeThreshold &&
          scannedObjects[scanResult.device.id.toString()].distance <=
              distanceThreshold &&
          eligibleType(
              scannedObjects[scanResult.device.id.toString()].deviceType)) {
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
        scannedObjects[scanResult.device.id.toString()]
            .distance
            .toInt()
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
    } catch (exception) {
    }
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
  ProximityAwarenessSingleton._internal();

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
    startScan();
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
          requiredNetworkType: NetworkType.NONE,
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
;      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");
      print('Response: $response');

      headers["Authorization"] = "Bearer " + response["access_token"];


      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map> fetchData() async {
    final response = await _networkHelper.authorizedFetch(
        bluetoothCharacteristicsEndpoint, headers);
    print('Response: $response');

    return json.decode(response);
  }

  void stopScans() {
    ongoingScanner.cancel();
    flutterBlueInstance.stopScan();
    flutterBlueInstance.scanResults.listen((event) {}).cancel();
    beaconSingleton.beaconBroadcast.stop();
  }
  //Get constants for scanning
  Future<void> getData() async {
    String _response = await _networkHelper.authorizedFetch(
        bluetoothConstantsEndpoint, headers);
    print('Response: $_response');

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
    } catch (Exception) {
    }
  }

  Future checkProximityAwarenessEnabled() async {
    await SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      if (sharedPreferences.containsKey("proximityAwarenessEnabled")) {
        proximityAwarenessEnabled = sharedPreferences.getBool("proximityAwarenessEnabled");
      } else {
        //Write to bt value
        sharedPreferences.setBool("proximityAwarenessEnabled", proximityAwarenessEnabled);
      }
    });
  }

  // Sets up signal broadcasting with a random UUID
  void startBeaconBroadcast() {
    beaconSingleton = BeaconSingleton();
    beaconSingleton.init();
    advertisementValue = beaconSingleton.advertisingUUID;
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
  bool timeThresholdMet = false;
  int scanIntervalAllowancesUsed = 0;

  BluetoothDeviceProfile(this.uuid, this.rssi, this.deviceType, this.timeStamps,
      this.continuousDuration);
}
