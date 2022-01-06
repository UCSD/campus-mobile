import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/topics.dart';

class NotificationService {
  final NetworkHelper _networkHelper = NetworkHelper();
  final String _endpoint = 'https://api-qa.ucsd.edu:8243/mp-registration/2.0.0';
  final String _topicsEndpoint =
      'https://mobile.ucsd.edu/replatform/v1/qa/topics.json';
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<TopicsModel>? _topicsModel;

  Future<bool> fetchTopics() async {
    print('NotificationService:fetchTopics');
    try {
      String? response = await _networkHelper.fetchData(_topicsEndpoint);
      if (response != null) {
        _topicsModel = topicsModelFromJson(response);
        return true;
      } else {
        _error = response;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> postPushToken(Map<String, String> headers, body) async {
    print('NotificationService:postPushToken');
    try {
      String? response = await _networkHelper.authorizedPost(
          _endpoint + '/register', headers, body);
      if (response == 'Success') {
        return true;
      } else {
        _error = response;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deletePushToken(
      Map<String, String> headers, String token) async {
    print('NotificationService:deletePushToken');
    token = Uri.encodeComponent(token);
    try {
      String? response = await _networkHelper.authorizedDelete(
          _endpoint + '/token/' + token, headers);
      if (response == 'Success') {
        return true;
      } else {
        _error = response;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String? get error => _error;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
  List<TopicsModel>? get topicsModel => _topicsModel;
}
