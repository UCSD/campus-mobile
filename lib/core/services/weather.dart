import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/weather.dart';

const String endpoint =
    'https://gglfnarjhf.execute-api.us-west-2.amazonaws.com/dev/';

class WeatherService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  WeatherModel _weatherModel = WeatherModel();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      _weatherModel = weatherModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();

      /// **********
      _isLoading = false;
      return false;
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;

  WeatherModel get weatherModel => _weatherModel;
}
