import 'dart:math';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/services/dining.dart';
import 'package:flutter/material.dart';

enum Meal { breakfast, lunch, dinner }

class DiningDataProvider extends ChangeNotifier {
  DiningDataProvider() {
    DiningConstants.payment_filter_types
        .forEach((type) => _diningFilterTypeStates[type] = true);
  }

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  Coordinates? _coordinates;
  Meal mealTime = Meal.breakfast;
  Map<String, bool> _diningFilterTypeStates = {};

  /// MODELS
  Map<String, DiningModel> _diningModels = {};
  Map<String, DiningModel> _diningFilteredModels = {};

  /// SERVICES
  var _diningService = DiningService();

  void fetchDiningLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    Map<String, DiningModel> mapOfDiningLocations = {};

    if (await _diningService.fetchData()) {
      for (DiningModel model in _diningService.data) {
        _fixImageUrls(model);
        mapOfDiningLocations[model.name] = model;
      }
      _diningModels = mapOfDiningLocations;
      populateDistances();
      _lastUpdated = DateTime.now();
    } else {
      _error = _diningService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateFilteredDiningModels() {
    _diningFilteredModels = {
      for (var dining in diningModels)
        if (dining.paymentFilterTypes
            .split(',')
            .map((type) => type.trim())
            .any((type) => _diningFilterTypeStates[type] == true))
          dining.name: dining
    };
    notifyListeners();
  }

  void toggleFilterType(String type) {
    _diningFilterTypeStates[type] = !_diningFilterTypeStates[type]!;
    notifyListeners();
  }

  void _fixImageUrls(DiningModel model) {
    if (model.images != null) {
      for (var img in model.images!) {
        img.small = img.small?.replaceAll('http://hdh-web.ucsd.edu/images', '');
        img.large = img.large?.replaceAll('http://hdh-web.ucsd.edu/images', '');
      }
    }
  }

  List<DiningModel> reorderLocations() {
    if (_coordinates == null) return _diningModels.values.toList();
    List<DiningModel> orderedListOfLots = _diningModels.values.toList();
    orderedListOfLots.sort((DiningModel a, DiningModel b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return 0;
    });
    return orderedListOfLots;
  }

  void populateDistances() {
    if (_coordinates != null &&
        _coordinates!.lat != null &&
        _coordinates!.lon != null) {
      for (DiningModel model in _diningModels.values.toList()) {
        if (model.coordinates != null) {
          var distance = calculateDistance(
              _coordinates!.lat!,
              _coordinates!.lon!,
              model.coordinates!.lat!,
              model.coordinates!.lon!);
          model.distance = distance.toDouble();
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

  /// SIMPLE SETTERS
  /// This setter is only used in provider to supply an updated Coordinates object
  set coordinates(Coordinates value) => _coordinates = value;

  /// RETURNS A List<diningModels> sorted by distance
  List<DiningModel> get diningModels {
    /// check if we have a coordinates object
    if (_coordinates != null) return reorderLocations();
    return _diningModels.values.toList();
  }

  List<DiningModel> get filteredDiningModels {
    /// If all or no filters are selected, then return diningModels
    if (!_diningFilterTypeStates.values.contains(true) ||
        _diningFilterTypeStates.values.every((f) => f)) {
      return diningModels;
    }

    /// If filters have changed, update filtered dining models
    /// so it contains only dining models that match the selected filters
    updateFilteredDiningModels();

    /// then (or else) return filtered dining models
    return _diningFilteredModels.values.toList();
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  Map<String, bool> get diningFilterTypeStates => _diningFilterTypeStates;
}
