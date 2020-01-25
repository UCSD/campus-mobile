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
    _filters = Map<String, bool>();
    _myEventsList = Map<String, bool>();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  Map<String, bool> _filters;

  Map<String, bool> _myEventsList;

  ///MODELS
  SpecialEventsModel _specialEventsModel;

  ///SERVICES
  SpecialEventsService _specialEventsService;

  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _specialEventsService.fetchData()) {
      _specialEventsModel = _specialEventsService.specialEventsModel;
      _lastUpdated = DateTime.now();
      populateFilters();
    } else {
      ///TODO: determine what error to show to the user
      _error = _specialEventsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void populateFilters() {
    Map<String, bool> filterMap = Map<String, bool>();
    for (String label in _specialEventsModel.labels) {
      filterMap[label] = false;
    }
    _filters = filterMap;
    notifyListeners();
  }

  void addToMyEvents(String event) {
    _myEventsList[event] = true;
    notifyListeners();
  }

  void removeFromMyEvents(String event) {
    _myEventsList[event] = false;
    notifyListeners();
  }

  void addFilter(String filter) {
    _filters[filter] = true;
    notifyListeners();
  }

  void removeFilter(String filter) {
    _filters[filter] = false;
    notifyListeners(); //re-renders UI
  }

  ///SIMPLE GETTERS
  Map<String, bool> get myEventsList => _myEventsList;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  SpecialEventsModel get specialEventsModel => _specialEventsModel;
  Map<String, bool> get filters => _filters;
}
