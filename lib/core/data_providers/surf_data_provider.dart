import 'package:campus_mobile_experimental/core/services/surf_service.dart';
import 'package:campus_mobile_experimental/core/models/surf_model.dart';
import 'package:flutter/material.dart';

class SurfDataProvider extends ChangeNotifier {
  SurfDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _surfService = SurfService();
    _surfModel = SurfModel();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  SurfModel _surfModel;

  ///SERVICES
  SurfService _surfService;

  void fetchSurfData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _surfService.fetchData()) {
      _surfModel = _surfService.surfModel;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _surfService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  SurfModel get surfModel => _surfModel;
}
