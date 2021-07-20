import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/ventilation.dart';

class VentilationService {
  VentilationService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<VentilationModel>? _data;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider
  List<VentilationModel>? get data => _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String endpoint =
      "https://ucsd-its-sandbox-wts-charles.s3.us-west-1.amazonaws.com/mock-api/ntplln-mock-3.json";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await (_networkHelper.authorizedFetch(endpoint, headers));

      /// parse data
      final data = ventilationModelFromJson(_response);
      _isLoading = false;

      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
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

  /// MIGHT NEED TO CHANGE THIS SINCE THE MOCK JSON DOES NOT NEED A TOKEN
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
