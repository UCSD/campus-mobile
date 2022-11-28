import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:campus_mobile_experimental/core/services/weather.dart';
import 'package:flutter/material.dart';

class WeatherDataProvider extends ChangeNotifier
{
  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  WeatherModel? _weatherModel = WeatherModel();

  ///SERVICES
  late WeatherService _weatherService = WeatherService();

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
