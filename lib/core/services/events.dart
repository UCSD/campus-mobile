import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventsService {
  EventsService() {
    fetchData();
  }

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  /// MODELS
  late List<EventModel> _data;

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await NetworkHelper.authorizedFetch(dotenv.get('EVENTS_ENDPOINT'), headers);

      /// parse data
      final data = eventModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await NetworkHelper.getNewToken(headers)) return await fetchData();
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
  List<EventModel>? get eventsModels => _data;
}
