import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/services/ventilation.dart';
import 'package:flutter/material.dart';

class VentilationDataProvider extends ChangeNotifier {
  VentilationDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _ventilationService = VentilationService();
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  Map<String?, VentilationLocationsModel> _ventilationLocationsModel =
      Map<String, VentilationLocationsModel>();
  Map<String, VentilationModel?> _ventilationModel =
      Map<String, VentilationModel?>();

  ///SERVICES
  late VentilationService _ventilationService;

  void fetchVentilationData(String bfrID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _ventilationService.fetchData(bfrID)) {
      _ventilationModel[bfrID] = _ventilationService.data;
    } else {
      _error = _ventilationService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void fetchVentilationLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    Map<String?, VentilationLocationsModel> mapOfVentialtionLocations =
        Map<String?, VentilationLocationsModel>();

    if (await _ventilationService.fetchLocations()) {
      for (VentilationLocationsModel model
          in _ventilationService.locationData!) {
        mapOfVentialtionLocations[model.buildingName] = model;
      }

      _ventilationLocationsModel = mapOfVentialtionLocations;
    } else {
      _error = _ventilationService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  // void fetchDiningLocations() async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  //
  //   /// creating  new map ensures we remove all unsupported locations
  //   Map<String?, DiningModel> mapOfDiningLocations =
  //       Map<String?, DiningModel>();
  //   if (await _diningService.fetchData()) {
  //     for (DiningModel model in _diningService.data!) {
  //       mapOfDiningLocations[model.name] = model;
  //     }
  //
  //     ///replace old list of locations with new one
  //     _diningModels = mapOfDiningLocations;
  //
  //     ///calculate distance of each eatery to user's current location
  //     populateDistances();
  //     _lastUpdated = DateTime.now();
  //   } else {
  //     ///TODO: determine what error to show to the user
  //     _error = _diningService.error;
  //   }
  //   _isLoading = false;
  //   notifyListeners();
  // }

  // List<DiningModel> reorderLocations() {
  //   if (_coordinates == null) {
  //     return _diningModels.values.toList();
  //   }
  //   List<DiningModel> orderedListOfLots = _diningModels.values.toList();
  //   orderedListOfLots.sort((DiningModel a, DiningModel b) {
  //     if (a.distance != null && b.distance != null) {
  //       return a.distance!.compareTo(b.distance!);
  //     }
  //     return 0;
  //   });
  //   return orderedListOfLots;
  // }

  // void populateDistances() {
  //   if (_coordinates != null) {
  //     for (DiningModel model in _diningModels.values.toList()) {
  //       if (model.coordinates != null &&
  //           _coordinates!.lat != null &&
  //           _coordinates!.lon != null) {
  //         var distance = calculateDistance(
  //             _coordinates!.lat ?? 0.0,
  //             _coordinates!.lon ?? 0.0,
  //             model.coordinates!.lat ?? 0.0,
  //             model.coordinates!.lon ?? 0.0);
  //         model.distance = distance as double?;
  //       } else {
  //         model.distance = null;
  //       }
  //     }
  //   }
  // }

  // num calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  //   var p = 0.017453292519943295;
  //   var c = cos;
  //   var a = 0.5 -
  //       c((lat2 - lat1) * p) / 2 +
  //       c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  //   return 12742 * asin(sqrt(a)) * 0.621371;
  // }

  // ///This setter is only used in provider to supply an updated Coordinates object
  // set coordinates(Coordinates value) {
  //   _coordinates = value;
  // }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  // List<VentilationLocationsModel> getVentilationLocations() {
  //   return _ventilationLocationsModel.values.toList();
  // }

  /// Returns menu data for given id
  /// Fetches menu if not already downloaded
  VentilationModel? getVentilationData(String? id) {
    if (id != null) {
      if (_ventilationModel[id] != null) {
        return _ventilationModel[id];
      } else {
        fetchVentilationData(id);
      }
    }
    return VentilationModel();
  }

  ///RETURNS A List<diningModels> sorted by distance
  List<VentilationLocationsModel> get ventilationLocationModels {
    ///check if we have a coordinates object
    return _ventilationLocationsModel.values.toList();
  }
  // List<MenuItem>? getMenuItems(String? id, List<String> filters) {
  //   List<MenuItem>? menuItems;
  //   if (_diningMenuItemModels[id!] == null) {
  //     return null;
  //   } else {
  //     menuItems = _diningMenuItemModels[id]!.menuItems;
  //   }
  //   List<MenuItem> filteredMenuItems = [];
  //   for (var menuItem in menuItems!) {
  //     int matched = 0;
  //     for (int i = 0; i < filters.length; i++) {
  //       if (menuItem.tags!.contains(filters[i])) {
  //         matched++;
  //       }
  //     }
  //     if (matched == filters.length) {
  //       filteredMenuItems.add(menuItem);
  //     }
  //   }
  //   return filteredMenuItems;
  // }

  // ///RETURNS A List<diningModels> sorted by distance
  // List<DiningModel> get diningModels {
  //   ///check if we have a coordinates object
  //   if (_coordinates != null) {
  //     return reorderLocations();
  //   }
  //   return _diningModels.values.toList();
  // }
}
