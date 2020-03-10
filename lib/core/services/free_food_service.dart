import 'dart:async';
import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'dart:developer';

class FreefoodService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String endpoint =
      "https://tbk5wko7a9.execute-api.us-west-1.amazonaws.com/dev/msm-linksservice/v1";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);
      log(_response.toString());
      /// parse data
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  // bool get isLoading => _isLoading;

  // String get error => _error;

  // DateTime get lastUpdated => _lastUpdated;

  // NetworkHelper get availabilityService => _networkHelper;
}
