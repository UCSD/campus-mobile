import 'dart:async';
import 'dart:io';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/speed_test.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:wifi_connection/WifiConnection.dart';
import 'package:wifi_connection/WifiInfo.dart';

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
  final Map<String, String> header = {
    "accept": "application/json",
  };

  Future<bool> fetchSignedUrls() async {
    _error = null;
    _isLoading = true;
    try {
      await getNewToken();
      // Get download & upload urls
      String? _downloadResponse = await _networkHelper.authorizedFetch(
          "https://api-qa.ucsd.edu:8243/wifi_test/v1.0.0/url_generator/download_url",
          header);
      String? _uploadResponse = await _networkHelper.authorizedFetch(
          "https://api-qa.ucsd.edu:8243/wifi_test/v1.0.0/url_generator/upload_url?name=temp.html",
          header);

      /// parse data
      await fetchNetworkDiagnostics().then((WifiInfo? data) {
        _speedTestModel = speedTestModelFromJson(
            data, _downloadResponse!, _uploadResponse!, data != null);
      });
      _isLoading = false;
      return true;
    } catch (exception) {
      // Occurs when there is no connection
      _speedTestModel = SpeedTestModel.fromJson(null, null, null, false);
      _error = exception.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<WifiInfo?> fetchNetworkDiagnostics() async {

    _isLoading = true;
    // Check connected to wifi
    if (await _connectivity.checkConnectivity() != ConnectivityResult.wifi) {
      _isLoading = false;
      return null;
    }
    late bool isUCSDWIFI;
    // Check for UCSD wifi
    WifiInfo? wiFiInfo = await WifiConnection.wifiInfo.then((value) {
      if ((!value.ssid!.contains("UCSD-PROTECTED")) &&
          (!value.ssid!.contains("UCSD-GUEST")) &&
          (!value.ssid!.contains("ResNet"))) {
        isUCSDWIFI = false;
        _isLoading = false;
        return null;
      }
      _isLoading = false;
      isUCSDWIFI = true;
      return value;
    });

    if (!isUCSDWIFI) {
      _isLoading = false;
      return null;
    }

    return wiFiInfo;
  }

  bool get isLoading => _isLoading;

  String? get error => _error;

  SpeedTestModel? get speedTestModel => _speedTestModel;

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

      header["Authorization"] = "Bearer " + response["access_token"];

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
