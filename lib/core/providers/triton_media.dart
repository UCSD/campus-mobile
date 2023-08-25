import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/services/triton_media.dart';
import 'package:flutter/material.dart';

class MediaDataProvider extends ChangeNotifier {
  MediaDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _mediaService = MediaService();

    _mediaModels = [];
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  List<MediaModel>? _mediaModels;

  ///SERVICES
  late MediaService _mediaService;

  void fetchMedia() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _mediaService.fetchData()) {
      _mediaModels = _mediaService.mediaModels;
      _lastUpdated = DateTime.now();

      /// check to see if the events feed returns nothing back
      if (_mediaModels!.isEmpty) {
        _error = 'No events found.';
      }
    } else {
      _error = _mediaService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<MediaModel>? get mediaModels => _mediaModels;
}
