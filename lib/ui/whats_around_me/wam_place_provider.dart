import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_service.dart';
import 'package:flutter/material.dart';
/// TODO FIX
class PlaceDataProvider extends ChangeNotifier {
  PlaceDataProvider() {
    _isLoading = false;

    // Initialize Service
    _placeService = PlaceService();
    // Initialize Model
    _placeModel = PlacesByCategoryModel();
  }

  // STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  // Model
  PlacesByCategoryModel? _placeModel;

  // Service
  PlaceService? _placeService;

  void fetchPlace(String place) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _placeService!.fetchPlaceData(place)) {
      _placeModel = _placeService?.placeModel;
      _lastUpdated = DateTime.now();
    } else {
      _error = _placeService?.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  // SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  PlacesByCategoryModel? get placeModel => _placeModel;

}