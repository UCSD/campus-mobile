import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:location/location.dart';
class BluetoothSingleton{
  static final BluetoothSingleton _bluetoothSingleton =  BluetoothSingleton._internal();
  FlutterBlue flutterBlueInstance = FlutterBlue.instance;
  final _storage = FlutterSecureStorage();
  int scanDuration = 2; //Seconds
  int enable = 0;
  Timer ongoingScanner;
  List loggedItems = [];
  static List bufferList = [];

  //initialize location and permissions to be checked
  Location location = Location();
  //Location
  LocationData _currentLocation;

  //flutterBlueInstance.scan(timeout: Duration(seconds: scanDuration), allowDuplicates: false)
  factory BluetoothSingleton(){
   // bluetoothStream();
  return _bluetoothSingleton;
  }


  init() {
    location.changeSettings(accuracy: LocationAccuracy.low, distanceFilter: 200.0);
    _logLocation();
    //flutterBlueInstance.scan( allowDuplicates: false);
   enableListener();
  }



  enableListener() {
    startScan();
    ongoingScanner = new Timer.periodic(Duration(seconds: 15),  (Timer t) => startScan());
  }

  startScan(){
     flutterBlueInstance.startScan( timeout: Duration(seconds: 2), allowDuplicates: false);
     flutterBlueInstance.scanResults.listen((results) {
      for(ScanResult scanResult in results){
        //PARSE FOR DISPLAY
        if (!bufferList.contains('ID: ${scanResult.device.id}' +
       "\nDevice name: " +
       (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
       "\n")) {
       bufferList.add('ID: ${scanResult.device.id}' +
       "\nDevice name: " +
       (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
       "\n");
       }
        print('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
            "\n");
      }
    });
     loggedItems.insertAll(loggedItems.length , bufferList);
     if(bufferList.length > 2){
       _logLocation();
     }
     // Add time stamp
     loggedItems.add("TIMESTAMP: "+
         DateTime.fromMillisecondsSinceEpoch(
             DateTime.now().millisecondsSinceEpoch)
             .toString() +
         '\n');

    flutterBlueInstance.stopScan();
     bufferList.clear();
}


  pauseScan(){
    ongoingScanner.cancel();
    flutterBlueInstance.stopScan();
  }

  resumeScan(int scanTime){
   ongoingScanner.cancel();
   flutterBlueInstance.stopScan();
  startNewScan(scanTime);
   ongoingScanner = new Timer.periodic(Duration(seconds:15), (Timer t) => startNewScan(scanTime));

  }

  startNewScan(int scanTime){
    flutterBlueInstance.startScan( timeout: Duration(seconds: scanTime), allowDuplicates: false);
    bufferList.clear();
    flutterBlueInstance.scanResults.listen((results) {
      for(ScanResult scanResult in results){
        print('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
            "\n");
        //PARSE FOR DISPLAY
        if (!bufferList.contains('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
            "\n")) {
          bufferList.add('ID: ${scanResult.device.id}' +
              "\nDevice name: " +
              (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
              "\n");
        }
      }
    });
   // loggedItems.addAll(bufferList);
    loggedItems.addAll(bufferList);
    if(bufferList.length > 2){
      _logLocation();
    }
    // Add time stamp
    loggedItems.add("TIMESTAMP: "+
        DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch)
            .toString() +
        '\n');

    flutterBlueInstance.stopScan();
    bufferList.clear();
  }


  void _logLocation() async {
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

    if(enable < 1){
      enableLocationListening();
    }
    //once permissions are verified, get location asynchronously
    _currentLocation = await location.getLocation();


    // Add location logging to rendered list
    loggedItems.add(
        " LATITUDE: " +
            _currentLocation.latitude.toString() +
            " LONGITUDE: " +
            _currentLocation.longitude.toString() +
            "\n");

  }

  BluetoothSingleton._internal();

  void enableLocationListening() {
    location.onLocationChanged.listen((event) {
      if(event.heading > 200){
        flutterBlueInstance.stopScan();
        ongoingScanner.cancel();
        pauseScan();
        resumeScan(2);
        enable++;
      }


    });
  }

}
