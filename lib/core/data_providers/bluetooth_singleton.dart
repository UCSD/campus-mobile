import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';
import 'dart:io' show Platform;

import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';

class BluetoothSingleton {
  // Hashmap to track time stamps
  HashMap<String, BluetoothDeviceProfile> scannedObjects = new HashMap();

  // Internal Declaration
  static final BluetoothSingleton _bluetoothSingleton =
      BluetoothSingleton._internal();

  //Flutter blue instance for scanning
  FlutterBlue flutterBlueInstance = FlutterBlue.instance;

  // Will add at the end, slows down scans
  final _storage = FlutterSecureStorage();

  /// Initialize header
  final Map<String, String> header = {
    'Authorization': 'Bearer 8e67e165-08ae-382f-87bc-7ec318d0b113'
  };

  // Holders for location
  final NetworkHelper _networkHelper = NetworkHelper();
  String bluetoothConstantsEndpoint =
      "https://ucsd-its-wts-dev.s3-us-west-1.amazonaws.com/replatform/v1/bluetooth_constants.json";
  String bluetoothCharacteristicsEndpoint =
      "https://api-qa.ucsd.edu:8243/bluetoothdevicecharacteristic/v1.0.0/servicenames/1";

  double previousLatitude = 0;
  double previousLongitude = 0;

  int uniqueIdThreshold = 0;
  int distanceThreshold = 10; // default in ZenHub

  // Keep track of devices that meet our requirements
  int uniqueDevices = 0;

  // Dwell time threshold (10 minutes -> 600 seconds;
  int dwellTimeThreshold = 200;

  // Constant for scans
  int scanDuration = 2; //Seconds
  var waitTime = 15; // Seconds

  // Tracker to enable location listener
  int enable = 0;

  // Allows for continuous scan
  Timer ongoingScanner;

  // Lists for displaying scan results
  List loggedItems = [];
  static List bufferList = [];
  static List<ScanResult> scannedDevices = [];

  //initialize location and permissions to be checked
  Location location = Location();
  LocationData _currentLocation;

  // Device Types
  Map<String, dynamic> deviceTypes;

  //flutterBlueInstance.scan(timeout: Duration(seconds: scanDuration), allowDuplicates: false)
  factory BluetoothSingleton() {
    // bluetoothStream();
    return _bluetoothSingleton;
  }

  init() async {
    //deviceTypes = await fetchData();
   // print("Device map: ${deviceTypes.toString()}");
    //await getData();

    // Set the minimum change to activate a new scan.
    location.changeSettings(accuracy: LocationAccuracy.low);

    // Enable location listening
    _logLocation();

    // Enable continuous scan
    enableListener();
  }

  /// This function starts continuous scan (on app open)
  enableListener() {
    //Start the initial scan
    Timer.run(() {
      startScan();
    });
    // Enable timer, must wait duration before next method execution
    ongoingScanner = new Timer.periodic(
        Duration(seconds: waitTime), (Timer t) => startScan());
  }

  Future<void> getData() async {
    String _response =
        await _networkHelper.fetchData(bluetoothConstantsEndpoint);
    //print(_response);
    final _json = json.decode(_response);
    uniqueIdThreshold = int.parse(_json["uniqueDevices"]);
    distanceThreshold = int.parse(_json["distanceThreshold"]);
    dwellTimeThreshold = int.parse(_json["dwellTimeThreshold"]);
    scanDuration = int.parse(_json["scanDuration"]);
    waitTime = int.parse(_json["waitTime"]) * 5;
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

  // Start a bluetooth scan of 2 second duration and listen to results
  startScan() {
    flutterBlueInstance.startScan(
        timeout: Duration(seconds: 2), allowDuplicates: false);

    // Process the scan results (synchronously)
    flutterBlueInstance.scanResults.listen((results) {
      for (ScanResult scanResult in results) {
        String calculatedUUID;

        scanResult.advertisementData.manufacturerData
            .forEach((item, hexcodeAsArray) => {
                  calculatedUUID = ("calculated UUID String : " +
                      calculateHexFromArray(hexcodeAsArray))
                });

        //Create BT Objects to render + check continuity
        identifyDevices(scanResult);

        bool repeatedDevice = checkForDuplicates(scanResult);

        //PARSE FOR FRONTEND DISPLAY
        frontEndFilter(repeatedDevice, scanResult, calculatedUUID);
      }
    });

    // Remove objects that are no longer continuous found
    removeNoncontinuousDevices();

    List<String> newBufferList = [];
    for (String deviceEntry in bufferList) {
      newBufferList.add(deviceEntry + /*
          ((scannedObjects[deviceEntry.substring(4, 40)].deviceType != "")
              ? "Device type: ${getAppleClassification(scannedObjects[deviceEntry.substring(4, 40)].deviceType)}"
              : "Device type: Unavailable") +*/
          "\n");
    }
    // Add the processed buffer to overall log
    loggedItems.insertAll(loggedItems.length, newBufferList);

    // If there are more than three devices, log location
    if (uniqueDevices >= uniqueIdThreshold) {
      loggedItems.add("LOCATION LOGGED");
      _logLocation();

      // Reset dwell times
      resetDevices();
      uniqueDevices = 0;
    }

    String timeStamp = "TIMESTAMP: " +
        DateTime.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch)
            .toString() +
        '\n';

    // Add time stamp for differentiation
    loggedItems.add(timeStamp);

    // Store timestamp
    _storage.write(key: _randomValue(), value: timeStamp);

    // Close on going scan in case it has not time out
    flutterBlueInstance.stopScan();

    // Clear previous scan results
    bufferList.clear();
    newBufferList.clear();

    scannedDevices.clear();
  }

