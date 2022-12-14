import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/services/triton_media.dart';
import 'package:flutter/material.dart';

class MediaDataProvider extends ChangeNotifier {
  MediaDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _eventsService = MediaService();

    _eventsModels = [];
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  List<MediaModel>? _eventsModels;

  ///SERVICES
  late MediaService _eventsService;

  void fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _eventsService.fetchData()) {
      _eventsModels = _eventsService.mediaModels;
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
  List<MediaModel>? get eventsModels => _eventsModels;
}
