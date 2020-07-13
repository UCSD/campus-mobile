import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class BluetoothSingleton{
  static final BluetoothSingleton _bluetoothSingleton =  BluetoothSingleton._internal();
  FlutterBlue flutterBlueInstance = FlutterBlue.instance;
  final _storage = FlutterSecureStorage();
  int scanDuration = 2; //Seconds
  Timer ongoingScanner;

  //flutterBlueInstance.scan(timeout: Duration(seconds: scanDuration), allowDuplicates: false)
  factory BluetoothSingleton(){
   // bluetoothStream();
  return _bluetoothSingleton;
  }


  init() {
    //flutterBlueInstance.scan( allowDuplicates: false);
   enableListener();
  }



  enableListener() {
    startScan();
    ongoingScanner = new Timer.periodic(Duration(seconds: scanDuration * 5),  (Timer t) => startScan());
  }git

  startScan(){
     flutterBlueInstance.startScan( timeout: Duration(seconds: 2), allowDuplicates: false);
     flutterBlueInstance.scanResults.listen((results) {
      for(ScanResult scanResult in results){
        final String value = scanResult.device.id.toString();
        print('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
            "\n");


      }
    });

    flutterBlueInstance.stopScan();
}


  pauseScan(){
    ongoingScanner.cancel();
  }

  resumeScan(int scanTime){
   ongoingScanner.cancel();
   flutterBlueInstance.stopScan();
   startNewScan(scanTime);
   ongoingScanner = new Timer.periodic(Duration(seconds:scanTime ), (Timer t) => startNewScan(scanTime));

  }

  startNewScan(int scanTime){
    flutterBlueInstance.startScan( timeout: Duration(seconds: scanTime), allowDuplicates: false);
    flutterBlueInstance.scanResults.listen((results) {
      for(ScanResult scanResult in results){
        final String value = scanResult.device.id.toString();
        print('ID: ${scanResult.device.id}' +
            "\nDevice name: " +
            (scanResult.device.name != "" ? scanResult.device.name : "Unknown") +
            "\n");


      }
    });
    flutterBlueInstance.stopScan();
  }

  BluetoothSingleton._internal();

}
