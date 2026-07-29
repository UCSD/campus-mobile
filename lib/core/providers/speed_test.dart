import 'dart:async';
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

enum SpeedTestPhase { download, upload }

abstract class SpeedTestState {
  const SpeedTestState();
}

class SpeedTestIdle extends SpeedTestState {
  const SpeedTestIdle();
}

class SpeedTestInitializing extends SpeedTestState {
  const SpeedTestInitializing();
}

class SpeedTestUnavailable extends SpeedTestState {
  const SpeedTestUnavailable();
}

class SpeedTestSimulated extends SpeedTestState {
  const SpeedTestSimulated();
}

class SpeedTestRunning extends SpeedTestState {
  const SpeedTestRunning({
    required this.phase,
    required this.downloadProgress,
    required this.uploadProgress,
    required this.currentSpeedMbps,
    required this.secondsElapsed,
  });

  final SpeedTestPhase phase;
  final double downloadProgress;
  final double uploadProgress;
  final double currentSpeedMbps;
  final int secondsElapsed;

  double get overallProgress => ((downloadProgress + uploadProgress) / 2).clamp(0.0, 1.0);
}

class SpeedTestSuccess extends SpeedTestState {
  const SpeedTestSuccess({required this.downloadMbps, required this.uploadMbps});

  final double downloadMbps;
  final double uploadMbps;
}

class SpeedTestTimeout extends SpeedTestState {
  const SpeedTestTimeout({required this.downloadMbps, required this.uploadMbps, required this.downloadCompleted});

  final double downloadMbps;
  final double uploadMbps;
  final bool downloadCompleted;
}

class SpeedTestFailure extends SpeedTestState {
  const SpeedTestFailure(this.message);

  final String message;
}

class SpeedTestProvider extends ChangeNotifier {
  SpeedTestProvider({Dio? dio}) : dio = dio ?? Dio();

  static const int SPEED_TEST_TIMEOUT_SECONDS = 30;

  SpeedTestState _state = const SpeedTestIdle();
  bool _isLoading = false;
  bool _speedTestDone = false;
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
  Coordinates? _coordinates;
  UserDataProvider? _userDataProvider;
  SpeedTestModel? _speedTestModel;
  Future<void>? _initialization;
  int _operationId = 0;
  bool _disposed = false;

  final Map<String, String> headers = {"accept": "application/json"};
  final Dio dio;
  final Stopwatch _timer = Stopwatch();
  final String mobileLoggerApi = dotenv.get('MOBILE_APP_LOGGER');

  Future<void> init() {
    if (_disposed || _state is SpeedTestRunning) return Future.value();

    final currentInitialization = _initialization;
    if (currentInitialization != null) return currentInitialization;

    final initialization = _initialize();
    _initialization = initialization;
    return initialization.whenComplete(() {
      if (identical(_initialization, initialization)) _initialization = null;
    });
  }

  Future<void> _initialize() async {
    _isLoading = true;
    _error = null;
    _transition(const SpeedTestInitializing());

    final service = SpeedTestService();
    try {
      if (await service.checkSimulation()) {
        if (_disposed) return;
        _onSimulator = true;
        isUCSDWiFi = false;
        _isLoading = false;
        _transition(const SpeedTestSimulated());
        return;
      }

      _onSimulator = false;
      final urlsLoaded = await service.fetchSignedUrls();
      if (_disposed) return;

      _speedTestModel = service.speedTestModel;
      if (!urlsLoaded || _speedTestModel == null) {
        _isLoading = false;
        isUCSDWiFi = false;
        _error = service.error ?? 'Unable to load speed test configuration.';
        _transition(SpeedTestFailure(_error!));
        return;
      }

      isUCSDWiFi = _speedTestModel?.isUCSDWifi ?? false;
      _resetProgress();
      _isLoading = false;
      _transition(isUCSDWiFi == true ? const SpeedTestIdle() : const SpeedTestUnavailable());
    } catch (exception) {
      if (_disposed) return;
      _isLoading = false;
      isUCSDWiFi = false;
      _error = exception.toString();
      _transition(SpeedTestFailure(_error!));
    }
  }

  void connectedToUCSDWifi() {
    if (_disposed || _state is SpeedTestRunning) return;
    isUCSDWiFi = _speedTestModel?.isUCSDWifi ?? false;
    _transition(isUCSDWiFi == true ? const SpeedTestIdle() : const SpeedTestUnavailable());
  }

  Future<void> speedTest() => startSpeedTest();

