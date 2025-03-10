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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class SpeedTestProvider extends ChangeNotifier {
  SpeedTestProvider() {
    /// TODO: probably a bug! Async functions should not be be run in the constructor
    init();
  }

  /// STATES
  var _isLoading = false;
  var _speedTestDone = false;
  bool? _onSimulator;
  bool? isUCSDWiFi = false;
  double _percentDownloaded = 0.0;
  double _percentUploaded = 0.0;
  double? _speedDownload;
  double? _speedUpload;
  int _secondsElapsedDownload = 0;
  int _secondsElapsedUpload = 0;
  String? _error;
  CancelToken? _cancelTokenDownload;
  CancelToken? _cancelTokenUpload;
  Map? wiFiLog;
  Map<String, String>? offloadDataHeader;
  late Coordinates _coordinates;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  /// MODELS
  SpeedTestModel? _speedTestModel;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  late SpeedTestService _speedTestService;
  static const _networkHelper = NetworkHelper();
  static final dio = Dio();
  final _timer = new Stopwatch();
  static late final mobileLoggerApi = dotenv.get('MOBILE_APP_LOGGER');

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
    await downloadSpeedTest();
    _timer.reset;
    await uploadSpeedTest();
    if (_percentUploaded == 1.0 && _percentDownloaded == 1.0) {
      _speedTestDone = true;
      notifyListeners();
    }
  }

  Future<void> uploadSpeedTest() async {
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      final temp = File(path + "/temp.html");

      // if the file above does not exist, cancel the upload speed test
      if (/*isUCSDWiFi != true || */!temp.existsSync())
        return;

      final tempDownload = temp.readAsBytesSync();
      final formData = FormData.fromMap(
          {"file": MultipartFile.fromBytes(tempDownload, filename: "temp.html")});
      notifyListeners();
      _cancelTokenUpload = CancelToken();
      _timer.start();
      await dio.put(_speedTestModel!.uploadUrl!,
          data: formData,
          onSendProgress: _progressCallbackUpload,
          cancelToken: _cancelTokenUpload);
    } catch (e) {
      print(e);
    } finally {
      _timer.stop();
      notifyListeners();
    }
  }

  Future downloadSpeedTest() async {
    var path = (await getApplicationDocumentsDirectory()).path;
    var tempDownload = File(path + "/temp.html");
    notifyListeners();
    try {
      _cancelTokenDownload = new CancelToken();
      _timer.start();
      await dio.download(_speedTestModel!.downloadUrl!, (tempDownload.path),
          onReceiveProgress: _progressCallbackDownload,
          cancelToken: _cancelTokenDownload);
    } catch (e) {
      print(e);
    } finally {
      _timer.stop();
      notifyListeners();
    }
  }

  void _progressCallbackDownload(int bytesDownloaded, int totalBytes) {
    _secondsElapsedDownload = _timer.elapsed.inSeconds;
    double speedInBytes = (bytesDownloaded / _timer.elapsed.inSeconds);
    _speedDownload = _convertToMbps(speedInBytes);
    _percentDownloaded = bytesDownloaded / totalBytes;
    notifyListeners();
  }

  void _progressCallbackUpload(int bytesDownloaded, int totalBytes) {
    _secondsElapsedUpload = _timer.elapsed.inSeconds;
    double speedInBytes = (bytesDownloaded / _timer.elapsed.inSeconds);
    _speedUpload = _convertToMbps(speedInBytes);
    _percentUploaded = bytesDownloaded / totalBytes;
    notifyListeners();
  }

  void resetSpeedTest() {
    _speedTestDone = false;
    _secondsElapsedUpload = _secondsElapsedDownload = 0;
    _timer.reset();
    _percentDownloaded = _percentUploaded = 0.0;
    _speedDownload = _speedUpload = 0.0;
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
    var sentSuccessfully = false;
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
          'Bearer ${_userDataProvider.authenticationModel.accessToken}'
    };

    if (_userDataProvider.isLoggedIn) {
      if (offloadDataHeader == null) {
        offloadDataHeader = {
          'Authorization':
              'Bearer ${_userDataProvider.authenticationModel.accessToken}'
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
      } catch (exception) {
        if (exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          _userDataProvider.silentLogin();
          offloadDataHeader = {
            'Authorization':
                'Bearer ${_userDataProvider.authenticationModel.accessToken}'
          };
          _networkHelper.authorizedPost(
              mobileLoggerApiWifi, offloadDataHeader, json.encode(log));
        }
      }
    } else {
      try {
        _networkHelper.getNewToken(headers).then((value) {
          _networkHelper.authorizedPost(
              mobileLoggerApiWifi, headers, json.encode(log));
        });
      } catch (exception) {
        _networkHelper.getNewToken(headers).then((value) {
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
          'Bearer ${_userDataProvider.authenticationModel.accessToken}'
    };
    wiFiLog = {
      "userId": (_userDataProvider.userProfileModel.pid) == null
          ? ""
          : _userDataProvider.userProfileModel.pid,
      "userLogin": (_userDataProvider.userProfileModel.username) == null
          ? ""
          : _userDataProvider.userProfileModel.username!,
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
              'Bearer ${_userDataProvider.authenticationModel.accessToken}'
        };
      }
      // Send to offload API
      try {
        _networkHelper.authorizedPost(
            mobileLoggerApiWifiReport, offloadDataHeader, json.encode(wiFiLog));
      } catch (exception) {
        if (exception.toString().contains(ErrorConstants.invalidBearerToken)) {
          _userDataProvider.silentLogin();
          offloadDataHeader = {
            'Authorization':
                'Bearer ${_userDataProvider.authenticationModel.accessToken}'
          };
          _networkHelper.authorizedPost(mobileLoggerApiWifiReport,
              offloadDataHeader, json.encode(wiFiLog));
        }
      }
    } else {
      try {
        _networkHelper.getNewToken(headers).then((value) {
          _networkHelper.authorizedPost(
              mobileLoggerApiWifiReport, headers, json.encode(wiFiLog));
        });
      } catch (exception) {
        _networkHelper.getNewToken(headers).then((value) {
          _networkHelper.authorizedPost(
              mobileLoggerApiWifiReport, headers, json.encode(wiFiLog));
        });
      }
    }
  }

  /// SIMPLE SETTERS
  /// This setter is only used in provider to supply an updated Coordinates object
  set coordinates(Coordinates value) => _coordinates = value;
  set userDataProvider(UserDataProvider userDataProvider) => _userDataProvider = userDataProvider;
  set speed(double? lastSpeed) => _speedDownload = lastSpeed;
  static double _convertToMbps(double speed) => speed / 125000;

  /// SIMPLE GETTERS
  bool get isLoading => _isLoading;
  bool? get isUCSDNetwork => isUCSDWiFi;
  bool? get onSimulator => _onSimulator;
  bool get speedTestDone => _speedTestDone;
  String? get error => _error;
  int get timeElapsedDownload => _secondsElapsedDownload;
  int get timeElapsedUpload => _secondsElapsedUpload;
  double get percentDownloaded => _percentDownloaded;
  double get percentUploaded => _percentUploaded;
  double? get speed => _speedDownload;
  double? get uploadSpeed => _speedUpload;
  Stopwatch get timer => _timer;
}
