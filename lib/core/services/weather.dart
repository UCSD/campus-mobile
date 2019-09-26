import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String WEATHER_ICON_BASE_URL =
    'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/';

class WeatherService {
  WeatherService();

  bool isLoading = false;
  DateTime lastUpdated = DateTime.now();
  http.Response response;
  String error;

  Future<Map> fetchPost() async {
    error = null;
    isLoading = true;
    response = await http.get(
        'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast');

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      isLoading = false;
      error = null;
      return jsonDecode(response.body);
    } else {
      error = response.body;
      isLoading = false;
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
