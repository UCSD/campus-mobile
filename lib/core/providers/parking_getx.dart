import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/parking.dart';
import 'package:campus_mobile_experimental/core/services/spot_types.dart';
import 'package:get/get.dart';

class ParkingGetX extends GetxController {
  UserDataProvider _userDataProvider = UserDataProvider();

  ///STATES
  // Observables for tracking loading state, error state, and selection counts
  Rx<bool> _isLoading = false.obs;
  Rxn<String> _error = Rxn<String>();
  Rxn<DateTime> _lastUpdated = Rxn<DateTime>();
  int selectedLots = 0, selectedSpots = 0;

  // Constants for maximum allowed selections
  static const MAX_SELECTED_LOTS = 10;
  static const MAX_SELECTED_SPOTS = 3;

  // Observables for managing parking view state, selected spot types state, and spot type map
  Rx<Map<String?, bool>?> _parkingViewState =
      Rx<Map<String?, bool>?>(<String?, bool>{}.obs);
  Rx<Map<String?, bool>?> _selectedSpotTypesState =
      Rx<Map<String?, bool>?>(<String?, bool>{}.obs);
  Rx<Map<String?, Spot>?> _spotTypeMap =
      Rx<Map<String?, Spot>?>(<String?, Spot>{}.obs);

  ///MODELS
  // Observable for storing parking models
  Rx<Map<String?, ParkingModel>?> _parkingModels =
      Rx<Map<String?, ParkingModel>?>(<String?, ParkingModel>{}.obs);
  // Observable for storing spot type model
  Rx<SpotTypeModel?> _spotTypeModel = SpotTypeModel().obs;

