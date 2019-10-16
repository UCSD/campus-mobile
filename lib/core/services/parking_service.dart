import 'dart:async';
import 'dart:convert';
import 'package:campus_mobile/core/models/parking_model.dart';
import 'package:campus_mobile/core/services/networking.dart';

class ParkingService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": ":application/json",
  };
  final String endpoint =
      "https://ucsd-mobile-dev.s3-us-west-1.amazonaws.com/mock-apis/parking/mock_parking_data.json";

  Future<List<ParkingModel>> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      final data = parkingModelFromJson(_response);
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return List<ParkingModel>();
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