  Future<void> startSpeedTest() async {
    final cannotStart = _disposed || _state is SpeedTestRunning || _state is SpeedTestInitializing;
    if (cannotStart) return;

    await init();
    final initializationDidNotReachIdle =
        _disposed || _state is SpeedTestSimulated || _state is SpeedTestUnavailable || _state is SpeedTestFailure;
    if (initializationDidNotReachIdle) return;

    final model = _speedTestModel;
    final configurationIsUnavailable = model?.downloadUrl == null || model?.uploadUrl == null || isUCSDWiFi != true;
    if (configurationIsUnavailable) {
      isUCSDWiFi = false;
      _transition(const SpeedTestUnavailable());
      return;
    }

    _resetProgress();
    final operationId = ++_operationId;
    _transition(_runningState(SpeedTestPhase.download));

    try {
      await _runSpeedTest(
        operationId,
      ).timeout(const Duration(seconds: SPEED_TEST_TIMEOUT_SECONDS), onTimeout: () => _handleTimeout(operationId));
    } catch (exception) {
      _failOperation(operationId, exception);
    }
  }

  Future<void> _runSpeedTest(int operationId) async {
    await downloadSpeedTest(operationId: operationId);
    if (!_canContinue(operationId)) return;

    _timer.reset();
    _transition(_runningState(SpeedTestPhase.upload));
    await uploadSpeedTest(operationId: operationId);
    if (!_canContinue(operationId)) return;

    _speedTestDone = true;
    _transition(SpeedTestSuccess(downloadMbps: _speedDownload ?? 0.0, uploadMbps: _speedUpload ?? 0.0));
    unawaited(sendNetworkDiagnostics(null));
  }

