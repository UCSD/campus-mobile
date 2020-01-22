import 'package:campus_mobile_experimental/core/models/weather_model.dart';
import 'package:campus_mobile_experimental/core/services/weather_service.dart';
import 'package:flutter/material.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    _isHidden = false;

    ///INITIALIZE SERVICES
    _weatherService = WeatherService();
    _weatherModel = WeatherModel();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  bool _isHidden;


  ///MODELS
  WeatherModel _weatherModel;

  ///SERVICES
  WeatherService _weatherService;

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

  ///Use to hide and show cards
  void toggleHide() {
    _isHidden = !_isHidden;
    print("toggleHide: $_isHidden");
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  bool get isHidden => _isHidden;
  WeatherModel get weatherModel => _weatherModel;
}
