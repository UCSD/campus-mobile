import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParkingService {
  ParkingService() {
    fetchParkingLotData();
  }

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {"accept": "application/json"};

  /// MODELS
  List<ParkingModel>? _data;

  Future<bool> fetchParkingLotData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (NetworkHelper.authorizedFetch(
        dotenv.get('PARKING_SERVICE_API_ENDPOINT') + "/status",
        headers,
      ));

      /// parse data
      _data = parkingModelFromJson(_response);
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        var isNewTokenObtained = await NetworkHelper.getNewToken(headers);
        if (isNewTokenObtained) return await fetchParkingLotData();
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<ParkingModel>? get data => _data;
}
