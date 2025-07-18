import 'dart:math';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/services/dining.dart';
import 'package:flutter/material.dart';

enum Meal { breakfast, lunch, dinner }

class DiningDataProvider extends ChangeNotifier {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  Coordinates? _coordinates;
  Meal mealTime = Meal.breakfast;
  List<bool> filtersSelected = [false, false, false];

  /// MODELS
  Map<String, DiningModel> _diningModels = {};
  Map<String, DiningMenuItemsModel> _diningMenuItemModels = {};

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

      // ─── LOGO-FILENAME DUMP ──────────────────────────────────────────
      final logos = _diningModels.values
        .where((m) => m.vendorLogo != null)
        .map((m) => Uri.parse(m.vendorLogo!).pathSegments.last)
        .toSet()      // remove duplicates
        .toList()
      ..sort();      // alphabetical
      debugPrint('🖼️ Expected vendor logos: $logos');
      // ─────────────────────────────────────────────────────────────────

      populateDistances();
      _lastUpdated = DateTime.now();
    } else {
      _error = _diningService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _fixImageUrls(DiningModel model) {
    if (model.images != null) {
      for (var img in model.images!) {
        img.small = img.small
            ?.replaceAll('http://hdh-web.ucsd.edu/images', '');
        img.large = img.large
            ?.replaceAll('http://hdh-web.ucsd.edu/images', '');
      }
    }
  }

  List<DiningModel> reorderLocations() {
    if (_coordinates == null) return _diningModels.values.toList();
    List<DiningModel> orderedListOfLots = _diningModels.values.toList();
    orderedListOfLots.sort((a, b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return 0;
    });
    return orderedListOfLots;
  }

  void populateDistances() {
    // TODO: fix the Coordinates system! Totally messed up design
    if (_coordinates != null &&
        _coordinates!.lat != null &&
        _coordinates!.lon != null) {
      for (DiningModel model in _diningModels.values) {
        if (model.coordinates != null) {
          var distance = calculateDistance(
            _coordinates!.lat!,
            _coordinates!.lon!,
            model.coordinates!.lat!,
            model.coordinates!.lon!,
          );
          model.distance = distance.toDouble();
        } else {
          model.distance = null;
        }
      }
    }
  }

  num calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 0.621371;
  }

  /// RETURNS A List<diningModels> sorted by distance
  List<DiningModel> get diningModels {
    if (_coordinates != null) return reorderLocations();
    return _diningModels.values.toList();
  }

  /// SIMPLE SETTERS
  set coordinates(Coordinates value) => _coordinates = value;

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
}