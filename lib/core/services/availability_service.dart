import 'dart:async';
<<<<<<< HEAD
import 'package:campus_mobile_beta/core/models/availability_model.dart';
import 'package:campus_mobile_beta/core/services/networking.dart';
=======

import 'package:campus_mobile/core/models/availability_model.dart';
import 'package:campus_mobile/core/services/networking.dart';
>>>>>>> 41519e4... implement links card

class AvailabilityService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": ":application/json",
    "Authorization": "Bearer " + "d409dd63-f8da-362d-b337-c506eac2c994",
  };
  final String endpoint =
      "https://api-qa.ucsd.edu:8243/occuspace/v1.0/busyness";

  Future<List<AvailabilityModel>> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      final data = availabilityModelFromJson(_response);
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return List<AvailabilityModel>();
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
