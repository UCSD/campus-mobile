import 'package:campus_mobile/core/models/events.dart';
import 'package:campus_mobile/core/services/events.dart';
import 'package:flutter/material.dart';

class EventsDataProvider extends ChangeNotifier {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  List<EventModel> _eventsModels = [];

  /// SERVICES
  var _eventsService = EventsService();

  void fetchEvents() async {
    _isLoading = true; _error = null;
    notifyListeners();
    if (await _eventsService.fetchData()) {
      _eventsModels = _eventsService.eventsModels!;
      _lastUpdated = DateTime.now();

      /// check to see if the events feed returns nothing back
      if (_eventsModels.isEmpty) _error = 'No events found.';
    } else {
      _error = _eventsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<EventModel> get eventsModels => _eventsModels;
}
