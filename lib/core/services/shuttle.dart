import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';

class ShuttleService {
  ShuttleService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<ShuttleStopModel> _data = [];
  List<ShuttleStopModel> get data => _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String campusShuttlesApiUrl =
      "https://api-qa.ucsd.edu:8243/shuttles/v1.0.0";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;

    try {
      String _response = await _networkHelper.authorizedFetch(
          campusShuttlesApiUrl + "/stops", headers);
      var data = shuttleStopModelFromJson(_response);
      _data = data;
      _isLoading = false;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await fetchData();
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<List<ArrivingShuttle>> getArrivingInformation(stopId) async {
    _error = null;
    _isLoading = true;
    try {
      String _response = await _networkHelper.authorizedFetch(
          campusShuttlesApiUrl + "/stops/" + stopId.toString() + "/arrivals",
          headers);
      final arrivingData = getArrivingShuttles(_response);
      _isLoading = false;
      return arrivingData;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await getArrivingInformation(stopId);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return [];
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
      headers["Authorization"] = "Bearer " + response["access_token"];
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
}
