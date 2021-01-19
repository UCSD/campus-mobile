import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/parking.dart';
import 'package:campus_mobile_experimental/core/services/spot_types.dart';
import 'package:flutter/material.dart';

class ParkingDataProvider extends ChangeNotifier {
  ParkingDataProvider() {
    ///DEFAULT STATES
    _isLoadingLots = false;
    _isLoadingSpots = false;
    _isLoading = false;

    _parkingService = ParkingService();
    _spotTypesService = SpotTypesService();
  }

  UserDataProvider _userDataProvider;

  ///STATES
  bool _isLoadingLots;
  bool _isLoadingSpots;
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int selected_lots, selected_spots;
  static const MAX_SELECTED_LOTS = 10;
  static const MAX_SELECTED_SPOTS = 3;
  Map<String, bool> _parkingViewState = <String, bool>{};
  Map<String, bool> _selectedSpotTypesState = <String, bool>{};

  ///MODELS
  Map<String, ParkingModel> _parkingModels;
  SpotTypeModel _spotTypeModel;

  ///SERVICES
  ParkingService _parkingService;
  SpotTypesService _spotTypesService;

  void fetchParkingData() async {
    _isLoading = true;
    selected_spots = 0;
    selected_lots = 0;
    _error = null;
    notifyListeners();

    /// create a new map to ensure we remove all unsupported lots
    Map<String, ParkingModel> newMapOfLots = Map<String, ParkingModel>();
    if (await _parkingService.fetchParkingLotData()) {
      if (_userDataProvider.userProfileModel.selectedParkingLots.isNotEmpty) {
        _parkingViewState =
            _userDataProvider.userProfileModel.selectedParkingLots;
      } else {
        for (ParkingModel model in _parkingService.data) {
          if (ParkingDefaults.defaultLots.contains(model.locationId)) {
            _parkingViewState[model.locationName] = true;
          } else {
            _parkingViewState[model.locationName] = false;
          }
        }
      }
      for (ParkingModel model in _parkingService.data) {
        newMapOfLots[model.locationName] = model;
      }

      //Update number of lots selected
      _parkingViewState.forEach((key, value) {
        if (value) {
          selected_lots++;
        }
      });

      ///replace old list of lots with new one
      _parkingModels = newMapOfLots;
    } else {
      ///TODO: determine what error to show to the user
      _error = _parkingService.error;
    }

    if (await _spotTypesService.fetchSpotTypesData()) {
      _spotTypeModel = _spotTypesService.spotTypeModel;
      if (_userDataProvider.userProfileModel.selectedParkingSpots.isNotEmpty) {
        //Load selected spots types from user Profile
        _selectedSpotTypesState =
            _userDataProvider.userProfileModel.selectedParkingSpots;
      } else {
        //Load default spot types
        for (Spot spot in _spotTypeModel.spots) {
          if (ParkingDefaults.defaultSpots.contains(spot.spotKey)) {
            _selectedSpotTypesState[spot.spotKey] = true;
          } else {
            _selectedSpotTypesState[spot.spotKey] = false;
          }
        }
      }

      //Update number of spots selected
      _selectedSpotTypesState.forEach((key, value) {
        if (value) {
          selected_spots++;
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
      return _parkingModels.values.toList();
    }
    return List<ParkingModel>();
  }

  SpotTypeModel get spotTypeModel {
    if (_spotTypeModel != null) {
      return _spotTypeModel;
    }
    return SpotTypeModel();
  }

// add or remove location availability display from card based on user selection, Limit to MAX_SELECTED
  void toggleLot(String location) {
    if (selected_lots < MAX_SELECTED_LOTS) {
      _parkingViewState[location] = !_parkingViewState[location];
      _parkingViewState[location] ? selected_lots++ : selected_lots--;
    } else {
      //prevent select
      if (_parkingViewState[location]) {
        selected_lots--;
        _parkingViewState[location] = !_parkingViewState[location];
      }
    }
    _userDataProvider.userProfileModel.selectedParkingLots = _parkingViewState;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  void toggleSpotSelection(String spotKey) {
    if (selected_spots < MAX_SELECTED_SPOTS) {
      _selectedSpotTypesState[spotKey] = !_selectedSpotTypesState[spotKey];
      _selectedSpotTypesState[spotKey] ? selected_spots++ : selected_spots--;
    } else {
      //prevent select
      if (_selectedSpotTypesState[spotKey]) {
        selected_spots--;
        _selectedSpotTypesState[spotKey] = !_selectedSpotTypesState[spotKey];
      }
    }
    _userDataProvider.userProfileModel.selectedParkingSpots =
        _selectedSpotTypesState;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  Map<String, bool> get spotTypesState => _selectedSpotTypesState;
  Map<String, bool> get parkingViewState => _parkingViewState;
}
