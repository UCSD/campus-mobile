import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_service.dart';
import 'package:flutter/material.dart';

class PlacesByCategoryProvider extends ChangeNotifier {
  // Instance Variables
  late PlacesByCategoryService _placesByCategoryService;
  List<Category>? _categoriesAroundMe;
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  // Constructor
  PlacesByCategoryProvider() {
    _isLoading = false;
    _placesByCategoryService = PlacesByCategoryService();
  }

  // Fetch Place Details given the placeId
  Future<void> fetchWhatsAroundYou() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try{
      await _placesByCategoryService.fetchPlacesByCategory();
      _categoriesAroundMe = _placesByCategoryService.placesByCategoryData!.categories;
    }
    catch(error) {
      _error = _placesByCategoryService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Getters
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<Category>? get categoriesAroundMe => _categoriesAroundMe;
}
