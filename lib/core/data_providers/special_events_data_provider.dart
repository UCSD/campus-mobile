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
  bool _isFull;
  int _numFiltersApplied;
  bool _filtersApplied;
  DateTime _lastUpdated;
  String _error;
  String _currentDateSelection;
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
    _isFull = true;
    _currentDateSelection = "2018-09-22"; // Initialize
    _filtersApplied = false;
    notifyListeners();
  }

  void populateFilters() {
    Map<String, bool> filterMap = Map<String, bool>();
    for (String label in _specialEventsModel.labels) {
      filterMap[label] = false;
    }
    _filters = filterMap;
    _numFiltersApplied = 0; // initialize filters count
    notifyListeners();
  }

  void setDateString(String date) {
    _currentDateSelection = date;
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
    _numFiltersApplied++;
    if (_filtersApplied == false) {
      _filtersApplied = true;
    }
    notifyListeners();
  }

  void removeFilter(String filter) {
    _filters[filter] = false;
    _numFiltersApplied--;
    if (_numFiltersApplied == 0) _filtersApplied = false;
    notifyListeners(); //re-renders UI
  }

  void switchToMySchedule() {
    _isFull = false;
    notifyListeners();
  }

  void switchToFullSchedule() {
    _isFull = true;
    notifyListeners();
  }

  List<String> selectEvents() {
    List<String> itemsForDate =
        _specialEventsModel.dateItems[_currentDateSelection];
    if (_isFull) {
      if (_filtersApplied)
        return applyFilters(itemsForDate);
      else
        return itemsForDate;
    } else {
      List<String> myItemsForDate = new List<String>();
      itemsForDate.forEach((f) => {
            if (_myEventsList[f] == true) {myItemsForDate.add(f)}
          });
      return myItemsForDate;
    }
  }

  // Makes new list of event UIDs after appliying fliters and maintains order
  List<String> applyFilters(List<String> events) {
    List<String> filteredEvents = new List<String>();
    for (int i = 0; i < events.length; i++) {
      String filter = getLabel(events[i]);
      if (_filters[filter]) {
        filteredEvents.add(events[i]);
      }
    }
    return filteredEvents;
  }

  //Helper function to get label given UID as string
  String getLabel(String uid) {
    for (int i = 0; i < _specialEventsModel.labels.length; i++) {
      if (_specialEventsModel.labelItems[_specialEventsModel.labels[i]]
          .contains(uid)) return _specialEventsModel.labels[i];
    }
    return null;
  }

  // Getters
  Map<String, bool> get myEventsList => _myEventsList;
  bool get isLoading => _isLoading;
  bool get isFull => _isFull;
  bool get filtersApplied => _filtersApplied;
  String get error => _error;
  String get currentDateSelection => _currentDateSelection;
  DateTime get lastUpdated => _lastUpdated;
  SpecialEventsModel get specialEventsModel => _specialEventsModel;
  Map<String, bool> get filters => _filters;
}
