import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/ventilation.dart';
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
  Map<String?, bool> _ventilationViewState = <String?, bool>{};

  /// MODELS
  /// TODO: add models that will be needed in this data provider
  Map<String?, VentilationModel>? _ventilationModels;
  late UserDataProvider _userDataProvider;

  ///
  /// DATA PROVIDERS
  /// TODO: add data providers that will be needed if this is a dependent data provider
  /// create setters for each of these providers

  /// SERVICES
  /// TODO: add any services that will be needed for this data provider
  late VentilationService _ventilationService;

  void fetchVentilation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// creating  new map ensures we remove all unsupported lots
    Map<String?, VentilationModel> newMapOfLots =
        Map<String?, VentilationModel>();
    if (await _ventilationService.fetchData()) {
      /// setting the LocationViewState based on user data
      for (VentilationModel model in _ventilationService.data!) {
        newMapOfLots[model.buildingName] = model;

        /// if the user is logged out and has not put any preferences,
        /// show all locations by default
        if (_userDataProvider
            .userProfileModel!.selectedVentilationLocations!.isEmpty) {
          ventilationViewState[model.buildingName] = true;
        }

        /// otherwise, LocationViewState should be true for all selectedOccuspaceLocations
        else {
          _ventilationViewState[model.buildingName] = _userDataProvider
              .userProfileModel!.selectedVentilationLocations!
              .contains(model.buildingName);
        }
      }

      ///replace old list of lots with new one
      _ventilationModels = newMapOfLots;

      /// if the user is logged in we want to sync the order of parking lots amongst all devices
      reorderLocations(
          _userDataProvider.userProfileModel!.selectedVentilationLocations);
      _lastUpdated = DateTime.now();
    } else {
      if (_error != null &&
          _error!.contains(ErrorConstants.invalidBearerToken)) {
        if (await _ventilationService.getNewToken()) {
          fetchVentilation();
        }
      }
      _error = _ventilationService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  List<VentilationModel?> makeOrderedList(List<String?>? order) {
    if (order == null) {
      return _ventilationModels!.values.toList();
    }

    ///create an empty list that will be returned
    List<VentilationModel?> orderedListOfLots = [];
    Map<String?, VentilationModel> tempMap = Map<String?, VentilationModel>();
    tempMap.addAll(_ventilationModels!);

    /// remove lots as we add them to the ordered list
    for (String? lotName in order) {
      orderedListOfLots.add(tempMap.remove(lotName));
    }

    /// add remaining lots
    orderedListOfLots.addAll(tempMap.values);
    return orderedListOfLots;
  }

  void reorderLocations(List<String?>? order) {
    ///edit the profile and upload user selected lots
    _userDataProvider.userProfileModel!.selectedVentilationLocations = order;
    // Commented out as this method updates the userDataProvider before it is set up,
    // posting null userProfile, was causing issues for parking preferences
    // _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  /// add or remove location availability display from card based on user selection
  void toggleLocation(String? location) {
    if (_ventilationViewState[location] ?? true) {
      _ventilationViewState[location] = false;
    } else {
      _ventilationViewState[location] = true;
    }
    _userDataProvider
        .updateUserProfileModel(_userDataProvider.userProfileModel);
    notifyListeners();
  }

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

  Map<String?, bool> get ventilationViewState => _ventilationViewState;

  List<VentilationModel?> get ventilationModels {
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

  /// get all locations
  List<String?> locations() {
    List<String?> locationsToReturn = [];
    for (VentilationModel model
        in _ventilationModels as Iterable<VentilationModel>? ?? []) {
      locationsToReturn.add(model.buildingName);
    }
    return locationsToReturn;
  }
}
