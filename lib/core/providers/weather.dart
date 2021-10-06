import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:campus_mobile_experimental/core/services/weather.dart';
import 'package:flutter/material.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _weatherService = WeatherService();
    _weatherModel = WeatherModel();
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  WeatherModel? _weatherModel;

  ///SERVICES
  late WeatherService _weatherService;

  void fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _weatherService.fetchData()) {
      _weatherModel = _weatherService.weatherModel;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _weatherService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  WeatherModel? get weatherModel => _weatherModel;
}
