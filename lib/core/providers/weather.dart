import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:campus_mobile_experimental/core/services/weather.dart';
import 'package:flutter/material.dart';

class WeatherDataProvider extends ChangeNotifier {
  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  late WeatherModel _weatherModel;

  ///SERVICES
  WeatherService _weatherService = WeatherService();

  void fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (await _weatherService.fetchData()) {
        _weatherModel = _weatherService.weatherModel;
        _lastUpdated = DateTime.now();
      } else {
        _error = _weatherService.error;
        print('Error from service: $_error'); // Add logging
      }
    } catch (e) {
      _error = e.toString();
      print('Exception caught: $_error'); // Add logging
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  WeatherModel get weatherModel => _weatherModel;
}
