import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/parking.dart';
import 'package:campus_mobile_experimental/core/services/spot_types.dart';
import 'package:flutter/material.dart';

class ParkingDataProvider extends ChangeNotifier {
  ParkingDataProvider()
      : selectedLots = 0,
        selectedSpots = 0 {
    ///DEFAULT STATES
    _isLoading = false;

    _parkingService = ParkingService();
    _spotTypesService = SpotTypesService();
  }

  late UserDataProvider _userDataProvider;

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  int selectedLots, selectedSpots;
  static const MAX_SELECTED_LOTS = 10;
  static const MAX_SELECTED_SPOTS = 3;
  Map<String?, bool>? _parkingViewState = <String?, bool>{};
  Map<String?, bool>? _selectedSpotTypesState = <String?, bool>{};
  Map<String?, Spot>? _spotTypeMap = <String?, Spot>{};

  ///MODELS
  Map<String?, ParkingModel>? _parkingModels;
  SpotTypeModel? _spotTypeModel;

  ///SERVICES
  late ParkingService _parkingService;
  late SpotTypesService _spotTypesService;

  void fetchParkingData() async {
    _isLoading = true;
    selectedSpots = 0;
    selectedLots = 0;
    _error = null;
    notifyListeners();

    /// create a new map to ensure we remove all unsupported lots
    Map<String?, ParkingModel> newMapOfLots = Map<String?, ParkingModel>();
    Map<String?, bool> newMapOfLotStates = Map<String?, bool>();

    if (await _parkingService.fetchParkingLotData()) {
      if (_userDataProvider.userProfileModel!.selectedParkingLots!.isNotEmpty) {
        _parkingViewState =
            _userDataProvider.userProfileModel!.selectedParkingLots;
      } else {
        for (ParkingModel model in _parkingService.data!) {
          if (ParkingDefaults.defaultLots.contains(model.locationId)) {
            _parkingViewState![model.locationName] = true;
          } else {
            _parkingViewState![model.locationName] = false;
          }
        }
      }

      for (ParkingModel model in _parkingService.data!) {
        newMapOfLots[model.locationName] = model;
        newMapOfLotStates[model.locationName] =
            (_parkingViewState![model.locationName] == null
                ? false
                : _parkingViewState![model.locationName])!;
      }

      ///replace old list of lots with new one
      _parkingModels = newMapOfLots;
      _parkingViewState = newMapOfLotStates;

      //Update number of lots selected
      _parkingViewState!.forEach((key, value) {
        if (value) {
          selectedLots++;
        }
      });
    } else {
      ///TODO: determine what error to show to the user
      _error = _parkingService.error;
    }

    if (await _spotTypesService.fetchSpotTypesData()) {
      _spotTypeModel = _spotTypesService.spotTypeModel;
      //create map of spot types
      for (Spot spot in _spotTypeModel!.spots!) {
        _spotTypeMap![spot.spotKey] = spot;
      }
      if (_userDataProvider
          .userProfileModel!.selectedParkingSpots!.isNotEmpty) {
        //Load selected spots types from user Profile
        _selectedSpotTypesState =
            _userDataProvider.userProfileModel!.selectedParkingSpots;
      } else {
        //Load default spot types
        for (Spot spot in _spotTypeModel!.spots!) {
          if (ParkingDefaults.defaultSpots.contains(spot.spotKey)) {
            _selectedSpotTypesState![spot.spotKey] = true;
          } else {
            _selectedSpotTypesState![spot.spotKey] = false;
          }
        }
      }

      /// this block of code is to ensure we remove any unsupported spot types
      Map<String?, bool?> newMapOfSpotTypes = Map<String, bool>();
      for (Spot spot in _spotTypeModel!.spots!) {
        newMapOfSpotTypes[spot.spotKey] =
            _selectedSpotTypesState![spot.spotKey];
      }
      _selectedSpotTypesState = newMapOfSpotTypes.cast<String?, bool>();

      //Update number of spots selected
      _selectedSpotTypesState!.forEach((key, value) {
        if (value) {
          selectedSpots++;
        }
      });
    } else {
      _error = _spotTypesService.error;
    }

    _lastUpdated = DateTime.now();

    _isLoading = false;
    notifyListeners();
  }

  ///RETURNS A List<ParkingModels> IN THE CORRECT ORDER
  List<ParkingModel> get parkingModels {
    if (_parkingModels != null) {
      return _parkingModels!.values.toList();
    }
    return [];
  }

