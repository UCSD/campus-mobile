import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_service.dart';
import 'package:flutter/material.dart';

class PlacesByCategoryProvider extends ChangeNotifier {
  // Instance Variables
  late PlacesByCategoryService _placesByCategoryService;
  final Map<String, List<Result>> _placesByCategory = {}; // Where all places are going to be
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  // Constructor
  PlacesByCategoryProvider() {
    _isLoading = false;
    _placesByCategoryService = PlacesByCategoryService();
  }

  // Fetch Place Details given the placeId
  Future<void> fetchPlacesByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = await _placesByCategoryService.fetchPlacesByCategory(categoryId);
    if (success) {
      _placesByCategory[categoryId] = _placesByCategoryService.placesByCategoryData?.results ?? [];
    } else {
      _error = _placesByCategoryService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Getters
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<Result>? getPlacesByCategory(String categoryId) => _placesByCategory[categoryId];
}

// class PlacesByCategoryProvider extends ChangeNotifier {
//   // Instance Variables
//   /// SERVICE
//   late PlacesByCategoryService _placesByCategoryService;
//   /// MODEL
//   late PlacesByCategoryModel _placesByCategoryModel;
//   /// STATES
//   bool? _isLoading;
//   DateTime? _lastUpdated;
//   String? _error;
//
//   // Constructor
//   PlacesByCategoryProvider() {
//     /// DEFAULT STATES
//     _isLoading = false;
//
//     /// INITIALIZE PLACE DETAILS SERVICE
//     _placesByCategoryService = PlacesByCategoryService();
//
//     /// INITIALIZE PLACE DETAILS MODEL
//     _placesByCategoryModel = PlacesByCategoryModel();
//   }
//
//   // Fetch Place Details given the placeId i.e. 13065 (restaurants)
//   void fetchPlacesByCategory(categoryId) async {
//     // Update fetch status
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//     // Call Service to perform API call to Place Details API
//     if (await _placesByCategoryService.fetchPlacesByCategory(categoryId)) {
//       _placesByCategoryModel = _placesByCategoryService.placesByCategoryData!;  // PlacesByCategoryData is inside service which is inside model which is inside "Results"
//       _lastUpdated = DateTime.now();
//     } else {
//       _error = _placesByCategoryService.error;
//     }
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   /// SIMPLE GETTERS
//   bool? get isLoading => _isLoading;
//   String? get error => _error;
//   DateTime? get lastUpdated => _lastUpdated;
//   PlacesByCategoryModel get placeDetailsModelData => _placesByCategoryModel; // traces all the way back to "Results"
// }