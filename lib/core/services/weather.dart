import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String WEATHER_ICON_BASE_URL =
    'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/';

class WeatherService {
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
      try {
        return jsonDecode(response.body);
      } catch (e) {
        ///TODO: log this as a bug because the json parsing has failed
        print(e);
        error = e;
        throw Exception('Failed to load post');
      }
    } else {
      error = response.body;
      isLoading = false;

      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
