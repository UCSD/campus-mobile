import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/parking.dart';
import 'package:campus_mobile_experimental/core/services/spot_types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ParkingGetX extends GetxController {
  UserDataProvider _userDataProvider = UserDataProvider();

  ///STATES
  Rx<bool> isLoading = false.obs;
  // DateTime? _lastUpdated;
  Rx<String?> error = null.obs;
  int selectedLots = 0, selectedSpots = 0;
  static const MAX_SELECTED_LOTS = 10;
  static const MAX_SELECTED_SPOTS = 3;
  // var rebuildParkingCard = null.obs;

  Rx<Map<String?, bool>?> parkingViewState =
      Rx<Map<String?, bool>?>(<String?, bool>{}.obs);
  Rx<Map<String?, bool>?> selectedSpotTypesState =
      Rx<Map<String?, bool>?>(<String?, bool>{}.obs);
  Rx<Map<String?, Spot>?> spotTypeMap =
      Rx<Map<String?, Spot>?>(<String?, Spot>{}.obs);

  // RxMap<String?, bool>? parkingViewState = <String?, bool>{}.obs;
  // RxMap<String?, bool>? selectedSpotTypesState = <String?, bool>{}.obs;
  // RxMap<String?, Spot>? spotTypeMap = <String?, Spot>{}.obs;

  ///MODELS
  Rx<Map<String?, ParkingModel>?> _parkingModels =
      Rx<Map<String?, ParkingModel>?>(<String?, ParkingModel>{}.obs);
  Rx<SpotTypeModel?> _spotTypeModel = SpotTypeModel().obs;

  ///SERVICES
  Rx<ParkingService> _parkingService = ParkingService().obs;
  late SpotTypesService _spotTypesService = SpotTypesService();

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchParkingData();
  }

  fetchParkingData() async {
    isLoading.value = true;
    selectedSpots = 0;
    selectedLots = 0;
    error.value = null;
    refresh();

    /// create a new map to ensure we remove all unsupported lots
    Map<String?, ParkingModel> newMapOfLots = Map<String?, ParkingModel>();
    Map<String?, bool> newMapOfLotStates = Map<String?, bool>();

    if (await _parkingService.value.fetchParkingLotData()) {
      if (_userDataProvider.userProfileModel!.selectedParkingLots!.isNotEmpty) {
        parkingViewState.value =
            _userDataProvider.userProfileModel!.selectedParkingLots;
      } else {
        for (ParkingModel model in _parkingService.value.data!) {
          if (ParkingDefaults.defaultLots.contains(model.locationId)) {
            parkingViewState.value![model.locationName] = true;
          } else {
            parkingViewState.value![model.locationName] = false;
          }
        }
      }

      for (ParkingModel model in _parkingService.value.data!) {
        newMapOfLots[model.locationName] = model;
        newMapOfLotStates[model.locationName] =
            (parkingViewState.value![model.locationName] == null
                ? false
                : parkingViewState.value![model.locationName])!;
      }

      ///replace old list of lots with new one
      _parkingModels.value = newMapOfLots;
      parkingViewState.value = newMapOfLotStates;

      //Update number of lots selected
      parkingViewState.value!.forEach((key, value) {
        if (value) {
          selectedLots++;
        }
      });
    } else {
      ///TODO: determine what error to show to the user
      error.value = _parkingService.value.error;
    }

    if (await _spotTypesService.fetchSpotTypesData()) {
      _spotTypeModel.value = _spotTypesService.spotTypeModel;
      //create map of spot types
      for (Spot spot in _spotTypeModel.value!.spots!) {
        spotTypeMap.value![spot.spotKey] = spot;
      }
      if (_userDataProvider
          .userProfileModel!.selectedParkingSpots!.isNotEmpty) {
        //Load selected spots types from user Profile
        selectedSpotTypesState.value =
            _userDataProvider.userProfileModel!.selectedParkingSpots;
      } else {
        //Load default spot types
        for (Spot spot in _spotTypeModel.value!.spots!) {
          if (ParkingDefaults.defaultSpots.contains(spot.spotKey)) {
            selectedSpotTypesState.value![spot.spotKey] = true;
          } else {
            selectedSpotTypesState.value![spot.spotKey] = false;
          }
        }
      }

      /// this block of code is to ensure we remove any unsupported spot types
      Map<String?, bool?> newMapOfSpotTypes = Map<String, bool>();
      for (Spot spot in _spotTypeModel.value!.spots!) {
        newMapOfSpotTypes[spot.spotKey] =
            selectedSpotTypesState.value![spot.spotKey];
      }
      selectedSpotTypesState.value = newMapOfSpotTypes.cast<String?, bool>();

      //Update number of spots selected
      selectedSpotTypesState.value!.forEach((key, value) {
        if (value) {
          selectedSpots++;
        }
      });
    } else {
      error.value = _spotTypesService.error;
    }

    // _lastUpdated = DateTime.now();

    isLoading.value = false;
    refresh();
  }

  ///RETURNS A List<ParkingModels> IN THE CORRECT ORDER
  List<ParkingModel> get parkingModels {
    if (_parkingModels.value != null) {
      return _parkingModels.value!.values.toList();
    }
    return [];
  }

  SpotTypeModel? get spotTypeModel {
    if (_spotTypeModel.value != null) {
      return _spotTypeModel.value;
    }
    return SpotTypeModel();
  }

