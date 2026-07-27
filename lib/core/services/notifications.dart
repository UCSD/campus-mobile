import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/topics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  late List<TopicsModel> _topicsModel = [];

  Future<bool> fetchTopics() async {
    _error = null;
    _isLoading = true;
    try {
      String? response = await NetworkHelper.fetchData(dotenv.get('NOTIFICATIONS_TOPICS_ENDPOINT'));
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
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> postPushToken(Map<String, String> headers, body) async {
    try {
      String? response = await NetworkHelper.authorizedPost(
        dotenv.get('NOTIFICATIONS_ENDPOINT') + '/register',
        headers,
        body,
      );
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

  Future<bool> deletePushToken(Map<String, String> headers, String token) async {
    token = Uri.encodeComponent(token);
    try {
      String? response = await NetworkHelper.authorizedDelete(
        dotenv.get('NOTIFICATIONS_ENDPOINT') + '/token/' + token,
        headers,
      );
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

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
  List<TopicsModel> get topicsModel => _topicsModel;
}
