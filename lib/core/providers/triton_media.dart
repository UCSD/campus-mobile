import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/services/triton_media.dart';
import 'package:flutter/material.dart';

class MediaDataProvider extends ChangeNotifier {
  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  List<MediaModel> _mediaModels = [];

  ///SERVICES
  MediaService _mediaService = MediaService();

  void fetchMedia() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _mediaService.fetchData()) {
      _mediaModels = _mediaService.mediaModels;
      _lastUpdated = DateTime.now();

      /// check to see if the events feed returns nothing back
      if (_mediaModels.isEmpty) {
        _error = 'No events found.';
      }
    } else {
      _error = _mediaService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<MediaModel> get mediaModels => _mediaModels;
}
