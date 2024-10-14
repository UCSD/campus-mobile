import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint = dotenv.get('WEATHER_ENDPOINT');
  WeatherModel _weatherModel = WeatherModel();

  Future<bool> fetchData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      _weatherModel = weatherModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  NetworkHelper get availabilityService => _networkHelper;
  WeatherModel get weatherModel => _weatherModel;
}
