import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';

class VentilationService {
  VentilationService() {
    fetchLocations();
  }

  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<VentilationLocationsModel>? _locationData;
  VentilationModel? _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String baseEndpoint =
      "https://ucsd-its-sandbox-wts-charles.s3.us-west-1.amazonaws.com/mock-api/ntplln-mock-2.json";

  Future<bool> fetchLocations() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(baseEndpoint);

      /// parse data
      final locationData = ventilationLocationsModelFromJson(_response);
      _isLoading = false;

      _locationData = locationData;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchData(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(
          "https://ucsd-its-sandbox-wts-charles.s3.us-west-1.amazonaws.com/mock-api/ntplln-mock-2-data.json");

      /// parse data
      final data = ventilationModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  bool get isLoading => _isLoading;

  String? get error => _error;

  DateTime? get lastUpdated => _lastUpdated;

  List<VentilationLocationsModel>? get locationData => _locationData;

  VentilationModel? get data => _data;
}
