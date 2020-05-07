import 'dart:async';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class NotificationService {
  final NetworkHelper _networkHelper = NetworkHelper();
  final String _endpoint = 'https://api.ucsd.edu:8243/mp-registration/1.0.0';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;

  Future<bool> postPushToken(Map<String, String> headers, body) async {
    String response = await _networkHelper.authorizedPost(
        _endpoint + '/register', headers, body);
    if (response == 'Success') {
      return true;
    } else {
      _error = response;
      return false;
    }
  }

  Future<bool> deletePushToken(
      Map<String, String> headers, String token) async {
    token = Uri.encodeComponent(token);
    String response = await _networkHelper.authorizedDelete(
        _endpoint + '/token/' + token, headers);
    if (response == 'Success') {
      return true;
    } else {
      _error = response;
      return false;
    }
  }

  String get error => _error;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
