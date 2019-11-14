import 'package:campus_mobile_experimental/core/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class EventsService extends ChangeNotifier {
  final String endpoint =
      'https://2jjml3hf27.execute-api.us-west-2.amazonaws.com/prod/events/student';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  List<EventModel> _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  EventsService() {
    fetchData();
  }

  fetchData() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      final data = eventsModelFromJson(_response);
      _isLoading = false;
      _data = data;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  String get error => _error;

  List<EventModel> get eventsModel => _data;
  List<EventModel> get data => _data;
  bool get isLoading => _isLoading;

  DateTime get lastUpdated => _lastUpdated;
}
