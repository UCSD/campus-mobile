import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/ventilation.dart';
import 'package:flutter/material.dart';

class VentilationDataProvider extends ChangeNotifier {
  VentilationDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// TODO: initialize services here
    _ventilationService = VentilationService();
  }

  /// STATES
  /// TODO: create any other states needed for the feature
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  List<String?> _ventilationViewState = [];

  /// MODELS
  /// TODO: add models that will be needed in this data provider
  Map<String?, VentilationLocationsModel>? _ventilationModels;
  late UserDataProvider _userDataProvider;

  ///
  /// DATA PROVIDERS
  /// TODO: add data providers that will be needed if this is a dependent data provider
  /// create setters for each of these providers

  /// SERVICES
  /// TODO: add any services that will be needed for this data provider
  late VentilationService _ventilationService;

  /// MIGHT BE A GOOD IDEA TO ADD SOME SORT OF LIMIT HERE AS WELL
  void toggleLocation(String? bfrId) {
    _ventilationViewState.add(bfrId);
    _userDataProvider.userProfileModel!.selectedVentilationLocations =
        _ventilationViewState;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  void fetchVentilationLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// creating  new map ensures we remove all unsupported locations
    Map<String?, VentilationLocationsModel> mapOfVentilationLocations =
        Map<String?, VentilationLocationsModel>();

    if (await _ventilationService.fetchLocations()) {
      for (VentilationLocationsModel model in _ventilationService.locations!) {
        mapOfVentilationLocations[model.buildingId] = model;
      }

      ///replace old list of lots with new one
      _ventilationModels = mapOfVentilationLocations;
    } else {
      _error = _ventilationService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  List<VentilationLocationsModel?> makeOrderedList(List<String?>? order) {
    if (order == null) {
      return _ventilationModels!.values.toList();
    }

    ///create an empty list that will be returned
    List<VentilationLocationsModel?> orderedListOfLots = [];
    Map<String?, VentilationLocationsModel> tempMap =
        Map<String?, VentilationLocationsModel>();
    tempMap.addAll(_ventilationModels!);

    /// remove lots as we add them to the ordered list
    for (String? lotName in order) {
      orderedListOfLots.add(tempMap.remove(lotName));
    }

    /// add remaining lots
    orderedListOfLots.addAll(tempMap.values);
    return orderedListOfLots;
  }
  //
  // void reorderLocations(List<String?>? order) {
  //   ///edit the profile and upload user selected lots
  //   _userDataProvider.userProfileModel!.selectedVentilationLocations = order;
  //   // Commented out as this method updates the userDataProvider before it is set up,
  //   // posting null userProfile, was causing issues for parking preferences
  //   // _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
  //   notifyListeners();
  // }
  //
  // /// add or remove location availability display from card based on user selection
  // void toggleLocation(String? location) {
  //   if (_ventilationViewState[location] ?? true) {
  //     _ventilationViewState[location] = false;
  //   } else {
  //     _ventilationViewState[location] = true;
  //   }
  //   _userDataProvider
  //       .updateUserProfileModel(_userDataProvider.userProfileModel);
  //   notifyListeners();
  // }

  ///UPLOAD SELECTED LOCATIONS IN THE CORRECT ORDER TO THE DATABASE
  ///IF NOT LOGGED IN THEN SAVE LOCATIONS TO LOCAL PROFILE
  uploadVentilationData(List<String> locations) {
    var userProfile = _userDataProvider.userProfileModel!;

    ///set the local user profile to the given lots
    userProfile.selectedVentilationLocations = locations;
    _userDataProvider.postUserProfile(userProfile);
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// SIMPLE GETTERS
  bool? get isLoading => _isLoading;

  String? get error => _error;

  DateTime? get lastUpdated => _lastUpdated;

  // Map<String?, bool> get ventilationViewState => _ventilationViewState;
  //
  List<VentilationLocationsModel?> get ventilationLocationsModels {
    if (_ventilationModels != null) {
      ///check if we have an offline _userProfileModel
      if (_userDataProvider.userProfileModel != null) {
        return makeOrderedList(
            _userDataProvider.userProfileModel!.selectedVentilationLocations);
      }
      return _ventilationModels!.values.toList();
    }
    return [];
  }
  //
  // /// get all locations
  // List<String?> locations() {
  //   List<String?> locationsToReturn = [];
  //   for (VentilationModel model
  //       in _ventilationModels as Iterable<VentilationModel>? ?? []) {
  //     locationsToReturn.add(model.buildingName);
  //   }
  //   return locationsToReturn;
  // }
}
