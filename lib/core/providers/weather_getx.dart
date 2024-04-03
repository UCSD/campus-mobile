import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:campus_mobile_experimental/core/services/weather.dart';
import 'package:get/get.dart';

/// Controller class for managing weather-related data using GetX state management.
class WeatherGetX extends GetxController {
  ///STATES
  Rx<bool> _isLoading = false
      .obs; // Observable boolean representing whether weather data is currently being loaded.
  Rxn<DateTime> _lastUpdated = Rxn<
      DateTime>(); // Observable representing the timestamp of the last update of weather data.
  Rxn<String> _error = Rxn<
      String>(); // Observable representing any error that occurred while fetching weather data.

  ///MODELS
  Rx<WeatherModel?> _weatherModel =
      WeatherModel().obs; // Observable containing weather data.

  ///SERVICES
  late WeatherService _weatherService =
      WeatherService(); // Instance of the WeatherService class for fetching weather data.

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchWeather();
  }

  /// Method to fetch weather data.
  void fetchWeather() async {
    _isLoading.value = true; // Indicate that data is being fetched
    _error.value = null; // Reset any previous errors

    if (await _weatherService.fetchData()) {
      // If weather data fetching is successful
      _weatherModel.value = _weatherService.weatherModel; // Update weather data
      _lastUpdated.value = DateTime.now(); // Update timestamp of last update
    } else {
      // If weather data fetching fails
      ///TODO: determine what error to show to the user
      _error.value = _weatherService.error; // Set error message
    }
    _isLoading.value = false; // Indicate that data fetching is complete
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  DateTime? get lastUpdated => _lastUpdated.value;
  WeatherModel? get weatherModel => _weatherModel.value;
}
