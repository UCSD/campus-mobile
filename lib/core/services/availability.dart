import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';

class AvailabilityService {
  AvailabilityService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<AvailabilityGroups>? _data;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider
  List<AvailabilityGroups>? get data => _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String endpoint =
      "https://api-qa.ucsd.edu:8243/occuspace/v3.0/busyness";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await (_networkHelper.authorizedFetch(endpoint, headers));

      /// parse data
      final data = availabilityApiModelFromJson(_response);
      _isLoading = false;

      List<AvailabilityGroups> models = [];
      for (AvailabilityGroups group in data.data!) {
        models.add(group);
      }

      _data = models;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      print("Error in services/availability.dart: $e");

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
