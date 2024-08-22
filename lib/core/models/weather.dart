// To parse this JSON data, do
//
//     final weatherModel = weatherModelFromJson(jsonString);

import 'dart:convert';

WeatherModel weatherModelFromJson(String str) => WeatherModel.fromJson(json.decode(str));

String weatherModelToJson(WeatherModel data) => json.encode(data.toJson());

class WeatherModel {
  double latitude;
  double longitude;
  String timezone;
  Weather currentWeather;
  WeeklyForecast weeklyForecast;
  int offset;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.currentWeather,
    required this.weeklyForecast,
    required this.offset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
    latitude: json["latitude"]?.toDouble() ?? 0.0,
    longitude: json["longitude"]?.toDouble() ?? 0.0,
    timezone: json["timezone"] ?? '',
    currentWeather: Weather.fromJson(json["currently"] ?? {}),
    weeklyForecast: WeeklyForecast.fromJson(json["daily"] ?? {}),
    offset: json["offset"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "timezone": timezone,
    "currently": currentWeather.toJson(),
    "daily": weeklyForecast.toJson(),
    "offset": offset,
  };
}

class Weather {
  int time;
  String summary;
  String icon;
  double temperature;
  double apparentTemperature;

  Weather({
    required this.time,
    required this.summary,
    required this.icon,
    required this.temperature,
    required this.apparentTemperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    time: json["time"] ?? 0,
    summary: json["summary"] ?? '',
    icon: json["icon"] ?? '',
    temperature: json["temperature"]?.toDouble() ?? 0.0,
    apparentTemperature: json["apparentTemperature"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "summary": summary,
    "icon": icon,
    "temperature": temperature,
    "apparentTemperature": apparentTemperature,
  };
}

class WeeklyForecast {
  String summary;
  String icon;
  List<Forecast> data;

  WeeklyForecast({
    required this.summary,
    required this.icon,
    required this.data,
  });

  factory WeeklyForecast.fromJson(Map<String, dynamic> json) => WeeklyForecast(
    summary: json["summary"] ?? '',
    icon: json["icon"] ?? '',
    data: json["data"] != null ? List<Forecast>.from(json["data"].map((x) => Forecast.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "summary": summary,
    "icon": icon,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Forecast {
  int time;
  String summary;
  String icon;
  double temperatureHigh;
  double temperatureLow;

  Forecast({
    required this.time,
    required this.summary,
    required this.icon,
    required this.temperatureHigh,
    required this.temperatureLow,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) => Forecast(
    time: json["time"] ?? 0,
    summary: json["summary"] ?? '',
    icon: json["icon"] ?? '',
    temperatureHigh: json["temperatureHigh"]?.toDouble() ?? 0.0,
    temperatureLow: json["temperatureLow"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "summary": summary,
    "icon": icon,
    "temperatureHigh": temperatureHigh,
    "temperatureLow": temperatureLow,
  };
}
