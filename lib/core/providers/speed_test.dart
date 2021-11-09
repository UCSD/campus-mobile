import 'dart:convert';
import 'dart:io';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/speed_test.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/speed_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class SpeedTestProvider extends ChangeNotifier {
  bool? _onSimulator;
  bool? _isLoading;
  late Coordinates _coordinates;
  String? _error;
  NetworkHelper _networkHelper = new NetworkHelper();
  Dio dio = new Dio();
  Stopwatch _timer = new Stopwatch();
  double? _speedDownload;
  double? _speedUpload;
  double _percentDownloaded = 0.0;
  double _percentUploaded = 0.0;
  CancelToken? _cancelTokenDownload;
  CancelToken? _cancelTokenUpload;
  bool _speedTestDone = false;
  int _secondsElapsedDownload = 0;
  int _secondsElapsedUpload = 0;
  late SpeedTestService _speedTestService;
  SpeedTestModel? _speedTestModel;
  bool? isUCSDWiFi = false;
  Map? wiFiLog;
  late UserDataProvider _userDataProvider;
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  Map<String, String>? offloadDataHeader;
  final String mobileLoggerApi =
      'https://api-qa.ucsd.edu:8243/mobileapplogger/v1.1.0/log';

  SpeedTestProvider() {
    _isLoading = false;
    init();
  }

  ///This setter is only used in provider to supply an updated Coordinates object
  set coordinates(Coordinates value) {
    _coordinates = value;
  }

  set userDataProvider(UserDataProvider userDataProvider) {
    _userDataProvider = userDataProvider;
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _speedTestService = SpeedTestService();
    if (await _speedTestService.checkSimulation()) {
      _onSimulator = true;
      notifyListeners();
      return;
    } else {
      _onSimulator = false;
    }
    // _isLoading = true;
    await _speedTestService.fetchSignedUrls();
    _isLoading = false;
    notifyListeners();
    _speedTestModel = _speedTestService.speedTestModel;
    connectedToUCSDWifi();
    resetSpeedTest();
  }

  void connectedToUCSDWifi() async {
    isUCSDWiFi = _speedTestModel!.isUCSDWifi;
    notifyListeners();
  }

  Future<void> speedTest() async {
    init();
    resetSpeedTest();
    downloadSpeedTest().then((value) {
      _timer.reset();
      uploadSpeedTest().then((value) {
        if (_percentUploaded == 1.0 && _percentDownloaded == 1.0) {
          _speedTestDone = true;
          notifyListeners();
        }
      });
    });
  }

  Future uploadSpeedTest() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    File temp = File(path + "/temp.html");

    // if not on UCSD wifi OR the file above does not exist,
    // we should not upload the speed test results
    // instead, stop the timer and exit the function
    if (isUCSDWiFi != true || !temp.existsSync()) {
      _timer.stop();
      notifyListeners();
      return;
    }

    var tempDownload = temp.readAsBytesSync();

    FormData formData = new FormData.fromMap(
        {"file": MultipartFile.fromBytes(tempDownload, filename: "temp.html")});
    notifyListeners();
    try {
      _cancelTokenUpload = new CancelToken();
      _timer.start();
      await dio.put(_speedTestModel!.uploadUrl!,
          data: formData,
          onSendProgress: _progressCallbackUpload,
          cancelToken: _cancelTokenUpload);
    } catch (e) {
      print(e);
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
      _cancelTokenDownload = new CancelToken();
      _timer.start();
      await dio.download(_speedTestModel!.downloadUrl!, (tempDownload.path),
          onReceiveProgress: _progressCallbackDownload,
          cancelToken: _cancelTokenDownload);
    } catch (e) {
      print(e);
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
    notifyListeners();
  }

  void cancelDownload() {
    _cancelTokenDownload!.cancel("cancelled");
    try {
      if (_timer.isRunning) {
        _timer.stop();
        _cancelTokenDownload!.cancel("cancelled");
      }
    } catch (e) {}
  }

  void cancelUpload() {
    _cancelTokenUpload!.cancel("cancelled");
    try {
      if (_timer.isRunning) {
        _timer.stop();
        _cancelTokenUpload!.cancel("cancelled");
      }
    } catch (e) {}
  }

  Future<bool> sendNetworkDiagnostics(int? lastSpeed) async {
    bool sentSuccessfully = false;

    wiFiLog = {
      "Platform": _speedTestModel!.platform,
      "SSID": _speedTestModel!.ssid,
      "BSSID": _speedTestModel!.bssid,
      "IPAddress": _speedTestModel!.ipAddress,
      "MacAddress": _speedTestModel!.macAddress,
      "LinkSpeed": _speedTestModel!.linkSpeed,
      "SignalStrength": _speedTestModel!.signalStrength,
      "Frequency": _speedTestModel!.frequency,
      "NetworkID": _speedTestModel!.networkID,
      "IsHiddenSSID": _speedTestModel!.isHiddenSSID,
      "RouterIP": _speedTestModel!.routerIP,
      "Channel": _speedTestModel!.channel,
      "Latitude": _coordinates.lat.toString(),
      "Longitude": _coordinates.lon.toString(),
      "TimeStamp": _speedTestModel!.timeStamp,
      "DownloadSpeed": lastSpeed != null
          ? lastSpeed.toStringAsPrecision(3)
          : _speedDownload!.toStringAsPrecision(3),
      "UploadSpeed": _speedUpload!.toStringAsPrecision(3),
    };

    sentSuccessfully = true;
    sendLogs(wiFiLog);
    return sentSuccessfully; //Due to failed submission or not connected to wifi
  }

  Future<void> sendLogs(Map? log) async {
    final mobileLoggerApiWifi = mobileLoggerApi + "?type=WIFI";

    offloadDataHeader = {
      'Authorization':
          'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
    };
    if (_userDataProvider.isLoggedIn) {
      if (offloadDataHeader == null) {
        offloadDataHeader = {
          'Authorization':
              'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
        };
      }
      // Send to offload API
      try {
        _networkHelper
            .authorizedPost(
                mobileLoggerApiWifi, offloadDataHeader, json.encode(log))
            .then((value) {
          return value;
        });
      } catch (Exception) {
        if (Exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          _userDataProvider.silentLogin();
          offloadDataHeader = {
            'Authorization':
                'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
          };
          _networkHelper.authorizedPost(
              mobileLoggerApiWifi, offloadDataHeader, json.encode(log));
        }
      }
    } else {
      try {
        getNewToken().then((value) {
          _networkHelper.authorizedPost(
              mobileLoggerApiWifi, headers, json.encode(log));
        });
      } catch (Exception) {
        getNewToken().then((value) {
          _networkHelper.authorizedPost(
              mobileLoggerApiWifi, headers, json.encode(log));
        });
      }
    }
  }

  Future<void> reportIssue() async {
    final mobileLoggerApiWifiReport = mobileLoggerApi + "?type=WIFIREPORT";

    offloadDataHeader = {
      'Authorization':
          'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
    };
    wiFiLog = {
      "userId": (_userDataProvider.userProfileModel!.pid) == null
          ? ""
          : _userDataProvider.userProfileModel!.pid,
      "userLogin": (_userDataProvider.userProfileModel!.username) == null
          ? ""
          : _userDataProvider.userProfileModel!.username!,
      "Platform": _speedTestModel!.platform,
      "SSID": _speedTestModel!.ssid,
      "BSSID": _speedTestModel!.bssid,
      "IPAddress": _speedTestModel!.ipAddress,
      "MacAddress": _speedTestModel!.macAddress,
      "LinkSpeed": _speedTestModel!.linkSpeed,
      "SignalStrength": _speedTestModel!.signalStrength,
      "Frequency": _speedTestModel!.frequency,
      "NetworkID": _speedTestModel!.networkID,
      "IsHiddenSSID": _speedTestModel!.isHiddenSSID,
      "RouterIP": _speedTestModel!.routerIP,
      "Channel": _speedTestModel!.channel,
      "Latitude": _coordinates.lat.toString(),
      "Longitude": _coordinates.lon.toString(),
      "TimeStamp": _speedTestModel!.timeStamp,
      "DownloadSpeed": wiFiLog!['DownloadSpeed'],
      "UploadSpeed": _speedUpload!.toStringAsPrecision(3),
    };
    if (_userDataProvider.isLoggedIn) {
      if (offloadDataHeader == null) {
        offloadDataHeader = {
          'Authorization':
              'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
        };
      }
      // Send to offload API
      try {
        _networkHelper.authorizedPost(
            mobileLoggerApiWifiReport, offloadDataHeader, json.encode(wiFiLog));
      } catch (Exception) {
        if (Exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          _userDataProvider.silentLogin();
          offloadDataHeader = {
            'Authorization':
                'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
          };
          _networkHelper.authorizedPost(mobileLoggerApiWifiReport,
              offloadDataHeader, json.encode(wiFiLog));
        }
      }
    } else {
      try {
        getNewToken().then((value) {
          _networkHelper.authorizedPost(
              mobileLoggerApiWifiReport, headers, json.encode(wiFiLog));
        });
      } catch (Exception) {
        getNewToken().then((value) {
          _networkHelper.authorizedPost(
              mobileLoggerApiWifiReport, headers, json.encode(wiFiLog));
        });
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
      return _networkHelper
          .authorizedPost(
              tokenEndpoint, tokenHeaders, "grant_type=client_credentials")
          .then((response) {
        headers["Authorization"] = "Bearer " + response["access_token"];
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  bool? get isLoading => _isLoading;
  String? get error => _error;
  double? get speed => _speedDownload;
  set speed(double? lastSpeed) => _speedDownload = lastSpeed;
  double? get uploadSpeed => _speedUpload;
  Stopwatch get timer => _timer;
  double get percentDownloaded => _percentDownloaded;
  double get percentUploaded => _percentUploaded;
  bool get speedTestDone => _speedTestDone;
  int get timeElapsedDownload => _secondsElapsedDownload;
  int get timeElapsedUpload => _secondsElapsedUpload;
  bool? get isUCSDNetwork => isUCSDWiFi;
  bool? get onSimulator => _onSimulator;
}
