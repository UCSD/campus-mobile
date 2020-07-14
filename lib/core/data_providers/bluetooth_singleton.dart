import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';

class BluetoothSingleton{
  
  // Internal Declaration
  static final BluetoothSingleton _bluetoothSingleton =  BluetoothSingleton._internal();
  
  //Flutter blue instance for scanning
  FlutterBlue flutterBlueInstance = FlutterBlue.instance;
  
  // Will add at the end, slows down scans
  final _storage = FlutterSecureStorage();
  
  // Constant for scans
  final int scanDuration = 2; //Seconds
  final waitTime = 15; // Seconds

  // Tracker to enable location listener
  int enable = 0;
  
  // Allows for continuous scan
  Timer ongoingScanner;
  
  // Lists for displaying scan results
  List loggedItems = [];
  static List bufferList = [];

  //initialize location and permissions to be checked
  Location location = Location();
  LocationData _currentLocation;

  //flutterBlueInstance.scan(timeout: Duration(seconds: scanDuration), allowDuplicates: false)
  factory BluetoothSingleton(){
   // bluetoothStream();
  return _bluetoothSingleton;
  }


  init() {
    
    // Set the minimum change to activate a new scan.
    location.changeSettings(accuracy: LocationAccuracy.low, distanceFilter: 200.0);
    
    // Enable location listening
    _logLocation();
    
    // Enable continuous scan 
   enableListener();
  }


  /// This function starts continuous scan (on app open)
  enableListener() {
    
    //Start the initial scan
    startScan();
    
    // Enable timer, must wait duration before next method execution
    ongoingScanner = new Timer.periodic(Duration(seconds: waitTime),  (Timer t) => startScan());
  }

  // Start a bluetooth scan of 2 second duration and listen to results
  startScan(){
     flutterBlueInstance.startScan( timeout: Duration(seconds: 2), allowDuplicates: false);

     // Process the scan results (synchronously)
     flutterBlueInstance.scanResults.listen((results) {
      for(ScanResult scanResult in results){

        //PARSE FOR FRONTEND DISPLAY
        if (!bufferList.contains('ID: ${scanResult.device.id}' +
       "\nDevice name: " +
       (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
       "\n")) {
       bufferList.add('ID: ${scanResult.device.id}' +
       "\nDevice name: " +
       (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
       "\n");
       }

        // Print to terminal for actual scan
        print('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
            "\n");
      }
    });

     // Add the processed buffer to overall log
     loggedItems.insertAll(loggedItems.length , bufferList);

     // If there are more than three devices, log location
     if(bufferList.length > 3){
       _logLocation();
     }


     // Add time stamp for differentiation
     loggedItems.add("TIMESTAMP: "+
         DateTime.fromMillisecondsSinceEpoch(
             DateTime.now().millisecondsSinceEpoch)
             .toString() +
         '\n');

     // Close on going scan in case it has not time out
    flutterBlueInstance.stopScan();

    // Clear previous scan results
     bufferList.clear();
}


// Cancel ongoing scans to start a new one
  pauseScan(){
    ongoingScanner.cancel();
    flutterBlueInstance.stopScan();
  }

  // Start a new scan with the given changes (For triggered scans or disposing a page)
  resumeScan(int scanTime){
    // Stop any ongoing scan
  pauseScan();

  // Set off an immediate scan
  startNewScan(scanTime);

  // Trigger a continuous scan
   ongoingScanner = new Timer.periodic(Duration(seconds: waitTime), (Timer t) => startNewScan(scanTime));

  }

  // Helper method to set up a modified scan (will be deleted for production)
  startNewScan(int scanTime){

    // Start scan with specified duration
    flutterBlueInstance.startScan( timeout: Duration(seconds: scanTime), allowDuplicates: false);

    // Process scan results
    flutterBlueInstance.scanResults.listen((results) {
      for(ScanResult scanResult in results){

        // Print to terminal ACTUAL scan result
        print('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
            "\n");


        //PARSE FOR FRONT END DISPLAY (avoids overwhelming data)
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

    // Add process scan results to scan log
    loggedItems.addAll(bufferList);

    // Add time stamp
    loggedItems.add("TIMESTAMP: "+
        DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch)
            .toString() +
        '\n');

    //If more than three devices are detected, log location
    if(bufferList.length > 2){
      _logLocation();
    }

    // Stop any scan not yet timed out
    flutterBlueInstance.stopScan();

    // Clear the previous scan results
    bufferList.clear();
  }


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

    // If this is our fist run, enable the location listener
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

  // Internal constructor
  BluetoothSingleton._internal();

  // Listens for location changes and ensures it is larger than 200 meters
  void enableLocationListening() {
    location.onLocationChanged.listen((event) {

      // 200 meter threshold
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
