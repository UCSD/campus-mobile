import 'package:campus_mobile_experimental/core/models/speed_test.dart';
import 'package:connectivity/connectivity.dart';
import 'package:wifi_connection/WifiInfo.dart';
import 'package:wifi_connection/WifiConnection.dart';

import '../../app_networking.dart';

class SpeedTestService {
  SpeedTestService();
  Connectivity _connectivity = Connectivity();
  final NetworkHelper _networkHelper = NetworkHelper();
  SpeedTestModel _speedTestModel;
  bool _isLoading = false;
  String _error;

  Future<bool> fetchSignedUrls() async {
    _error = null;
    _isLoading = true;
    try {
      // Get download & upload urls
      String _downloadResponse = await _networkHelper.fetchData(
          "https://api-qa.ucsd.edu:8243/wifi_test/v1.0.0/generateDownloadUrl");
      String _uploadResponse = await _networkHelper.fetchData(
          "https://api-qa.ucsd.edu:8243/wifi_test/v1.0.0/generateUploadUrl?name=temp.html");

      /// parse data
      await fetchNetworkDiagnostics().then((WifiInfo data) {
        _speedTestModel = speedTestModelFromJson(
            data, _downloadResponse, _uploadResponse, data != null);
      });
      _isLoading = false;
      return true;
    } catch (exception) {
      _error = exception.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<WifiInfo> fetchNetworkDiagnostics() async {
    // Check connected to wifi
    if (await _connectivity.checkConnectivity() != ConnectivityResult.wifi) {
      return null;
    }

    // Check for UCSD wifi
    WifiInfo wiFiInfo = await WifiConnection.wifiInfo;
    if (wiFiInfo.ssid.contains("UCSD-PROTECTED") ||
        wiFiInfo.ssid.contains("UCSD-GUEST") ||
        wiFiInfo.ssid.contains("ResNet")) {
      return null;
    }

    return wiFiInfo;
  }

  bool get isLoading => _isLoading;
  String get error => _error;
  SpeedTestModel get speedTestModel => _speedTestModel;
}
