import 'dart:async';
import 'dart:io';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/speed_test.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:wifi_connection/WifiConnection.dart';
import 'package:wifi_connection/WifiInfo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpeedTestService {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  SpeedTestService();

  Future<bool> checkSimulation() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (!androidInfo.isPhysicalDevice) {
          return true;
        }
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        if (!iosInfo.isPhysicalDevice) {
          return true;
        }
      }
    } catch (exception) {
      print(exception.toString());
    }
    return false;
  }

  Connectivity _connectivity = Connectivity();
  final NetworkHelper _networkHelper = NetworkHelper();
  SpeedTestModel? _speedTestModel;
  bool _isLoading = false;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  Future<bool> fetchSignedUrls() async {
    _error = null; _isLoading = true;
    try {
      await _networkHelper.getNewToken(headers);
      // Get download & upload urls
      String? _downloadResponse = await _networkHelper.authorizedFetch(
          dotenv.get('SPEED_TEST_DOWNLOAD_ENDPOINT'),
          headers);
      String? _uploadResponse = await _networkHelper.authorizedFetch(
          dotenv.get('SPEED_TEST_UPLOAD_ENDPOINT'),
          headers);

      /// parse data
      await fetchNetworkDiagnostics().then((WifiInfo? data) {
        _speedTestModel = speedTestModelFromJson(
            data, _downloadResponse!, _uploadResponse!, data != null);
      });
      return true;
    } catch (exception) {
      // Occurs when there is no connection
      _speedTestModel = SpeedTestModel.fromJson(null, null, null, false);
      _error = exception.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<WifiInfo?> fetchNetworkDiagnostics() async {
    _isLoading = true;
    // Check connected to wifi
    if (await _connectivity.checkConnectivity() != ConnectivityResult.wifi) {
      _isLoading = false;
      return null;
    }

    // Check wifi info
    WifiInfo? wiFiInfo = await WifiConnection.wifiInfo.then((value) => value);
    return wiFiInfo;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  SpeedTestModel? get speedTestModel => _speedTestModel;
}
