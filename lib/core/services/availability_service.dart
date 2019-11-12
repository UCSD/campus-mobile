import 'dart:async';
import 'package:campus_mobile_beta/core/models/availability_model.dart';
import 'package:campus_mobile_beta/core/services/networking.dart';
import 'package:flutter/material.dart';

class AvailabilityService extends ChangeNotifier {
  AvailabilityService() {
    fetchData();
  }
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  List<AvailabilityModel> _data;

  List<AvailabilityModel> get data => _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": ":application/json",
    "Authorization": "Bearer " + "7e0ed6a9-86a7-3349-86a2-b4aa035ab8bb",
  };
  final String endpoint =
      "https://api-qa.ucsd.edu:8243/occuspace/v1.0/busyness";

  fetchData() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      final data = availabilityModelFromJson(_response);
      _isLoading = false;

      _data = data;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
