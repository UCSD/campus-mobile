import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';

class MessageService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  Messages? _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  final String myMessagesApiUrl =
      'https://api-qa.ucsd.edu:8243/mp-mymessages/2.0.0';
  final String topicsApiUrl =
      'https://api-qa.ucsd.edu:8243/mp-topicmessages/2.0.0';

  final Map<String, String> topicsHeaders = {
    "accept": "application/json",
  };

  Future<bool> fetchMyMessagesData(
      int? timestamp, Map<String, String> authHeaders) async {
    _error = null;
    _isLoading = true;

    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          myMessagesApiUrl + '/messages?start=' + timestamp.toString(),
          authHeaders);

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

  Future<bool> fetchTopicData(int? timestamp, List<String?> topics) async {
    _error = null;
    _isLoading = true;

    String topicsEndpoint = '/topics?topics=' + topics.join(',');
    String timestampEndpoint = '&start=' + timestamp.toString();

    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          topicsApiUrl + topicsEndpoint + timestampEndpoint, topicsHeaders);

      /// parse data
      final data = messagesFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await fetchTopicData(timestamp, topics);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization":
          "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
    };
    try {
      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");

      topicsHeaders["Authorization"] = "Bearer " + response["access_token"];

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String? get error => _error;
  Messages? get messagingModels => _data;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
