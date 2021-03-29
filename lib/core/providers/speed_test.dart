import 'dart:convert';
import 'dart:io';

import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/speed_test.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/speed_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import '../../app_constants.dart';
import '../../app_networking.dart';

class SpeedTestProvider extends ChangeNotifier {
  bool _isLoading;
  bool _isUCSDWifi = true;
  Coordinates _coordinates;
  String _error;
  NetworkHelper _networkHelper;
  Dio dio;
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
  SpeedTestService _speedTestService;
  SpeedTestModel _speedTestModel;
  bool isUCSDWiFi = true;
  UserDataProvider _userDataProvider;
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  Map<String, String> offloadDataHeader;
  static const String mobileLoggerApi = 'https://api-qa.ucsd.edu:8243/mobileapplogger/v1.1.0/log?type=wifi';


  SpeedTestProvider() {
    _isLoading = false;
    _speedTestService = SpeedTestService();
    init();
  }

  ///This setter is only used in provider to supply an updated Coordinates object
  set coordinates(Coordinates value) {
    _coordinates = value;
  }

  set userDataProvider(UserDataProvider userDataProvider){
    _userDataProvider = userDataProvider;
  }

  void init() async {
    _isLoading = true;
    await _speedTestService.fetchSignedUrls();
    _isLoading = false;
    _speedTestModel = _speedTestService.speedTestModel;
  }

  void connectedToUCSDWifi() async {
    bool lastState = isUCSDWiFi;
    print("UCSD wifi is connected: ${_speedTestModel.isUCSDWifi}");
    if (lastState != _speedTestModel.isUCSDWifi) {
      notifyListeners();
    }
  }

  void speedTest() async {
    resetSpeedTest();

    await downloadSpeedTest();
    await uploadSpeedTest();
    if (_percentUploaded == 1.0 && _percentDownloaded == 1.0) {
      _speedTestDone = true;
      notifyListeners();
    }
  }

  Future uploadSpeedTest() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    var tempDownload = File(path + "/temp.html").readAsBytesSync();

    FormData formData = new FormData.fromMap(
        {"file": MultipartFile.fromBytes(tempDownload, filename: "temp.html")});
    notifyListeners();
    try {
      _cancelTokenDownload = new CancelToken();
      _timer.start();
      await dio.put(_speedTestModel.uploadUrl,
          data: formData,
          onSendProgress: _progressCallbackUpload,
          cancelToken: _cancelTokenDownload);
    } catch (e) {}
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
      await dio.download(_speedTestModel.downloadUrl, (tempDownload.path),
          onReceiveProgress: _progressCallbackDownload,
          cancelToken: _cancelTokenUpload);
    } catch (e) {}
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

  Future<bool> sendNetworkDiagnostics(int lastSpeed) async {
    Map wiFiLog;
    bool sentSuccessfully = false;

        wiFiLog = {
          "Platform": _speedTestModel.platform,
          "SSID": _speedTestModel.ssid,
          "BSSID": _speedTestModel.bssid,
          "IPAddress": _speedTestModel.ipAddress,
          "MacAddress": _speedTestModel.macAddress,
          "LinkSpeed": _speedTestModel.linkSpeed,
          "SignalStrength": _speedTestModel.signalStrength,
          "Frequency": _speedTestModel.frequency,
          "NetworkID": _speedTestModel.networkID,
          "IsHiddenSSID":_speedTestModel.isHiddenSSID,
          "RouterIP": _speedTestModel.routerIP,
          "Channel":_speedTestModel.channel,
          "Latitude": _coordinates.lat,
          "Longitude": _coordinates.lon,
          "TimeStamp": _speedTestModel.timeStamp,
          "DownloadSpeed": lastSpeed != null
              ? lastSpeed.toStringAsPrecision(3)
              : _speedDownload.toStringAsPrecision(3),
          "UploadSpeed": _speedUpload.toStringAsPrecision(3),
        };

      //TODO: Send data for submission
      sentSuccessfully = true;
      sendLogs(wiFiLog);
    return sentSuccessfully; //Due to failed submission or not connected to wifi

}
  void sendLogs(Map log) {
    offloadDataHeader = {
      'Authorization':
      'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
    };
    if (_userDataProvider.isLoggedIn) {
      if (offloadDataHeader == null) {
        offloadDataHeader = {
          'Authorization':
          'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
        };
      }
      // Send to offload API
      try {
        var response = _networkHelper
            .authorizedPost(
            mobileLoggerApi, offloadDataHeader, json.encode(log))
            .then((value) {
        });
      } catch (Exception) {
        if (Exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          _userDataProvider.silentLogin();
          offloadDataHeader = {
            'Authorization':
            'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
          };
          _networkHelper.authorizedPost(
              mobileLoggerApi, offloadDataHeader, json.encode(log));
        }
      }
    } else {
      try {
        var response = _networkHelper.authorizedPost(
            mobileLoggerApi, headers, json.encode(log));
      } catch (Exception) {
        getNewToken();
        var response = _networkHelper.authorizedPost(
            mobileLoggerApi, headers, json.encode(log));
      }
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

  bool get isLoading => _isLoading;
  String get error => _error;
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
}
