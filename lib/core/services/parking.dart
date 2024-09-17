import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<bool> fetchParkingLotData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (_networkHelper.authorizedFetch(
          dotenv.get('PARKING_SERVICE_API_ENDPOINT') + "/status", headers));

      /// parse data
      _data = parkingModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await _networkHelper.getNewToken(headers)) {
          return await fetchParkingLotData();
        }
      }
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