  Future<void> downloadSpeedTest({int? operationId}) async {
    final activeOperationId = operationId ?? _operationId;

    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      if (!_isCurrentPhase(activeOperationId, SpeedTestPhase.download)) return;

      final tempDownload = File('$path/temp.html');
      _cancelTokenDownload = CancelToken();
      _timer
        ..reset()
        ..start();

      await dio.download(
        _speedTestModel!.downloadUrl!,
        tempDownload.path,
        onReceiveProgress: (bytesDownloaded, totalBytes) =>
            _progressCallbackDownload(activeOperationId, bytesDownloaded, totalBytes),
        cancelToken: _cancelTokenDownload,
      );

      if (!_isCurrentPhase(activeOperationId, SpeedTestPhase.download)) return;
      _secondsElapsedDownload = _timer.elapsed.inSeconds;
      _percentDownloaded = 1.0;
      _transition(_runningState(SpeedTestPhase.download));
    } on DioException catch (exception) {
      final isUnexpectedError = !CancelToken.isCancel(exception);
      if (isUnexpectedError) _failOperation(activeOperationId, exception);
    } catch (exception) {
      _failOperation(activeOperationId, exception);
    } finally {
      if (activeOperationId == _operationId) _timer.stop();
    }
  }

  Future<void> uploadSpeedTest({int? operationId}) async {
    final activeOperationId = operationId ?? _operationId;

    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      if (!_isCurrentPhase(activeOperationId, SpeedTestPhase.upload)) return;

      final temp = File('$path/temp.html');
      if (!temp.existsSync()) {
        _failOperation(activeOperationId, StateError('Speed test download file is unavailable.'));
        return;
      }

      final tempDownload = temp.readAsBytesSync();
      final formData = FormData.fromMap({"file": MultipartFile.fromBytes(tempDownload, filename: "temp.html")});

      _cancelTokenUpload = CancelToken();
      _timer
        ..reset()
        ..start();

      await dio.put(
        _speedTestModel!.uploadUrl!,
        data: formData,
        onSendProgress: (bytesUploaded, totalBytes) =>
            _progressCallbackUpload(activeOperationId, bytesUploaded, totalBytes),
        cancelToken: _cancelTokenUpload,
      );

      if (!_isCurrentPhase(activeOperationId, SpeedTestPhase.upload)) return;
      _secondsElapsedUpload = _timer.elapsed.inSeconds;
      _percentUploaded = 1.0;
      _transition(_runningState(SpeedTestPhase.upload));
    } on DioException catch (exception) {
      final isUnexpectedError = !CancelToken.isCancel(exception);
      if (isUnexpectedError) _failOperation(activeOperationId, exception);
    } catch (exception) {
      _failOperation(activeOperationId, exception);
    } finally {
      if (activeOperationId == _operationId) _timer.stop();
    }
  }

  void _progressCallbackDownload(int operationId, int bytesDownloaded, int totalBytes) {
    if (!_isCurrentPhase(operationId, SpeedTestPhase.download)) return;
    _secondsElapsedDownload = _timer.elapsed.inSeconds;
    _speedDownload = _safeMbps(bytesDownloaded);
    _percentDownloaded = _safeProgress(bytesDownloaded, totalBytes);
    _transition(_runningState(SpeedTestPhase.download));
  }

  void _progressCallbackUpload(int operationId, int bytesUploaded, int totalBytes) {
    if (!_isCurrentPhase(operationId, SpeedTestPhase.upload)) return;
    _secondsElapsedUpload = _timer.elapsed.inSeconds;
    _speedUpload = _safeMbps(bytesUploaded);
    _percentUploaded = _safeProgress(bytesUploaded, totalBytes);
    _transition(_runningState(SpeedTestPhase.upload));
  }

  void resetSpeedTest({bool notify = true}) {
    if (_state is SpeedTestRunning) return;
    _resetProgress();
    if (notify) _transition(isUCSDWiFi == true ? const SpeedTestIdle() : const SpeedTestUnavailable());
  }

  void _resetProgress() {
    _speedTestDone = false;
    _secondsElapsedUpload = 0;
    _secondsElapsedDownload = 0;
    _timer.reset();
    _percentDownloaded = 0.0;
    _percentUploaded = 0.0;
    _speedDownload = 0.0;
    _speedUpload = 0.0;
    _cancelTokenDownload = null;
    _cancelTokenUpload = null;
  }

  void cancelDownload() {
    final downloadCanBeCancelled = _cancelTokenDownload?.isCancelled == false;
    if (downloadCanBeCancelled) _cancelTokenDownload?.cancel("cancelled");
    if (_timer.isRunning) _timer.stop();
  }

  void cancelUpload() {
    final uploadCanBeCancelled = _cancelTokenUpload?.isCancelled == false;
    if (uploadCanBeCancelled) _cancelTokenUpload?.cancel("cancelled");
    if (_timer.isRunning) _timer.stop();
  }

  void cancelSpeedTest() {
    if (_state is! SpeedTestRunning) return;
    _operationId++;
    cancelDownload();
    cancelUpload();
    _resetProgress();
    _transition(isUCSDWiFi == true ? const SpeedTestIdle() : const SpeedTestUnavailable());
  }

  Future<bool> sendNetworkDiagnostics(int? lastSpeed) async {
    final model = _speedTestModel;
    if (model == null) return false;

    wiFiLog = {
      "Platform": model.platform,
      "SSID": model.ssid,
      "BSSID": model.bssid,
      "IPAddress": model.ipAddress,
      "MacAddress": model.macAddress,
      "LinkSpeed": model.linkSpeed,
      "SignalStrength": model.signalStrength,
      "Frequency": model.frequency,
      "NetworkID": model.networkID,
      "IsHiddenSSID": model.isHiddenSSID,
      "RouterIP": model.routerIP,
      "Channel": model.channel,
      "Latitude": _coordinates?.lat.toString() ?? "",
      "Longitude": _coordinates?.lon.toString() ?? "",
      "TimeStamp": model.timeStamp,
      "DownloadSpeed": _formatLogNumber(lastSpeed?.toDouble() ?? _speedDownload ?? 0.0),
      "UploadSpeed": _formatLogNumber(_speedUpload ?? 0.0),
    };

    await sendLogs(wiFiLog);
    return true;
  }

  Future<void> sendLogs(Map? log) async {
    if (log == null) return;
    await _sendLog('$mobileLoggerApi?type=WIFI', log);
  }

  Future<void> reportIssue() async {
    final model = _speedTestModel;
    final userDataProvider = _userDataProvider;
    if (model == null || userDataProvider == null) return;

    final report = {
      "userId": userDataProvider.userProfileModel.pid ?? "",
      "userLogin": userDataProvider.userProfileModel.username ?? "",
      "Platform": model.platform,
      "SSID": model.ssid,
      "BSSID": model.bssid,
      "IPAddress": model.ipAddress,
      "MacAddress": model.macAddress,
      "LinkSpeed": model.linkSpeed,
      "SignalStrength": model.signalStrength,
      "Frequency": model.frequency,
      "NetworkID": model.networkID,
      "IsHiddenSSID": model.isHiddenSSID,
      "RouterIP": model.routerIP,
      "Channel": model.channel,
      "Latitude": _coordinates?.lat.toString() ?? "",
      "Longitude": _coordinates?.lon.toString() ?? "",
      "TimeStamp": model.timeStamp,
      "DownloadSpeed": wiFiLog?['DownloadSpeed'] ?? _formatLogNumber(_speedDownload ?? 0.0),
      "UploadSpeed": _formatLogNumber(_speedUpload ?? 0.0),
    };

    wiFiLog = report;
    await _sendLog('$mobileLoggerApi?type=WIFIREPORT', report);
  }

  Future<void> _sendLog(String url, Map log) async {
    final userDataProvider = _userDataProvider;
    if (userDataProvider == null) return;

    if (!userDataProvider.isLoggedIn) {
      try {
        if (await NetworkHelper.getNewToken(headers))
          await NetworkHelper.authorizedPost(url, headers, json.encode(log));
      } catch (_) {}
      return;
    }

    offloadDataHeader = {'Authorization': 'Bearer ${userDataProvider.authenticationModel.accessToken}'};

    try {
      await NetworkHelper.authorizedPost(url, offloadDataHeader, json.encode(log));
    } catch (exception) {
      final tokenIsValid = !exception.toString().contains(ErrorConstants.INVALID_BEARER_TOKEN);
      if (tokenIsValid) return;

      try {
        if (!await userDataProvider.silentLogin()) return;
        offloadDataHeader = {'Authorization': 'Bearer ${userDataProvider.authenticationModel.accessToken}'};
        await NetworkHelper.authorizedPost(url, offloadDataHeader, json.encode(log));
      } catch (_) {}
    }
  }

  SpeedTestRunning _runningState(SpeedTestPhase phase) => SpeedTestRunning(
    phase: phase,
    downloadProgress: _percentDownloaded,
    uploadProgress: _percentUploaded,
    currentSpeedMbps: phase == SpeedTestPhase.upload ? _speedUpload ?? 0.0 : _speedDownload ?? 0.0,
    secondsElapsed: phase == SpeedTestPhase.upload ? _secondsElapsedUpload : _secondsElapsedDownload,
  );

  bool _canContinue(int operationId) => !_disposed && operationId == _operationId && _state is SpeedTestRunning;

  bool _isCurrentPhase(int operationId, SpeedTestPhase phase) {
    if (!_canContinue(operationId)) return false;
    return (_state as SpeedTestRunning).phase == phase;
  }

  void _handleTimeout(int operationId) {
    if (!_canContinue(operationId)) return;

    final timeoutState = SpeedTestTimeout(
      downloadMbps: _speedDownload ?? 0.0,
      uploadMbps: _speedUpload ?? 0.0,
      downloadCompleted: _percentDownloaded >= 1.0,
    );

    _operationId++;
    cancelDownload();
    cancelUpload();
    _transition(timeoutState);
    unawaited(sendNetworkDiagnostics(null));
  }

  void _failOperation(int operationId, Object exception) {
    if (!_canContinue(operationId)) return;
    _operationId++;
    cancelDownload();
    cancelUpload();
    _error = exception.toString();
    _transition(SpeedTestFailure(_error!));
  }

  void _transition(SpeedTestState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  double _safeProgress(int bytesTransferred, int totalBytes) {
    if (totalBytes <= 0 || bytesTransferred < 0) return 0.0;
    final progress = bytesTransferred / totalBytes;
    if (!progress.isFinite) return 0.0;
    return progress.clamp(0.0, 1.0);
  }

  double _safeMbps(int bytesTransferred) {
    final elapsedSeconds = _timer.elapsedMilliseconds / 1000.0;
    if (elapsedSeconds <= 0 || bytesTransferred <= 0) return 0.0;
    final speed = _convertToMbps(bytesTransferred / elapsedSeconds);
    return speed.isFinite ? speed : 0.0;
  }

  String _formatLogNumber(double value) => value.isFinite ? value.toStringAsFixed(2) : '0.00';

  set coordinates(Coordinates value) => _coordinates = value;
  set userDataProvider(UserDataProvider userDataProvider) => _userDataProvider = userDataProvider;
  set speed(double? lastSpeed) => _speedDownload = lastSpeed;

  double _convertToMbps(double speed) => speed / 125000;

  SpeedTestState get state => _state;
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

  @override
  void dispose() {
    _disposed = true;
    _operationId++;
    cancelDownload();
    cancelUpload();
    super.dispose();
  }
}
