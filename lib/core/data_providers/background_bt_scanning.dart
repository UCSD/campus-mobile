import 'dart:ui';

import 'package:campus_mobile_experimental/core/data_providers/bluetooth_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

abstract class BackgroundBTScanning{
  static const MethodChannel _channel = const MethodChannel('ucsd.mobile.app');

  static Future<bool> initialize() async{
    //final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel.invokeMethod('BackgroundBtScanning.initializeService', <dynamic>[callback.toRawHandle()]);
  }

  static Future<bool> registerBTScan(
      BluetoothSingleton bluetoothInstance,
      ){

  }

  void callbackDispatcher(){
    const MethodChannel _backgroundChannel = MethodChannel('ucsd.mobile.app/bluetooth_scanning_background');

    WidgetsFlutterBinding.ensureInitialized();

    _backgroundChannel.setMethodCallHandler((MethodCall call) async{

    });
  }
}