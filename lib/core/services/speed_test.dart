import 'package:connectivity/connectivity.dart';
import 'package:wifi_connection/WifiInfo.dart';
import 'package:wifi_connection/WifiConnection.dart';

import '../../app_networking.dart';

class SpeedTestService {
  SpeedTestService();
  Connectivity _connectivity = Connectivity();
  final NetworkHelper _networkHelper = NetworkHelper();
  bool _isLoading = false;
  String _error;

  Future<bool> fetchSignedUrls() async {
    _error = null;
    _isLoading = true;
    try {
      String _downloadResponse = await _networkHelper.fetchData(
          "https://api-qa.ucsd.edu:8243/wifi_test/v1.0.0/generateDownloadUrl");
      String _uploadResponse = await _networkHelper.fetchData(
          "https://api-qa.ucsd.edu:8243/wifi_test/v1.0.0/generateUploadUrl?name=temp.html");

      /// parse data

      WifiInfo wifiData;
      fetchNetworkDiagnostics().then(( WifiInfo data) {
        if (data == null) {
          // State = not connected to wifi
        }
        wifiData = data;
      });
      _isLoading = false;
      return true;
    } catch (exception) {}
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
}
