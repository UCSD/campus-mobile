import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/services/events.dart';
import 'package:flutter/material.dart';

class EventsDataProvider extends ChangeNotifier
{
  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  List<EventModel>? _eventsModels = [];

  ///SERVICES
  EventsService _eventsService = EventsService();

  void fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _eventsService.fetchData()) {
      _eventsModels = _eventsService.eventsModels;
      _lastUpdated = DateTime.now();

      /// check to see if the events feed returns nothing back
      if (_eventsModels!.isEmpty) {
        _error = 'No events found.';
      }
    } else {
      _error = _eventsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<EventModel>? get eventsModels => _eventsModels;
}
