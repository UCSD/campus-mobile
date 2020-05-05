import 'package:campus_mobile_experimental/core/services/networking.dart';

class BarcodeService {
  BarcodeService();
  bool _isLoading;
  String _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String _endpoint = 'https://api.ucsd.edu:8243/scandata/1.0.0/scanData';
  final Map<String, String> headers = {
    "accept": "application/json",
    "Authorization": "",
  };

  Future<bool> uploadResults(
      Map<String, String> headers, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    try {
      final response =
          await _networkHelper.authorizedPost(_endpoint, headers, body);
      if (response != null) {
        _isLoading = false;
        return true;
      } else {
        throw (response.toString());
      }
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.response != null && e.response.statusCode == 401) {
        if (await getNewToken()) {
          return await uploadResults(headers, body);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization": "PUBLIC_AUTH_SERVICE_TOKEN_API_KEY_PH"
    };
    try {
      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");
      headers["Authorization"] = "Bearer " + response["access_token"];
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String get error => _error;
  bool get isLoading => _isLoading;
}
