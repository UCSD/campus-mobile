import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
import 'package:campus_mobile_experimental/core/services/spot_types_service.dart';
import 'package:flutter/material.dart';

class SpotTypesDataProvider extends ChangeNotifier {
  SpotTypesDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    _spotTypeModel = SpotTypeModel();
    selected = 0;
  }

  ///SERVICES
  final SpotTypesService _spotTypesService = SpotTypesService();

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int selected;
  static const MAX_SELECTED = 3;
  Map<String, bool> _selectedSpotTypesState = <String, bool>{};

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

      for (Spot spot in _spotTypeModel.spots){
        _selectedSpotTypesState[spot.spotKey] = false;
      }
    } else {
      _error = _spotTypesService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleSpotSelection(String spotKey) {
    if (selected < MAX_SELECTED) {
      _selectedSpotTypesState[spotKey] = !_selectedSpotTypesState[spotKey];
      _selectedSpotTypesState[spotKey] ? selected++ : selected--;
    } else {
      //prevent select
      if (_selectedSpotTypesState[spotKey]) {
        selected--;
        _selectedSpotTypesState[spotKey] = !_selectedSpotTypesState[spotKey];
      }
    }
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  SpotTypeModel get spotTypeModel => _spotTypeModel;
  Map<String, bool> get spotTypesState => _selectedSpotTypesState;
}
