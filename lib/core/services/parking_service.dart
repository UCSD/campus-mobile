import 'dart:async';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'package:flutter/material.dart';

class ParkingService extends ChangeNotifier {
  ParkingService() {
    fetchData();
  }
  bool _isLoading = false;
  List<ParkingModel> _data = List<ParkingModel>();

  set data(List<ParkingModel> value) {
    _data = value;
    notifyListeners();
  }

  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": ":application/json",
  };

  final String endpoint =
      "https://ucsd-mobile-dev.s3-us-west-1.amazonaws.com/mock-apis/parking/mock_parking_data.json";

  fetchData() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      final data = parkingModelFromJson(_response);
      _isLoading = false;
      _data = data;
      notifyListeners();
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ParkingModel> get data => _data;

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
