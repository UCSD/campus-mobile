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

  void fetchDiningMenu(String menuId) async {
    _isLoading = true; _error = null;
    notifyListeners();
    if (await _diningService.fetchMenu(menuId)) {
      _diningMenuItemModels[menuId] = _diningService.menuData!;
    } else {
      _error = _diningService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void fetchDiningLocations() async {
    final diningLogosEndpoint = "https://cdn.ucsd.edu/dining-logos/";
    final List<String> diningLogos = [
      "art-of-espresso.png",
      "audreys.png",
      "blue-bowl.png",
      "blue-wave-bistro.png",
      "canyon-vista-marketplace.png",
      "carlolines.png",
      "club-med.png",
      "crafted.png",
      "destiny-coast.png",
      "fan-fan.png",
      "faculty-club.png",
      "foodworx.png",
      "gong-cha.png",
      "james-place.png",
      "johns.png",
      "market-at-sixth.png",
      "ocean-view.png",
      "pacific-cafe.png",
      "pines.png",
      "plant-power.png",
      "restaurants-at-sixth.png",
      "rogers-market.png",
      "roots.png",
      "sixth-market.png",
      "sixty-four-degrees.png",
      "street-corner.png",
      "sunshine-market.png",
      "tahini.png",
      "the-bistro.png",
      "ventanas.png",
      "verdeli.png",
    ];

    _isLoading = true; _error = null;
    notifyListeners();
    Map<String, DiningModel> mapOfDiningLocations = {};

    /// fetch dining locations from the service
    if (await _diningService.fetchData()) {
      for (DiningModel model in _diningService.data) {
        // Fix the image URLs
        if (model.images != null) {
          for (var img in model.images!) {
            img.small = img.small?.replaceAll('http://hdh-web.ucsd.edu/images', '');
            img.large = img.large?.replaceAll('http://hdh-web.ucsd.edu/images', '');
          }
        }
        ///////////// Map vendor with its logo /////////////
        for (var i = 0; i < diningLogos.length; i++) {
          // Normalize model name and logo names to check...
          final modelName = normalize(model.name);
          final logoName = normalize(diningLogos[i].split('.')[0]);
          // ...if logo name is a substring of the model name
          if (modelName.contains(logoName)) {
            model.vendorLogo = diningLogosEndpoint + diningLogos[i];
            print('Found logo for ${model.name}: ${model.vendorLogo}');
            break;
          }
        }

        // Special Cases
        if(model.name == '64 Degrees') {
          model.vendorLogo = diningLogosEndpoint + "sixty-four-degrees.png";
        }
        if(model.name == 'Pacific Café & Catering') {
          model.vendorLogo = diningLogosEndpoint + "pacific-cafe.png";
        }
        if(model.name == 'Caroline\'s Seaside Cafe') {
          model.vendorLogo = diningLogosEndpoint + "carlolines.png";
        }

        // Save the data
        mapOfDiningLocations[model.name] = model;
      }

      /// replace old list of locations with new one
      _diningModels = mapOfDiningLocations;

      /// calculate distance of each eatery to user's current location
      populateDistances();
      _lastUpdated = DateTime.now();
    } else {
      /// TODO: determine what error to show to the user
      _error = _diningService.error;
    }
    _isLoading = false;
    notifyListeners();
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
    // TODO: fix the Coordinates system! Totally messed up design
    if (_coordinates != null && _coordinates!.lat != null && _coordinates!.lon != null) {
      for (DiningModel model in _diningModels.values.toList()) {
        if (model.coordinates != null) {
          var distance = calculateDistance(
              _coordinates!.lat!,
              _coordinates!.lon!,
              model.coordinates!.lat!,
              model.coordinates!.lon!
          );
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

  /// Returns menu data for a given id
  /// Fetches menu if not already downloaded
  DiningMenuItemsModel? getMenuData(String? id) {
    if (id != null && _diningMenuItemModels.containsKey(id)) {
      return _diningMenuItemModels[id];
    } else if (id != null) {
      fetchDiningMenu(id);
    }
    return null;
  }

  List<DiningMenuItem>? getMenuItems(String? id, List<String> filters) {
    List<DiningMenuItem>? menuItems;
    if (id != null && _diningMenuItemModels[id] != null) {
      menuItems = _diningMenuItemModels[id]!.menuItems;
    }
    List<DiningMenuItem> filteredMenuItems = [];
    if (menuItems != null) {
      for (var menuItem in menuItems) {
        var matched = 0;
        for (var i = 0; i < filters.length; i++) {
          if (menuItem.tags.contains(filters[i])) matched++;
        }
        if (matched == filters.length) filteredMenuItems.add(menuItem);
      }
    }
    return filteredMenuItems;
  }

  /// RETURNS A List<diningModels> sorted by distance
  List<DiningModel> get diningModels {
    /// check if we have a coordinates object
    if (_coordinates != null) return reorderLocations();
    return _diningModels.values.toList();
  }

  /// Removes apostrophes and non-alphanumeric characters
  String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"['’]"), '')       // remove apostrophes
        .replaceAll(RegExp(r"[^a-z0-9]"), ''); // remove all non-alphanumeric
  }

  /// SIMPLE SETTERS
  /// This setter is only used in provider to supply an updated Coordinates object
  set coordinates(Coordinates value) => _coordinates = value;

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
}
