import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/location_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/services/shuttle_service.dart';

class ShuttleDataProvider extends ChangeNotifier {
  ShuttleDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// TODO: initialize services here
    _shuttleService = ShuttleService();
  }

  bool _isLoading;
  String _error;
  UserDataProvider _userDataProvider;
  ShuttleService _shuttleService;
  LocationDataProvider _locationDataProvider;

  Map<String, ShuttleModel> _shuttleModels;

  void fetchShuttles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _shuttleService.fetchData();
    // create new map of shuttles to display
    Map<String, ShuttleModel> newMapOfShuttles = Map<String, ShuttleModel>();

    // get closest stop to current user


  }
}

