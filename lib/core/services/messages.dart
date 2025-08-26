import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  late Messages _data;

  Future<bool> fetchMyMessagesData(
      int timestamp, Map<String, String> authHeaders) async {
    _error = null;
    _isLoading = true;

    try {
      /// fetch data
      String _response = await NetworkHelper.authorizedFetch(
          dotenv.get('MY_MESSAGES_API_ENDPOINT') + timestamp.toString(),
          authHeaders);

      /// parse data
      final data = messagesFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await NetworkHelper.getNewToken(authHeaders))
          return await fetchMyMessagesData(timestamp, authHeaders);
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> fetchTopicData(int timestamp, List<String?> topics) async {
    _error = null;
    _isLoading = true;
    var topicsEndpoint = 'topics=' + topics.join(',');
    var timestampEndpoint = '&start=' + timestamp.toString();
    try {
      /// fetch data
      String _response = await NetworkHelper.fetchData(
          dotenv.get('TOPICS_API_ENDPOINT') +
              topicsEndpoint +
              timestampEndpoint);

      /// parse data
      final data = messagesFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
  Messages get messagingModels => _data;
}
