//TODO: NEED AUTH BEARER TOKENS TO TEST ON APP

import 'dart:async';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class MessageService {
  final String mymessages_endpoint =
      'https://api-qa.ucsd.edu:8243/mp-mymessages/1.0.0/messages?start=';
  final String topics_endpoint =
      'https://h6rc133pbh.execute-api.us-west-2.amazonaws.com/prod/topics?';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  Messages _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchMyMessagesData(
      int timestamp, Map<String, String> authHeaders) async {
    _error = null;
    _isLoading = true;

    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          mymessages_endpoint + timestamp.toString(), authHeaders);

      /// parse data
      final data = messagesFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchTopicData(int timestamp, List<String> topics) async {
    _error = null;
    _isLoading = true;

    String topicsEndpoint = 'topics=' + topics.join(',');
    String timestampEndpoint = '&start=' + timestamp.toString();
    try {
      /// fetch data
      String _response = await _networkHelper
          .fetchData(topics_endpoint + topicsEndpoint + timestampEndpoint);

      /// parse data
      final data = messagesFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String get error => _error;
  Messages get messagingModels => _data;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
