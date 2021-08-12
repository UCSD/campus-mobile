import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';

class VentilationService {
  VentilationService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<VentilationLocationsModel>? _locations;
  VentilationDataModel? _data;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String locationsEndpoint =
      "https://api-qa.ucsd.edu:8243/buildingstatus/v1.0.0/buildings";
  final String dataBaseEndpoint =
      "https://api-qa.ucsd.edu:8243/buildingstatus/v1.0.0/buildings";

  Future<bool> fetchLocations() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      print("Before fetch locations:" + locationsEndpoint);
      String _response =
          await (_networkHelper.authorizedFetch(locationsEndpoint, headers));
      print("After fetch locations:" + locationsEndpoint);

      /// parse data
      final data = ventilationLocationsModelFromJson(_response);
      _isLoading = false;

      print("HELLO RESPONSE $_response");
      _locations = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      print("IN CATCH");
      if (e.toString().contains("401")) {
        print("Getting new token from fetchLocations");
        if (await getNewToken()) {
          print("Getting new token from fetchLocations");
          return await fetchLocations();
        }
      }
      _error = e.toString();
      print(_error);
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchData(String bfrID) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data, BUT FOR NOW THIS WILL NOT WORK WITH MOCK JSON
      print("Before fetching data" + dataBaseEndpoint + '/' + bfrID);
      String _response = await _networkHelper.authorizedFetch(
          dataBaseEndpoint + '/' + bfrID, headers);
      print("After fetching data" + dataBaseEndpoint + '/' + bfrID);
      // String _response = await _networkHelper.fetchData(dataBaseEndpoint);

      /// parse data
      final data = ventilationDataModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        print("Getting new token from fetchData");
        if (await getNewToken()) {
          print("Got new token from fetchData");
          return await fetchData(bfrID);
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

  List<VentilationLocationsModel>? get locations => _locations;

  VentilationDataModel? get data => _data;
}
