import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  late WeatherModel _weatherModel;

  /// SERVICES
  final  _networkHelper = NetworkHelper();
  final endpoint = dotenv.get('WEATHER_ENDPOINT');

  Future<bool> fetchData() async {
    _error = null; _isLoading = true;
    try {
      String _response = await _networkHelper.fetchData(endpoint);
      _weatherModel = weatherModelFromJson(_response);
      return true;
    } catch (e) {
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
  WeatherModel get weatherModel => _weatherModel;
}
