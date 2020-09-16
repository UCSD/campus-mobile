import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
import 'package:campus_mobile_experimental/core/services/parking_service.dart';
import 'package:campus_mobile_experimental/core/services/spot_types_service.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/default_parking_constants.dart';

class ParkingDataProvider extends ChangeNotifier {
  ParkingDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    selected_lots = 0;
    selected_spots = 0;

    _parkingModels = Map<String, ParkingModel>();
    _spotTypeModel = SpotTypeModel();
  }

  ///STATES
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
  final ParkingService _parkingService = ParkingService();
  final SpotTypesService _spotTypesService = SpotTypesService();

  /// FETCH PARKING LOT DATA AND SYNC THE ORDER IF USER IS LOGGED IN
  /// TODO: make sure to remove any lots the user has selected and are no longer available
  void fetchParkingLots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// creating  new map ensures we remove all unsupported lots
    Map<String, ParkingModel> newMapOfLots = Map<String, ParkingModel>();
    if (await _parkingService.fetchParkingLotData()) {
      for (ParkingModel model in _parkingService.data) {
        newMapOfLots[model.locationName] = model;
        if (ParkingDefaults.defaultLots.contains(model.locationId)) {
          _parkingViewState[model.locationName] = true;
          selected_lots++;
        } else {
          _parkingViewState[model.locationName] = false;
        }
      }

      ///replace old list of lots with new one
      _parkingModels = newMapOfLots;

      //TODO Add user selected spots

      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _parkingService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void fetchSpotTypes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (await _spotTypesService.fetchSpotTypesData()) {
      _lastUpdated = DateTime.now();
      _spotTypeModel = _spotTypesService.spotTypeModel;

      for (Spot spot in _spotTypeModel.spots) {
        if (ParkingDefaults.defaultSpots.contains(spot.spotKey)) {
          //add first 10 to default lots selected
          _selectedSpotTypesState[spot.spotKey] = true;
          selected_spots++;
        } else {
          _selectedSpotTypesState[spot.spotKey] = false;
        }
      }
    } else {
      _error = _spotTypesService.error;
    }

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

// add or remove location availability display from card based on user selection, Limit to MAX_SELECTED
  void toggleLot(String location) {
    if (selected_lots <= MAX_SELECTED_LOTS) {
      _parkingViewState[location] = !_parkingViewState[location];
      _parkingViewState[location] ? selected_lots++ : selected_lots--;
    } else {
      //prevent select
      if (_parkingViewState[location]) {
        selected_lots--;
        _parkingViewState[location] = !_parkingViewState[location];
      }
    }
    notifyListeners();
  }

  void toggleSpotSelection(String spotKey) {
    if (selected_spots <= MAX_SELECTED_SPOTS) {
      _selectedSpotTypesState[spotKey] = !_selectedSpotTypesState[spotKey];
      _selectedSpotTypesState[spotKey] ? selected_spots++ : selected_spots--;
    } else {
      //prevent select
      if (_selectedSpotTypesState[spotKey]) {
        selected_spots--;
        _selectedSpotTypesState[spotKey] = !_selectedSpotTypesState[spotKey];
      }
    }
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  SpotTypeModel get spotTypeModel => _spotTypeModel;
  Map<String, bool> get spotTypesState => _selectedSpotTypesState;
  Map<String, bool> get parkingViewState => _parkingViewState;
}
