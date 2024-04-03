import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:campus_mobile_experimental/core/services/weather.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeatherGetX extends GetxController {
  @override
  Future<void> onInit() async {
    super.onInit();
    fetchWeather();
  }

  ///STATES
  Rx<bool> _isLoading = false.obs;
  Rxn<DateTime> _lastUpdated = Rxn<DateTime>();
  Rxn<String> _error = Rxn<String>();

  ///MODELS
  Rx<WeatherModel> _weatherModel = WeatherModel().obs;

  ///SERVICES
  late WeatherService _weatherService = WeatherService();

  void fetchWeather() async {
    _isLoading.value = true;
    _error.value = null;

    if (await _weatherService.fetchData()) {
      _weatherModel.value = _weatherService.weatherModel;
      _lastUpdated.value = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error.value = _weatherService.error;
    }
    _isLoading.value = false;
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  DateTime? get lastUpdated => _lastUpdated.value;
  WeatherModel? get weatherModel => _weatherModel.value;
}
