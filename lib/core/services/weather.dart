import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/weather.dart';

class WeatherService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint = 'https://77hpgmqp7k.execute-api.us-west-2.amazonaws.com/dev-v1/weatherservice/weatherforecast';

  late WeatherModel _weatherModel;

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      String _response = await _networkHelper.fetchData(endpoint);
      _weatherModel = weatherModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('Exception caught in fetchData: $_error');
      return false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  WeatherModel get weatherModel => _weatherModel;
}
