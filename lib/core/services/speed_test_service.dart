import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:wifi_connection/WifiConnection.dart';
import 'package:wifi_connection/WifiInfo.dart';

class SpeedTestService extends ChangeNotifier {
  SpeedTestService() {
    _networkHelper = Dio();
    _timer = Stopwatch();
    _speedDownload = 0.0;
    _speedUpload = 0.0;
    _percentDownloaded = 0.00;
    _percentUploaded = 0.00;
  }

  Dio _networkHelper;
  Stopwatch _timer;
  double _speedDownload;
  double _speedUpload;
  double _percentDownloaded;
  double _percentUploaded;
  CancelToken _cancelTokenDownload;
  CancelToken _cancelTokenUpload;
  bool _speedTestDone = false;
  int _secondsElapsedDownload = 0;
  int _secondsElapsedUpload = 0;
  bool isUCSDWiFi = true;

  String url =
      'https://ucsd-its-wts-dev.s3-us-west-1.amazonaws.com/Services/WifiAnalyzer/webpage_25MB.html';

  String signedUrlAPI = "https://sb5m4z541f.execute-api.us-west-2.amazonaws.com/qa/%7Bwifitest+%7D";
String signedURL;
  void speedTest() async {
    resetSpeedTest();

    await downloadSpeedTest();
    await new Dio().get("https://sb5m4z541f.execute-api.us-west-2.amazonaws.com/qa/%7Bwifitest+%7D?name=temp.html").then((value) {
      signedURL = value.data.toString().substring(13, value.data.toString().length - 1);
    }
    );
    await uploadSpeedTest();
    if (_percentUploaded == 1.0 && _percentDownloaded == 1.0) {
      _speedTestDone = true;
      notifyListeners();
    }
  }

  Future uploadSpeedTest() async {

    String path = (await getApplicationDocumentsDirectory()).path;
    //create file


    var tempDownload = File(path + "/temp.html").readAsBytesSync();

    FormData formData = new FormData.fromMap({
      "file": MultipartFile.fromBytes(tempDownload, filename: "temp.html")
    });

    notifyListeners();
    try {
      _cancelTokenDownload = new CancelToken();
      _timer.start();
      await _networkHelper.put(signedURL, data: formData, onSendProgress:  _progressCallbackUpload, cancelToken:  _cancelTokenDownload);
    } catch (e) {
    }
    _timer.stop();
    notifyListeners();
  }

