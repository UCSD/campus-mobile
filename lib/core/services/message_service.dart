//TODO: NEED AUTH BEARER TOKENS TO TEST ON APP

import 'dart:async';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class MessageService {
  Map<String, String> headers = {
    "accept": "application/json",
    "Authorization": "Bearer " + "86bd2fe8-9d62-3f8d-9133-359395c73b70",
  };

  final String mymessages_endpoint =
      'https://api-qa.ucsd.edu:8243/mp-mymessages/1.0.0/messages?start=';
  final String topics_endpoint = 
      'https://bvgjvzaakl.execute-api.us-west-2.amazonaws.com/dev/topics?topics=all,freefood&start=';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  Messages _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchMyMessagesData(timestamp) async {
    _error = null;
    _isLoading = true;

    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(mymessages_endpoint + timestamp.toString(), headers);

      /// parse data
      final data = messagesFromJson(_response);
      _isLoading = false;
      _data = data;
      print(_response);
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      print("error fetching the data");
      if (e.response.statusCode == 401) {
        if (await getNewToken()) {
          return await fetchMyMessagesData(timestamp);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchTopicData(timestamp) async {
    _error = null;
    _isLoading = true;

    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(topics_endpoint + timestamp.toString());

      /// parse data
      final data = messagesFromJson(_response);
      _isLoading = false;
      _data = data;
      print(_response);
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      print("error fetching the data");
      if (e.response.statusCode == 401) {
        if (await getNewToken()) {
          return await fetchTopicData(timestamp);
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
          "Basic //REPLACE HERE"
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
  Messages get messagingModels => _data;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}