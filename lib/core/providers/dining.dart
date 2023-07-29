import 'dart:math';

import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/services/dining.dart';
import 'package:flutter/material.dart';

class DiningDataProvider extends ChangeNotifier {

  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  Map<String?, DiningModel> _diningModels = Map<String, DiningModel>();
  Coordinates? _coordinates;

  ///SERVICES
  DiningService _diningService = DiningService();

  void fetchDiningLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// creating  new map ensures we remove all unsupported locations
    Map<String?, DiningModel> mapOfDiningLocations =
        Map<String?, DiningModel>();
    if (await _diningService.fetchData()) {
      for (DiningModel model in _diningService.data!) {
        mapOfDiningLocations[model.name] = model;
      }

      ///replace old list of locations with new one
      _diningModels = mapOfDiningLocations;

      ///calculate distance of each eatery to user's current location
      populateDistances();
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _diningService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void populateDistances() {
    if (_coordinates != null) {
      for (DiningModel model in _diningModels.values.toList()) {
        if (model.coordinates != null &&
            _coordinates!.lat != null &&
            _coordinates!.lon != null) {
          var distance = calculateDistance(
              _coordinates!.lat ?? 0.0,
              _coordinates!.lon ?? 0.0,
              model.coordinates!.lat ?? 0.0,
              model.coordinates!.lon ?? 0.0);
          model.distance = distance as double?;
        } else {
          model.distance = null;
        }
      }
    }
  }

  num calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 0.621371;
  }

  ///This setter is only used in provider to supply an updated Coordinates object
  set coordinates(Coordinates value) {
    _coordinates = value;
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  //Transition getters
  Coordinates? getCoordinates() {
    return _coordinates;
  }
}