  Future downloadSpeedTest() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    //create file
    File tempDownload = File(path + "/temp.html");
    // _timer.start();
    notifyListeners();
    try {
      _cancelTokenUpload = new CancelToken();
      _timer.start();
      await _networkHelper.download(url, (tempDownload.path),
          onReceiveProgress: _progressCallbackDownload,
          cancelToken: _cancelTokenUpload);
    } catch (e) {
    }
    _timer.stop();
    notifyListeners();
  }

  _progressCallbackDownload(int bytesDownloaded, int totalBytes) {
    _secondsElapsedDownload = _timer.elapsed.inSeconds;
    double speedInBytes = (bytesDownloaded / _timer.elapsed.inSeconds);
    _speedDownload = _convertToMbps(speedInBytes);

    _percentDownloaded = bytesDownloaded / totalBytes;

    notifyListeners();
  }

  _progressCallbackUpload(int bytesDownloaded, int totalBytes) {
    _secondsElapsedUpload = _timer.elapsed.inSeconds;
    double speedInBytes = (bytesDownloaded / _timer.elapsed.inSeconds);
    _speedUpload = _convertToMbps(speedInBytes);
    _percentUploaded = bytesDownloaded / totalBytes;
    notifyListeners();
  }

  double _convertToMbps(double speed) {
    return speed / 125000;
  }

  void resetSpeedTest() {
    _speedTestDone = false;
    _secondsElapsedUpload = 0;
    _secondsElapsedDownload = 0;
    _timer.reset();
    _percentDownloaded = 0.0;
    _percentUploaded = 0.0;
    _speedDownload = 0.00;
    _speedUpload = 0.0;
  }

  void cancelDownload() {
    try {
      if (_timer.isRunning) {
        _timer.stop();
        _cancelTokenDownload.cancel("cancelled");
      }
    } catch (e) {
    }
  }
  void cancelUpload() {
    try {
      if (_timer.isRunning) {
        _timer.stop();
        _cancelTokenUpload.cancel("cancelled");
      }
    } catch (e) {
    }
  }

  double get speed => _speedDownload;
  set speed(double lastSpeed) => _speedDownload = lastSpeed;
  double get uploadSpeed => _speedUpload;
  Stopwatch get timer => _timer;
  double get percentDownloaded => _percentDownloaded;
  double get percentUploaded => _percentUploaded;
  bool get speedTestDone => _speedTestDone;
  int get timeElapsedDownload => _secondsElapsedDownload;
  int get timeElapsedUpload => _secondsElapsedUpload;
  bool get isUCSDNetwork => isUCSDWiFi;
  void connectedToUCSDwifi() async{
   WifiInfo wiFiInfo = await WifiConnection.wifiInfo;
   bool lastState = isUCSDWiFi;
   if(wiFiInfo.ssid.contains("UCSD-PROTECTED") || wiFiInfo.ssid.contains("UCSD-GUEST") ||  wiFiInfo.ssid.contains("ResNet")){
     isUCSDWiFi = true;
   }else{
     isUCSDWiFi = false;
   }
   if(lastState != isUCSDWiFi) {
     notifyListeners();
   }
   }
  // Send WiFi data
  Future<bool> sendNetworkDiagnostics(int lastSpeed) async {
    Map wiFiLog;
    bool sentSuccessfully = false;

    List<Object> locationWifiConnectivity = await futureCombo();
    if (locationWifiConnectivity[2] == ConnectivityResult.wifi) {
      if (Platform.isAndroid) {
        wiFiLog = {
          "Platform": "Android",
          "SSID": (locationWifiConnectivity[0] as WifiInfo).ssid,
          "BSSID": (locationWifiConnectivity[0] as WifiInfo).bssId,
          "IPAddress": (locationWifiConnectivity[0] as WifiInfo).ipAddress,
          "MacAddress": (locationWifiConnectivity[0] as WifiInfo).macAddress,
          "LinkSpeed": (locationWifiConnectivity[0] as WifiInfo).linkSpeed,
          "SignalStrength":
          (locationWifiConnectivity[0] as WifiInfo).signalStrength,
          "Frequency": (locationWifiConnectivity[0] as WifiInfo).frequency,
          "NetworkID": (locationWifiConnectivity[0] as WifiInfo).networkId,
          "IsHiddenSSID":
          (locationWifiConnectivity[0] as WifiInfo).isHiddenSSid,
          "RouterIP": (locationWifiConnectivity[0] as WifiInfo).routerIp,
          "Channel": (locationWifiConnectivity[0] as WifiInfo).channel,
          "Latitude":
          (locationWifiConnectivity[1] as LocationData).latitude as Double,
          "Longitude":
          (locationWifiConnectivity[1] as LocationData).longitude as Double,
          "TimeStamp": DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch)
              .toString(),
          "DownloadSpeed": lastSpeed != null
              ? lastSpeed.toStringAsPrecision(3)
              : speed.toStringAsPrecision(3),
          "UploadSpeed": uploadSpeed.toStringAsPrecision(3),
        };
      } else {
        print(  uploadSpeed.toStringAsPrecision(3) );
      wiFiLog = {
          "Platform": "iOS",
          "SSID": (locationWifiConnectivity[0] as WifiInfo).ssid,
          "BSSID": (locationWifiConnectivity[0] as WifiInfo).bssId,
          "IPAddress": (locationWifiConnectivity[0] as WifiInfo).ipAddress,
          "MacAddress": (locationWifiConnectivity[0] as WifiInfo).macAddress,
          "LinkSpeed": "",
          "SignalStrength": "",
          "Frequency": "",
          "NetworkID": "",
          "IsHiddenSSID": "",
          "RouterIP": "",
          "Channel": "",
          "Latitude":
          (locationWifiConnectivity[1] as LocationData).latitude ,
          "Longitude":
          (locationWifiConnectivity[1] as LocationData).longitude ,
          "TimeStamp": DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch)
              .toString(),
          "DownloadSpeed": lastSpeed != null
              ? lastSpeed.toStringAsPrecision(3)
              : speed.toStringAsPrecision(3),
          "UploadSpeed": uploadSpeed.toStringAsPrecision(3),
        };
      print(json.encode(wiFiLog));
      }
      //TODO: Send data for submission
      sentSuccessfully = true;


    }

    return sentSuccessfully; //Due to failed submission or not connected to wifi
  }

  Future<List<Object>> futureCombo() async {
    if (await (Connectivity().checkConnectivity()) != ConnectivityResult.wifi) {
      return [null, null, await (Connectivity().checkConnectivity())];
    }

    var location = Location();
    location.changeSettings(accuracy: LocationAccuracy.low);

    LocationData position;
    return [
      await WifiConnection.wifiInfo,
      await location.getLocation(),
      await (Connectivity().checkConnectivity())
    ];
  }
}
