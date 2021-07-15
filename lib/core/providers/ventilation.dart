import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
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
  // in ventilation provider add this at like line 29ish,
  // be sure to import the userDataProvider when it tells you to:

  ///Additional Provider
  late UserDataProvider _userDataProvider;

  // at the very end of the VentilationDataProvider class, add this:

  ///Simple Setters
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

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

    // /// if the user is logged out and has not put any preferences,
    // /// show all locations by default
    // if (_userDataProvider
    //     .userProfileModel!.selectedVentilationLocations!.isEmpty) {
    //   locationViewState[model.locationName] = true;
    // }
    //
    // /// otherwise, LocationViewState should be true for all selectedOccuspaceLocations
    // else {
    //   _locationViewState[model.locationName] = _userDataProvider
    //       .userProfileModel!.selectedVentilationLocations!
    //       .contains(model.locationName);
    // }

    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

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

  List<VentilationModel?> get ventilationModels {
    return _ventilationModel.values.toList();
  }

  List<VentilationLocationsModel> get ventilationLocationModels {
    return _ventilationLocationsModel.values.toList();
  }
}
