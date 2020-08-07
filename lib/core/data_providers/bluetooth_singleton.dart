import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:math';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

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

  // Holders for location
  final NetworkHelper _networkHelper = NetworkHelper();
  String bluetoothConstantsEndpoint = "https://ucsd-its-wts-dev.s3-us-west-1.amazonaws.com/replatform/v1/bluetooth_constants.json";

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

  //flutterBlueInstance.scan(timeout: Duration(seconds: scanDuration), allowDuplicates: false)
  factory BluetoothSingleton() {
    // bluetoothStream();
    return _bluetoothSingleton;
  }

  init()  async {

    await getData();

    // Set the minimum change to activate a new scan.
    location.changeSettings(
        accuracy: LocationAccuracy.low);

    // Enable location listening
    _logLocation();

    // Enable continuous scan
    enableListener();
  }

  /// This function starts continuous scan (on app open)
  enableListener() {

    //Start the initial scan
    Timer.run(() {startScan();});
    // Enable timer, must wait duration before next method execution
    ongoingScanner = new Timer.periodic(
        Duration(seconds: waitTime), (Timer t) => startScan());
  }


  Future<void> getData() async {
    String _response = await _networkHelper.fetchData(bluetoothConstantsEndpoint);
    print(_response);
    final _json = json.decode(_response);
    uniqueIdThreshold = int.parse(_json["uniqueDevices"]);
    distanceThreshold = int.parse(_json["distanceThreshold"]);
    dwellTimeThreshold = int.parse(_json["dwellTimeThreshold"]);
    scanDuration = int.parse(_json["scanDuration"]);
    waitTime = int.parse(_json["waitTime"]);
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

        scanResult.advertisementData.manufacturerData.forEach((item, hexcodeAsArray) => {
          calculatedUUID = ("calculated UUID String : " + calculateHexFromArray(hexcodeAsArray))
        });

        //Create BT Objects to render + check continuity
        identifyDevices(scanResult);

        bool repeatedDevice = checkForDuplicates(scanResult);

        //PARSE FOR FRONTEND DISPLAY
        frontEndFilter(repeatedDevice, scanResult, calculatedUUID);

      }});

    // Remove objects that are no longer continuous found
    removeNoncontinuousDevices();

    processDevices();
  }

  Future<void> processDevices()  async{
    bool done;
    done =  connectDevices();

    if(done) {
      // Add the processed buffer to overall log
      loggedItems.insertAll(loggedItems.length, bufferList);

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
              DateTime
                  .now()
                  .millisecondsSinceEpoch)
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
    }
  }

  bool connectDevices()  {
    scannedDevices.forEach((scanResult)  {
      connectToDevice(scanResult);
    });
    return true;
  }

  // Reset device dwell time when used to track user's location
  void resetDevices(){
    scannedObjects.forEach((key, value) {
      if(value.timeThresholdMet){
        value.timeThresholdMet = false;
        value.dwellTime = 0;
      }

    });
  }

  void connectToDevice(ScanResult scanResult)  {
    try {
      scanResult.device.connect(autoConnect: false).timeout(
          Duration(seconds: 2), onTimeout: () {
        bufferList.add(
            "\nConnection to " + scanResult.device.id.toString() + "timed out");
        scanResult.device.disconnect();
      }).then((value) =>
          bufferList.add(
              "Connection to " + scanResult.device.id.toString() + "success"));
    }catch(Exception){

    }
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
            scanResult.device.id.toString(), scanResult.rssi, "",
            new List<TimeOfDay>.from({TimeOfDay.now()}), true,
            scanResult.advertisementData.txPowerLevel)
    );
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

  void removeNoncontinuousDevices() {
    List<String> objectsToRemove = [];
    scannedObjects.forEach((key, value) {
      if(!value.continuousDuration){
        objectsToRemove.add(key);
      }
    });
    objectsToRemove.forEach((element) {
      scannedObjects.remove(element);
    });
  }

  void frontEndFilter(bool repeatedDevice, ScanResult scanResult, String calculatedUUID) {
    if (!repeatedDevice) {
      scannedObjects[scanResult.device.id.toString()].dwellTime +=
      (waitTime);
      scannedObjects[scanResult.device.id.toString()].distance = getDistance(scanResult.rssi);
      if (scannedObjects[scanResult.device.id.toString()].dwellTime >=
          dwellTimeThreshold && scannedObjects[scanResult.device.id.toString()].distance <=
          distanceThreshold) {
        uniqueDevices+= 1; // Add the # of unique devices detected
      }

      // Log important information
      String deviceLog ='ID: ${scanResult.device.id}' +
          "\n" + "RSSI: " + scanResult.rssi.toString() + " Dwell time: " +
          scannedObjects[scanResult.device.id.toString()].dwellTime
              .toString() + " " + (calculatedUUID != null ? calculatedUUID : "") + " " + " Distance(ft): ${getDistance(scanResult.rssi)}" + "\n";

      // Add to frontend staging
      bufferList.add(deviceLog);
      scannedDevices.add(scanResult);

      // Store bt logs
      //_storage.write(key: _randomValue(), value: deviceLog);


      // extractBTServices(scanResult);
    }
  }

  void extractBTServices(ScanResult scanResult) async {
    scanResult.device.connect().then((value) {
      scanResult.device.discoverServices().then((value) {
        bufferList.add("SERVICES");
        value.forEach((element) {
          // element.includedServices.forEach((element) {element.characteristics.forEach((element) {element.toString();});});
          bufferList.add(element.toString());
          bufferList.add("\n");

        });
      });
      bufferList.add("SERVICE UUIDs");
      scanResult.advertisementData.serviceUuids.forEach((element) {
        bufferList.add(element.toString());
      });
      bufferList.add("\n");
    });
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
    var ratio = (rssi*1.0)/txPower;
    if(ratio < 1.0) {
      return (math.pow(ratio,10)*3.28084); //multiply by 3.. for meters to feet conversion
    }
    else {
      return ((0.89976*math.pow(ratio,7.7095) + 0.111)*3.28084); //https://haddadi.github.io/papers/UBICOMP2016iBeacon.pdf
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
class BluetoothDeviceProfile{
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

  BluetoothDeviceProfile(this.uuid,  this.rssi,  this.deviceType, this.timeStamps,  this.continuousDuration, this.measuredPower);

}

