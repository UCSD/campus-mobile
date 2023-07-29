import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/weather.dart';

UseQueryResult<WeatherModel, dynamic> useFetchWeather() {
  return useQuery(['weather'], () async {
    /// fetch data
    String _response = await NetworkHelper().fetchData(
        'https://77hpgmqp7k.execute-api.us-west-2.amazonaws.com/dev-v1/weatherservice/weatherforecast');
    debugPrint("WeatherModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = weatherModelFromJson(_response);
    return data;
  });
}
