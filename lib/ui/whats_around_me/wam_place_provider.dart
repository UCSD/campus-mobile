import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_model.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_service.dart';
import 'package:flutter/material.dart';

class PlaceDataProvider extends ChangeNotifier {
  PlaceDataProvider() {
    _isLoading = false;

    // Initialize Service
    _placeService = PlaceService();
    // Initialize Model
    _placeModel = PlaceModel();
  }

  // STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  // Model
  PlaceModel? _placeModel;

  // Service
  PlaceService? _placeService;

  void fetchPlace() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _placeService!.fetchData()) {
      _placeModel = _placeService?.placeModel;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _placeService?.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  PlaceModel? get placeModel => _placeModel;

}