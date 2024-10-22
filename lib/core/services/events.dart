import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventsService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<EventModel>? _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  EventsService() { fetchData(); }

  Future<bool> fetchData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.fetchData(dotenv.get('EVENTS_ENDPOINT'));

      /// parse data
      final data = eventModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  List<EventModel>? get eventsModels => _data;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
