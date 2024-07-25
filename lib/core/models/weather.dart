// To parse this JSON data, do
//
//     final weatherModel = weatherModelFromJson(jsonString);

import 'dart:convert';

WeatherModel weatherModelFromJson(String str) =>
    WeatherModel.fromJson(json.decode(str));

String weatherModelToJson(WeatherModel data) => json.encode(data.toJson());

class WeatherModel {
  double? latitude;
  double? longitude;
  String? timezone;
  Weather? currentWeather;
  WeeklyForecast? weeklyForecast;
  int? offset;

  WeatherModel({
    this.latitude,
    this.longitude,
    this.timezone,
    this.currentWeather,
    this.weeklyForecast,
    this.offset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        timezone: json["timezone"],
        currentWeather: Weather.fromJson(json["currently"]),
        weeklyForecast: WeeklyForecast.fromJson(json["daily"]),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "currently": currentWeather?.toJson(),
        "daily": weeklyForecast?.toJson(),
        "offset": offset,
      };
}

class Weather {
  int time;
  String summary;
  String icon;
  int nearestStormDistance;
  int nearestStormBearing;
  int precipIntensity;
  int precipProbability;
  String precipType;
  double temperature;
  double apparentTemperature;
  double dewPoint;
  double humidity;
  double pressure;
  double windSpeed;
  double windGust;
  int windBearing;
  double cloudCover;
  int uvIndex;
  int visibility;
  double ozone;