  // Reset device dwell time when used to track user's location
  void resetDevices() {
    scannedObjects.forEach((key, value) {
      if (value.timeThresholdMet) {
        value.timeThresholdMet = false;
        value.dwellTime = 0;
      }
    });
  }

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
            new List<TimeOfDay>.from({TimeOfDay.now()}),
            true,
            scanResult.advertisementData.txPowerLevel));
  }

  bool checkForDuplicates(ScanResult scanResult) {
    bool repeatedDevice = false;
    bufferList.forEach((element) {
      String toFind = 'ID: ${scanResult.device.id}';
      if (element.contains(toFind)) {
        repeatedDevice = true;
      }
    });
    return repeatedDevice;
  }

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

  void removeNoncontinuousDevices() {
    List<String> objectsToRemove = [];
    scannedObjects.forEach((key, value) {
      if (!value.continuousDuration) {
        objectsToRemove.add(key);
      }
    });
    objectsToRemove.forEach((element) {
      scannedObjects.remove(element);
    });
  }

  bool eligibleType(String manufacturerName) {
    return getAppleClassification(manufacturerName) != "" ? true : false;
  }

  void frontEndFilter(
      bool repeatedDevice, ScanResult scanResult, String calculatedUUID) {
    if (!repeatedDevice) {
      scannedObjects[scanResult.device.id.toString()].dwellTime += (waitTime);
      scannedObjects[scanResult.device.id.toString()].distance =
          getDistance(scanResult.rssi);
      if (scannedObjects[scanResult.device.id.toString()].dwellTime >=
              dwellTimeThreshold &&
          scannedObjects[scanResult.device.id.toString()].distance <=
              distanceThreshold &&
          eligibleType(
              scannedObjects[scanResult.device.id.toString()].deviceType)) {
        uniqueDevices += 1; // Add the # of unique devices detected
      }

      // Log important information
      String deviceLog = 'ID: ${scanResult.device.id}' +
          "\n" +
          "RSSI: " +
          scanResult.rssi.toString() +
          " Dwell time: " +
          scannedObjects[scanResult.device.id.toString()].dwellTime.toString() +
          " " +
          (calculatedUUID != null ? calculatedUUID : "") +
          " " +
          " Distance(ft): ${getDistance(scanResult.rssi)}\n" +
          "Raw Data: ${scanResult.advertisementData.rawData}";

      bufferList.add("$deviceLog");

      _storage.write(key: _randomValue(), value: deviceLog);
      // Optimize device connection
      if (Platform.isAndroid)
        scannedObjects[scanResult.device.id.toString()].deviceType =
            parseForAppearance(scanResult);

      if (scanResult.advertisementData.connectable &&
          scannedObjects[scanResult.device.id.toString()].deviceType == "" &&
          scanResult != null) {
        extractBTServices(scanResult);
      }
    }
  }

  String parseForAppearance (ScanResult scanResult) {
    Uint8List adData = scanResult.advertisementData.rawData;
    int index = 0;
    int dataSize = 0;
    String data;

    while (index < adData.length) {
      data = "0x";
      int length = adData[index++];
      if (length == 0) //check if reached end of advertisement
        break;

      if (index + length > adData.length) //check if there is not enough data in the advertisement
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

  void extractBTServices(ScanResult scanResult) async {
    try {
      scanResult.device.connect().then((value) {
        scanResult.device.discoverServices().then((value) {
          value.forEach((element) {
            if (element.uuid.toString().toUpperCase().contains("1800")) { // GAP Service
              element.characteristics.forEach((element) {
                if (element.toString().toUpperCase().contains("2A01")) { // Appearance
                  element.read().then((value) {
                    //   print("Device type: ${ascii.decode(value).toString()}");
                    scannedObjects[scanResult.device.id.toString()].deviceType =
                      "Device type: ${ascii.decode(value).toString()}";
                  });
                }
              });
            }
            else if (element.uuid.toString().toUpperCase().contains("180A")) { // Device Info Service
              element.characteristics.forEach((element) {
                if (element.toString().toUpperCase().contains("2A24")) { // Model Number String
                  element.read().then((value) {
                 //   print("Device type: ${ascii.decode(value).toString()}");
                    scannedObjects[scanResult.device.id.toString()].deviceType =
                        "Device type: ${ascii.decode(value).toString()}";
                  });
                }
              });
            }
          });
        });
      });
    } catch (exception) {}
  }

  Future<Map> fetchData() async {
    final response = await _networkHelper.authorizedFetch(
        bluetoothCharacteristicsEndpoint, header);

    return json.decode(response);
  }

// Cancel ongoing scans to start a new one
  /*pauseScan() {
    ongoingScanner.cancel();
    flutterBlueInstance.stopScan();
  }*/

  // Start a new scan with the given changes (For triggered scans or disposing a page)
  /*resumeScan(int scanTime) {
    // Stop any ongoing scan
    pauseScan();

    // Set off an immediate scan
    startNewScan(scanTime);

    // Trigger a continuous scan
    ongoingScanner = new Timer.periodic(
        Duration(seconds: waitTime), (Timer t) => startNewScan(scanTime));
  }*/

  // Helper method to set up a modified scan (will be deleted for production)
  /* startNewScan(int scanTime) {
    // Start scan with specified duration
    flutterBlueInstance.startScan(
        timeout: Duration(minutes: scanTime), allowDuplicates: false);

    // Process scan results
    flutterBlueInstance.scanResults.listen((results) {
      for (ScanResult scanResult in results) {
        print(scanResult.advertisementData.manufacturerData);
        identifyDevices(scanResult);



        // Print to terminal ACTUAL scan result
        print('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != ""
                ? scanResult.device.name
                : "Unknown") +
            "\n");

        //PARSE FOR FRONT END DISPLAY (avoids overwhelming data)
        if (!bufferList.contains('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != ""
                ? scanResult.device.name
                : "Unknown") +
            "\n")) {
          bufferList.add('ID: ${scanResult.device.id}' +
              "\nDevice name: " +
              (scanResult.device.name != ""
                  ? scanResult.device.name
                  : "Unknown") +
              "\n");
        }
      }
    });

    // Add process scan results to scan log
    loggedItems.addAll(bufferList);

    // Add time stamp
    loggedItems.add("TIMESTAMP: " +
        DateTime.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch)
            .toString() +
        '\n');




    // Stop any scan not yet timed out
    flutterBlueInstance.stopScan();

    // Clear the previous scan results
    bufferList.clear();
  }*/

  // Used to log current user location or enable the location change listener
  void _logLocation() async {
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

    //once permissions are verified, get location asynchronously
    _currentLocation = await location.getLocation();

    // Location Logging
    String logLocation = " LATITUDE: " +
        _currentLocation.latitude.toString() +
        " LONGITUDE: " +
        _currentLocation.longitude.toString() +
        "\n";

    // Add location logging to rendered list
    loggedItems.add(logLocation);

    // Store location logs
    _storage.write(key: _randomValue(), value: logLocation);
  }

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
  BluetoothSingleton._internal();

  // Log storage size
  Future<Null> _readAll() async {
    final all = await _storage.readAll();
    print('Secure storage item count is ${all.length}');
  }

  // Key generator for storage
  String _randomValue() {
    final rand = Random();
    final codeUnits = List.generate(20, (index) {
      return rand.nextInt(26) + 65;
    });

    return String.fromCharCodes(codeUnits);
  }
}

// Helper Class
class BluetoothDeviceProfile {
  String uuid;
  int rssi;
  String deviceType;
  List<TimeOfDay> timeStamps;
  bool continuousDuration;
  int measuredPower;
  double distance; // Feet
  int txPowerLevel;
  double dwellTime = 0;
  bool timeThresholdMet = false;

  BluetoothDeviceProfile(this.uuid, this.rssi, this.deviceType, this.timeStamps,
      this.continuousDuration, this.measuredPower);
}
