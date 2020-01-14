import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/core/services/special_events_service.dart';
import 'package:flutter/material.dart';

class SpecialEventsDataProvider extends ChangeNotifier {
  SpecialEventsDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _specialEventsService = SpecialEventsService();
    _specialEventsModel = SpecialEventsModel();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  SpecialEventsModel _specialEventsModel;

  ///SERVICES
  SpecialEventsService _specialEventsService;

  void fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _specialEventsService.fetchData()) {
      _specialEventsModel = _specialEventsService.specialEventsModel;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _specialEventsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  SpecialEventsModel get weatherModel => _specialEventsModel;
}
