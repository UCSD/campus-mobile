import 'package:campus_mobile_experimental/ui/whats_around_me/wam_location_name_address_model.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_location_name_address_service.dart';
import 'package:flutter/material.dart';

class LocationNameAddressDataProvider extends ChangeNotifier {
  LocationNameAddressDataProvider() {
    _isLoading = false;

    // Initialize Service
    _locationNameAddressService = LocationNameAddressService();
    // Initialize Model
    _locationNameAddressModel = LocationNameAddressModel();
  }

  // STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  // Model
  LocationNameAddressModel? _locationNameAddressModel;

  // Service
  LocationNameAddressService? _locationNameAddressService;

  void fetchLocationNameAddress() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _locationNameAddressService!.fetchData()) {
      _locationNameAddressModel = _locationNameAddressService?.locationNameAddressModel;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _locationNameAddressService?.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  LocationNameAddressModel? get locationNameAddressModel => _locationNameAddressModel;

}