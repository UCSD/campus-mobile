import 'package:campus_mobile_experimental/core/services/networking.dart';

class BarcodeService {
  BarcodeService();
  bool _isLoading;
  String _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String _endpoint = 'https://api-qa.ucsd.edu:8243/scandata/2.0.0/scanData';

  Future<bool> uploadResults(
      Map<String, String> headers, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    try {
      final response =
          await _networkHelper.authorizedPost(_endpoint, headers, body);
      if (response != null &&
          validateUploadResults(body, response)) {
        print("Submission successful");
        _isLoading = false;
        return true;
      } else {
        throw (response.toString());
      }
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }
  bool validateUploadResults(Map<String, dynamic> submit, Map<String, dynamic> response) {
    return submit["barcode"] == response["SCAN_CODE_ID"];
  }
  String get error => _error;
  bool get isLoading => _isLoading;
}
