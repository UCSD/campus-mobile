

import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';

class ParkingService {
  ParkingService() {
    fetchParkingLotData();
  }
  bool _isLoading = false;
  List<ParkingModel>? _data;
  DateTime? _lastUpdated;
  String? _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  final String endpoint =
      "https://mobile.ucsd.edu/replatform/v1/qa/webview/parking-v2/parking_lots.json";

  Future<bool> fetchParkingLotData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (_networkHelper.fetchData(endpoint) as FutureOr<String>);

      /// parse data
      _data = parkingModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  List<ParkingModel>? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
}