  Weather({
    required this.time,
    required this.summary,
    required this.icon,
    this.nearestStormDistance = 0,
    this.nearestStormBearing = 0,
    this.precipIntensity = 0,
    this.precipProbability = 0,
    this.precipType = "None",
    required this.temperature,
    required this.apparentTemperature,
    this.dewPoint = 0.0,
    this.humidity = 0.0,
    this.pressure = 0.0,
    this.windSpeed = 0.0,
    this.windGust = 0.0,
    this.windBearing = 0,
    this.cloudCover = 0.0,
    this.uvIndex = 0,
    this.visibility = 0,
    this.ozone = 0.0,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        time: json["time"],
        summary: json["summary"],
        icon: json["icon"],
        nearestStormDistance: json["nearestStormDistance"],
        nearestStormBearing: json["nearestStormBearing"],
        precipIntensity: json["precipIntensity"],
        precipProbability: json["precipProbability"],
        precipType: json["precipType"] ?? "None",
        temperature: json["temperature"].toDouble(),
        apparentTemperature: json["apparentTemperature"].toDouble(),
        dewPoint: json["dewPoint"].toDouble(),
        humidity: json["humidity"].toDouble(),
        pressure: json["pressure"].toDouble(),
        windSpeed: json["windSpeed"].toDouble(),
        windGust: json["windGust"].toDouble(),
        windBearing: json["windBearing"],
        cloudCover: json["cloudCover"].toDouble(),
        uvIndex: json["uvIndex"],
        visibility: json["visibility"],
        ozone: json["ozone"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "summary": summary,
        "icon": icon,
        "nearestStormDistance": nearestStormDistance,
        "nearestStormBearing": nearestStormBearing,
        "precipIntensity": precipIntensity,
        "precipProbability": precipProbability,
        "precipType": precipType,
        "temperature": temperature,
        "apparentTemperature": apparentTemperature,
        "dewPoint": dewPoint,
        "humidity": humidity,
        "pressure": pressure,
        "windSpeed": windSpeed,
        "windGust": windGust,
        "windBearing": windBearing,
        "cloudCover": cloudCover,
        "uvIndex": uvIndex,
        "visibility": visibility,
        "ozone": ozone,
      };
}

class WeeklyForecast {
  String? summary;
  String? icon;
  List<Forecast>? data;

  WeeklyForecast({
    this.summary,
    this.icon,
    this.data,
  });

  factory WeeklyForecast.fromJson(Map<String, dynamic> json) => WeeklyForecast(
        summary: json["summary"],
        icon: json["icon"],
        data:
            List<Forecast>.from(json["data"].map((x) => Forecast.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "summary": summary,
        "icon": icon,
        "data": data?.map((x) => x.toJson()).toList(),
      };
}

class Forecast {
  int time;
  String summary;
  String icon;
  int sunriseTime;
  int sunsetTime;
  double moonPhase;
  double precipIntensity;
  double precipIntensityMax;
  int precipIntensityMaxTime;
  double precipProbability;
  String precipType;
  double temperatureHigh;
  int temperatureHighTime;
  double temperatureLow;
  int temperatureLowTime;
  double apparentTemperatureHigh;
  int apparentTemperatureHighTime;
  double apparentTemperatureLow;
  int apparentTemperatureLowTime;
  double dewPoint;
  double humidity;
  double pressure;
  double windSpeed;
  double windGust;
  int windGustTime;
  int windBearing;
  double cloudCover;
  int uvIndex;
  int uvIndexTime;
  double visibility;
  double ozone;
  double temperatureMin;
  int temperatureMinTime;
  double temperatureMax;
  int temperatureMaxTime;
  double apparentTemperatureMin;
  int apparentTemperatureMinTime;
  double apparentTemperatureMax;
  int apparentTemperatureMaxTime;

  Forecast({
    required this.time,
    required this.summary,
    required this.icon,
    this.sunriseTime = 0,
    this.sunsetTime = 0,
    this.moonPhase = 0.0,
    this.precipIntensity = 0.0,
    this.precipIntensityMax = 0.0,
    this.precipIntensityMaxTime = 0,
    this.precipProbability = 0.0,
    this.precipType = "None",
    required this.temperatureHigh,
    this.temperatureHighTime = 0,
    required this.temperatureLow,
    this.temperatureLowTime = 0,
    this.apparentTemperatureHigh = 0.0,
    this.apparentTemperatureHighTime = 0,
    this.apparentTemperatureLow = 0.0,
    this.apparentTemperatureLowTime = 0,
    this.dewPoint = 0.0,
    this.humidity = 0.0,
    this.pressure = 0.0,
    this.windSpeed = 0.0,
    this.windGust = 0.0,
    this.windGustTime = 0,
    this.windBearing = 0,
    this.cloudCover = 0.0,
    this.uvIndex = 0,
    this.uvIndexTime = 0,
    this.visibility = 0.0,
    this.ozone = 0.0,
    this.temperatureMin = 0.0,
    this.temperatureMinTime = 0,
    this.temperatureMax = 0.0,
    this.temperatureMaxTime = 0,
    this.apparentTemperatureMin = 0.0,
    this.apparentTemperatureMinTime = 0,
    this.apparentTemperatureMax = 0.0,
    this.apparentTemperatureMaxTime = 0,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) => Forecast(
        time: json["time"],
        summary: json["summary"],
        icon: json["icon"],
        sunriseTime: json["sunriseTime"],
        sunsetTime: json["sunsetTime"],
        moonPhase: json["moonPhase"].toDouble(),
        precipIntensity: json["precipIntensity"].toDouble(),
        precipIntensityMax: json["precipIntensityMax"].toDouble(),
        precipIntensityMaxTime: json["precipIntensityMaxTime"],
        precipProbability: json["precipProbability"].toDouble(),
        precipType: json["precipType"] == null ? null : json["precipType"],
        temperatureHigh: json["temperatureHigh"].toDouble(),
        temperatureHighTime: json["temperatureHighTime"],
        temperatureLow: json["temperatureLow"].toDouble(),
        temperatureLowTime: json["temperatureLowTime"],
        apparentTemperatureHigh: json["apparentTemperatureHigh"].toDouble(),
        apparentTemperatureHighTime: json["apparentTemperatureHighTime"],
        apparentTemperatureLow: json["apparentTemperatureLow"].toDouble(),
        apparentTemperatureLowTime: json["apparentTemperatureLowTime"],
        dewPoint: json["dewPoint"].toDouble(),
        humidity: json["humidity"].toDouble(),
        pressure: json["pressure"].toDouble(),
        windSpeed: json["windSpeed"].toDouble(),
        windGust: json["windGust"].toDouble(),
        windGustTime: json["windGustTime"],
        windBearing: json["windBearing"],
        cloudCover: json["cloudCover"].toDouble(),
        uvIndex: json["uvIndex"],
        uvIndexTime: json["uvIndexTime"],
        visibility: json["visibility"].toDouble(),
        ozone: json["ozone"].toDouble(),
        temperatureMin: json["temperatureMin"].toDouble(),
        temperatureMinTime: json["temperatureMinTime"],
        temperatureMax: json["temperatureMax"].toDouble(),
        temperatureMaxTime: json["temperatureMaxTime"],
        apparentTemperatureMin: json["apparentTemperatureMin"].toDouble(),
        apparentTemperatureMinTime: json["apparentTemperatureMinTime"],
        apparentTemperatureMax: json["apparentTemperatureMax"].toDouble(),
        apparentTemperatureMaxTime: json["apparentTemperatureMaxTime"],
      );

  Map<String, dynamic> toJson() => {
    "time": time,
    "summary": summary,
    "icon": icon,
    "sunriseTime": sunriseTime,
    "sunsetTime": sunsetTime,
    "moonPhase": moonPhase,
    "precipIntensity": precipIntensity,
    "precipIntensityMax": precipIntensityMax,
    "precipIntensityMaxTime": precipIntensityMaxTime,
    "precipProbability": precipProbability,
    "precipType": precipType,
    "temperatureHigh": temperatureHigh,
    "temperatureHighTime": temperatureHighTime,
    "temperatureLow": temperatureLow,
    "temperatureLowTime": temperatureLowTime,
    "apparentTemperatureHigh": apparentTemperatureHigh,
    "apparentTemperatureHighTime": apparentTemperatureHighTime,
    "apparentTemperatureLow": apparentTemperatureLow,
    "apparentTemperatureLowTime": apparentTemperatureLowTime,
    "dewPoint": dewPoint,
    "humidity": humidity,
    "pressure": pressure,
    "windSpeed": windSpeed,
    "windGust": windGust,
    "windGustTime": windGustTime,
    "windBearing": windBearing,
    "cloudCover": cloudCover,
    "uvIndex": uvIndex,
    "uvIndexTime": uvIndexTime,
    "visibility": visibility,
    "ozone": ozone,
    "temperatureMin": temperatureMin,
    "temperatureMinTime": temperatureMinTime,
    "temperatureMax": temperatureMax,
    "temperatureMaxTime": temperatureMaxTime,
    "apparentTemperatureMin": apparentTemperatureMin,
    "apparentTemperatureMinTime": apparentTemperatureMinTime,
    "apparentTemperatureMax": apparentTemperatureMax,
    "apparentTemperatureMaxTime": apparentTemperatureMaxTime,
  };
}
