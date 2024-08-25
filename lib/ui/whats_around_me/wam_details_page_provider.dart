import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page_model.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page_service.dart';
import 'package:flutter/material.dart';

class PlaceDetailsProvider extends ChangeNotifier {
  // Instance Variables
  /// SERVICE
  late PlaceDetailsService _placeDetailsService;
  /// MODEL
  late PlaceDetailsModel _placeDetailsModel;
  /// STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  // Constructor
  PlaceDetailsProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// INITIALIZE PLACE DETAILS SERVICE
    _placeDetailsService = PlaceDetailsService();

    /// INITIALIZE PLACE DETAILS MODEL
    _placeDetailsModel = PlaceDetailsModel();
  }

  // Fetch Place Details given the placeId i.e. bd5f5dfa788b7c5f59f3bfe2cc3d9c60
  void fetchPlaceDetails(placeId) async {
    // Update fetch status
    _isLoading = true;
    _error = null;
    notifyListeners();
    // Call Service to perform API call to Place Details API
    if (await _placeDetailsService.fetchPlaceDetails(placeId)) {
      _placeDetailsModel = _placeDetailsService.placeDetailsData!;
      _lastUpdated = DateTime.now();
    } else {
      _error = _placeDetailsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  PlaceDetailsModel get placeDetailsModelData => _placeDetailsModel;
}