  SpotTypeModel? get spotTypeModel {
    if (_spotTypeModel != null) {
      return _spotTypeModel;
    }
    return SpotTypeModel();
  }

// add or remove location availability display from card based on user selection, Limit to MAX_SELECTED
  void toggleLot(String? location, int numSelected) {
    selectedLots = numSelected;
    if (selectedLots < MAX_SELECTED_LOTS) {
      _parkingViewState![location] = !_parkingViewState![location]!;
      _parkingViewState![location]! ? selectedLots++ : selectedLots--;
    } else {
      //prevent select
      if (_parkingViewState![location]!) {
        selectedLots--;
        _parkingViewState![location] = !_parkingViewState![location]!;
      }
    }
    _userDataProvider.userProfileModel!.selectedParkingLots = _parkingViewState;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  void toggleSpotSelection(String? spotKey, int spotsSelected) {
    selectedSpots = spotsSelected;
    if (selectedSpots < MAX_SELECTED_SPOTS) {
      _selectedSpotTypesState![spotKey] = !_selectedSpotTypesState![spotKey]!;
      _selectedSpotTypesState![spotKey]! ? selectedSpots++ : selectedSpots--;
    } else {
      //prevent select
      if (_selectedSpotTypesState![spotKey]!) {
        selectedSpots--;
        _selectedSpotTypesState![spotKey] = !_selectedSpotTypesState![spotKey]!;
      }
    }
    _userDataProvider.userProfileModel!.selectedParkingSpots =
        _selectedSpotTypesState;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// Returns the total number of spots open at a given location
  /// does not filter based on spot type
  Map<String, num> getApproxNumOfOpenSpots(String? locationId) {
    Map<String, num> totalAndOpenSpots = {"Open": 0, "Total": 0};
    if (_parkingModels![locationId] != null &&
        _parkingModels![locationId]!.availability != null) {
      for (dynamic spot in _parkingModels![locationId]!.availability!.keys) {
        if (_parkingModels![locationId]!.availability![spot]['Open'] != null &&
            _parkingModels![locationId]!.availability![spot]['Open'] != "") {
          totalAndOpenSpots["Open"] = totalAndOpenSpots["Open"]! +
              (_parkingModels![locationId]!.availability![spot]['Open']
                      is String
                  ? int.parse(
                      _parkingModels![locationId]!.availability![spot]['Open'])
                  : _parkingModels![locationId]!.availability![spot]['Open']);
        }

        if (_parkingModels![locationId]!.availability![spot]['Total'] != null &&
            _parkingModels![locationId]!.availability![spot]['Total'] != "") {
          totalAndOpenSpots["Total"] = totalAndOpenSpots["Total"]! +
              (_parkingModels![locationId]!.availability![spot]['Total']
                      is String
                  ? int.parse(
                      _parkingModels![locationId]!.availability![spot]['Total'])
                  : _parkingModels![locationId]!.availability![spot]['Total']);
        }
      }
    }
    return totalAndOpenSpots;
  }

  Map<String, List<String>> getParkingMap() {
    Map<String, List<String>> parkingMap = {};
    List<String> neighborhoodsToSort = [];
    for (ParkingModel model in _parkingService.data!) {
      neighborhoodsToSort.add(model.neighborhood!);
    }
    print(neighborhoodsToSort);
    neighborhoodsToSort.sort();
    print(neighborhoodsToSort);
    for (String neighborhood in neighborhoodsToSort) {
      List<String> val = [];
      parkingMap[neighborhood] = val;
    }

    for (ParkingModel model in _parkingService.data!) {
      parkingMap[model.neighborhood]!.add(model.locationName!);
    }
    return parkingMap;
  }

  List<String> getStructures() {
    List<String> structureMap = [];
    for (ParkingModel model in _parkingService.data!) {
      if (model.isStructure!) {
        structureMap.add(model.locationName!);
      }
    }
    return structureMap;
  }

  List<String> getLots() {
    List<String> lotMap = [];
    for (ParkingModel model in _parkingService.data!) {
      if (model.isStructure! == false) {
        lotMap.add(model.locationName!);
      }
    }
    return lotMap;
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  Map<String?, bool>? get spotTypesState => _selectedSpotTypesState;
  Map<String?, bool>? get parkingViewState => _parkingViewState;
  Map<String?, Spot?>? get spotTypeMap => _spotTypeMap;
  // SpotTypeModel? get spotTypeModel => _spotTypeModel;
}