// add or remove location availability display from card based on user selection, Limit to MAX_SELECTED
  void toggleLot(String? location, int numSelected) {
    selectedLots = numSelected;
    if (selectedLots < MAX_SELECTED_LOTS) {
      parkingViewState.value![location] = !parkingViewState.value![location]!;
      parkingViewState.value![location]! ? selectedLots++ : selectedLots--;
    } else {
      //prevent select
      if (parkingViewState.value![location]!) {
        selectedLots--;
        parkingViewState.value![location] = !parkingViewState.value![location]!;
      }
    }
    _userDataProvider.userProfileModel!.selectedParkingLots =
        parkingViewState.value;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    refresh();
  }

  void toggleSpotSelection(String? spotKey, int spotsSelected) {
    selectedSpots = spotsSelected;
    if (selectedSpots < MAX_SELECTED_SPOTS) {
      selectedSpotTypesState.value![spotKey] =
          !selectedSpotTypesState.value![spotKey]!;
      selectedSpotTypesState.value![spotKey]!
          ? selectedSpots++
          : selectedSpots--;
    } else {
      //prevent select
      if (selectedSpotTypesState.value![spotKey]!) {
        selectedSpots--;
        selectedSpotTypesState.value![spotKey] =
            !selectedSpotTypesState.value![spotKey]!;
      }
    }
    _userDataProvider.userProfileModel!.selectedParkingSpots =
        selectedSpotTypesState.value;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    refresh();
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// Returns the total number of spots open at a given location
  /// does not filter based on spot type
  Map<String, num> getApproxNumOfOpenSpots(String? locationId) {
    Map<String, num> totalAndOpenSpots = {"Open": 0, "Total": 0};
    if (_parkingModels.value![locationId] != null &&
        _parkingModels.value![locationId]!.availability != null) {
      for (dynamic spot
          in _parkingModels.value![locationId]!.availability!.keys) {
        if (_parkingModels.value![locationId]!.availability![spot]['Open'] !=
                null &&
            _parkingModels.value![locationId]!.availability![spot]['Open'] !=
                "") {
          totalAndOpenSpots["Open"] = totalAndOpenSpots["Open"]! +
              (_parkingModels.value![locationId]!.availability![spot]['Open']
                      is String
                  ? int.parse(_parkingModels
                      .value![locationId]!.availability![spot]['Open'])
                  : _parkingModels.value![locationId]!.availability![spot]
                      ['Open']);
        }

        if (_parkingModels.value![locationId]!.availability![spot]['Total'] !=
                null &&
            _parkingModels.value![locationId]!.availability![spot]['Total'] !=
                "") {
          totalAndOpenSpots["Total"] = totalAndOpenSpots["Total"]! +
              (_parkingModels.value![locationId]!.availability![spot]['Total']
                      is String
                  ? int.parse(_parkingModels
                      .value![locationId]!.availability![spot]['Total'])
                  : _parkingModels.value![locationId]!.availability![spot]
                      ['Total']);
        }
      }
    }
    return totalAndOpenSpots;
  }

  Map<String, List<String>> getParkingMap() {
    Map<String, List<String>> parkingMap = {};
    List<String> neighborhoodsToSort = [];
    for (ParkingModel model in _parkingService.value.data!) {
      neighborhoodsToSort.add(model.neighborhood!);
    }
    neighborhoodsToSort.sort();
    for (String neighborhood in neighborhoodsToSort) {
      List<String> val = [];
      parkingMap[neighborhood] = val;
    }

    for (ParkingModel model in _parkingService.value.data!) {
      parkingMap[model.neighborhood]!.add(model.locationName!);
    }
    return parkingMap;
  }

  List<String> getStructures() {
    List<String> structureMap = [];
    for (ParkingModel model in _parkingService.value.data!) {
      if (model.isStructure!) {
        structureMap.add(model.locationName!);
      }
    }
    return structureMap;
  }

  List<String> getLots() {
    List<String> lotMap = [];
    for (ParkingModel model in _parkingService.value.data!) {
      if (model.isStructure! == false) {
        lotMap.add(model.locationName!);
      }
    }
    return lotMap;
  }

  ///SIMPLE GETTERS
  // bool? get isLoading => _isLoading;
  // String? get error => _error;
  // DateTime? get lastUpdated => _lastUpdated;
  // Map<String?, bool>? get spotTypesState => _selectedSpotTypesState;
  // Map<String?, bool>? get parkingViewState => _parkingViewState;
  // Map<String?, Spot?>? get spotTypeMap => _spotTypeMap;
// SpotTypeModel? get spotTypeModel => _spotTypeModel;
}