  ///SERVICES
  // Observable for parking service
  Rx<ParkingService> _parkingService = ParkingService().obs;
  // Spot types service
  late SpotTypesService _spotTypesService = SpotTypesService();

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchParkingData();
  }

  // Fetch parking data from services
  void fetchParkingData() async {
    _isLoading.value = true;
    selectedSpots = 0;
    selectedLots = 0;
    _error.value = null;
    refresh();

    // Create new maps to ensure we remove all unsupported lots and spot types
    Map<String?, ParkingModel> newMapOfLots = Map<String?, ParkingModel>();
    Map<String?, bool> newMapOfLotStates = Map<String?, bool>();

    // Fetch parking lot data
    if (await _parkingService.value.fetchParkingLotData()) {
      // Populate parking view state from user profile or default lots
      if (_userDataProvider.userProfileModel!.selectedParkingLots!.isNotEmpty) {
        _parkingViewState.value =
            _userDataProvider.userProfileModel!.selectedParkingLots;
      } else {
        for (ParkingModel model in _parkingService.value.data!) {
          if (ParkingDefaults.defaultLots.contains(model.locationId)) {
            _parkingViewState.value![model.locationName] = true;
          } else {
            _parkingViewState.value![model.locationName] = false;
          }
        }
      }

      // Populate new maps of lots and their states
      for (ParkingModel model in _parkingService.value.data!) {
        newMapOfLots[model.locationName] = model;
        newMapOfLotStates[model.locationName] =
            (_parkingViewState.value![model.locationName] == null
                ? false
                : _parkingViewState.value![model.locationName])!;
      }

      // Replace old list of lots with new one
      _parkingModels.value = newMapOfLots;
      _parkingViewState.value = newMapOfLotStates;

      // Update number of lots selected
      _parkingViewState.value!.forEach((key, value) {
        if (value) {
          selectedLots++;
        }
      });
    } else {
      // Handle parking service error
      _error.value = _parkingService.value.error;
    }

    // Fetch spot types data
    if (await _spotTypesService.fetchSpotTypesData()) {
      _spotTypeModel.value = _spotTypesService.spotTypeModel;
      // Create map of spot types
      for (Spot spot in _spotTypeModel.value!.spots!) {
        _spotTypeMap.value![spot.spotKey] = spot;
      }
      if (_userDataProvider
          .userProfileModel!.selectedParkingSpots!.isNotEmpty) {
        // Load selected spot types from user profile
        _selectedSpotTypesState.value =
            _userDataProvider.userProfileModel!.selectedParkingSpots;
      } else {
        // Load default spot types
        for (Spot spot in _spotTypeModel.value!.spots!) {
          if (ParkingDefaults.defaultSpots.contains(spot.spotKey)) {
            _selectedSpotTypesState.value![spot.spotKey] = true;
          } else {
            _selectedSpotTypesState.value![spot.spotKey] = false;
          }
        }
      }

      // Update spot types state to remove any unsupported spot types
      Map<String?, bool?> newMapOfSpotTypes = Map<String, bool>();
      for (Spot spot in _spotTypeModel.value!.spots!) {
        newMapOfSpotTypes[spot.spotKey] =
            _selectedSpotTypesState.value![spot.spotKey];
      }
      _selectedSpotTypesState.value = newMapOfSpotTypes.cast<String?, bool>();

      // Update number of spots selected
      _selectedSpotTypesState.value!.forEach((key, value) {
        if (value) {
          selectedSpots++;
        }
      });
    } else {
      // Handle spot types service error
      _error.value = _spotTypesService.error;
    }

    _isLoading.value = false;
    refresh();
  }

  // Getter for parking models
  List<ParkingModel> get parkingModels {
    if (_parkingModels.value != null) {
      return _parkingModels.value!.values.toList();
    }
    return [];
  }

  // Getter for spot type model
  SpotTypeModel? get spotTypeModel {
    if (_spotTypeModel.value != null) {
      return _spotTypeModel.value;
    }
    return SpotTypeModel();
  }

  // Toggle selection of a parking lot
  void toggleLot(String? location, int numSelected) {
    selectedLots = numSelected;
    if (selectedLots < MAX_SELECTED_LOTS) {
      _parkingViewState.value![location] = !_parkingViewState.value![location]!;
      _parkingViewState.value![location]! ? selectedLots++ : selectedLots--;
    } else {
      // Prevent selection if maximum lots are already selected
      if (_parkingViewState.value![location]!) {
        selectedLots--;
        _parkingViewState.value![location] =
            !_parkingViewState.value![location]!;
      }
    }
    _userDataProvider.userProfileModel!.selectedParkingLots =
        _parkingViewState.value;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    refresh();
  }

  // Toggle selection of a spot type
  void toggleSpotSelection(String? spotKey, int spotsSelected) {
    selectedSpots = spotsSelected;
    if (selectedSpots < MAX_SELECTED_SPOTS) {
      _selectedSpotTypesState.value![spotKey] =
          !_selectedSpotTypesState.value![spotKey]!;
      _selectedSpotTypesState.value![spotKey]!
          ? selectedSpots++
          : selectedSpots--;
    } else {
      // Prevent selection if maximum spots are already selected
      if (_selectedSpotTypesState.value![spotKey]!) {
        selectedSpots--;
        _selectedSpotTypesState.value![spotKey] =
            !_selectedSpotTypesState.value![spotKey]!;
      }
    }
    _userDataProvider.userProfileModel!.selectedParkingSpots =
        _selectedSpotTypesState.value;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    refresh();
  }

  // Setter for user data provider
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  // Calculate and return the total number of spots open at a given location
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

  // Generate and return a map of parking locations grouped by neighborhood
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

  // Get a list of parking structures
  List<String> getStructures() {
    List<String> structureMap = [];
    for (ParkingModel model in _parkingService.value.data!) {
      if (model.isStructure!) {
        structureMap.add(model.locationName!);
      }
    }
    return structureMap;
  }

  // Get a list of parking lots
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
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  DateTime? get lastUpdated => _lastUpdated.value;
  Map<String?, bool>? get selectedSpotTypesState =>
      _selectedSpotTypesState.value;
  Map<String?, bool>? get parkingViewState => _parkingViewState.value;
  Map<String?, Spot?>? get spotTypeMap => _spotTypeMap.value;
// SpotTypeModel? get spotTypeModel => _spotTypeModel;
}
