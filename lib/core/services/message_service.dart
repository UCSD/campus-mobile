//TODO: NEED AUTH BEARER TOKENS TO TEST ON APP

import 'dart:async';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class MessageService {
  Map<String, String> headers = {
    "accept": "application/json",
    "Authorization": "Bearer " + "605e5b2a-5e62-38c6-8f4e-fdecec507e5f",
  };

  final String endpoint =
      'https://api-qa.ucsd.edu:8243/mp-mymessages/1.0.0';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  Messages _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;

    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      final data = messagesFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      print("error fetching the data");
      if (e.response.statusCode == 401) {
        if (await getNewToken()) {
          return await fetchData();
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