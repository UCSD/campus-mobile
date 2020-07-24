import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
import 'package:campus_mobile_experimental/core/services/spot_types_service.dart';
import 'package:flutter/material.dart';

class SpotTypesDataProvider extends ChangeNotifier {
  SpotTypesDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    _spotTypeModel = SpotTypeModel();
  }

  ///SERVICES
  final SpotTypesService _spotTypesService = SpotTypesService();

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  SpotTypeModel _spotTypeModel;
  //TODO v2 - Add to user profile

  void fetchSpotTypes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (await _spotTypesService.fetchSpotTypesData()) {
      _lastUpdated = DateTime.now();
      _spotTypeModel = _spotTypesService.spotTypeModel;

    } else {
      _error = _spotTypesService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  SpotTypeModel get spotTypeModel => _spotTypeModel;
}
