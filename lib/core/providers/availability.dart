import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/availability.dart';
import 'package:flutter/material.dart';

class AvailabilityDataProvider extends ChangeNotifier {
  AvailabilityDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// TODO: initialize services here
    _availabilityService = AvailabilityService();
  }

  /// STATES
  /// TODO: create any other states needed for the feature
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  Map<String?, bool> _locationViewState = <String?, bool>{};

  /// MODELS
  /// TODO: add models that will be needed in this data provider
  Map<String?, AvailabilityModel>? _availabilityModels;
  late UserDataProvider _userDataProvider;

  ///
  /// DATA PROVIDERS
  /// TODO: add data providers that will be needed if this is a dependent data provider
  /// create setters for each of these providers

  /// SERVICES
  /// TODO: add any services that will be needed for this data provider
  late AvailabilityService _availabilityService;

  void fetchAvailability() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// creating  new map ensures we remove all unsupported lots
    Map<String?, AvailabilityModel> newMapOfLots =
        Map<String?, AvailabilityModel>();
    if (await _availabilityService.fetchData()) {
      /// setting the LocationViewState based on user data
      for (AvailabilityModel model in _availabilityService.data!) {
        newMapOfLots[model.name] = model;

        /// if the user is logged out and has not put any preferences,
        /// show all locations by default
        if (_userDataProvider
            .userProfileModel!.selectedOccuspaceLocations!.isEmpty) {
          locationViewState[model.name] = true;
        }

        /// otherwise, LocationViewState should be true for all selectedOccuspaceLocations
        else {
          _locationViewState[model.name] = _userDataProvider
              .userProfileModel!.selectedOccuspaceLocations!
              .contains(model.name);
        }
      }

      ///replace old list of lots with new one
      _availabilityModels = newMapOfLots;

      /// if the user is logged in we want to sync the order of parking lots amongst all devices
      reorderLocations(
          _userDataProvider.userProfileModel!.selectedOccuspaceLocations);
      _lastUpdated = DateTime.now();
    } else {
      if (_error != null &&
          _error!.contains(ErrorConstants.invalidBearerToken)) {
        if (await _availabilityService.getNewToken()) {
          fetchAvailability();
        }
      }
      _error = _availabilityService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  List<AvailabilityModel?> makeOrderedList(List<String?>? order) {
    if (order == null) {
      return _availabilityModels!.values.toList();
    }

    ///create an empty list that will be returned
    List<AvailabilityModel?> orderedListOfLots = [];
    Map<String?, AvailabilityModel> tempMap = Map<String?, AvailabilityModel>();
    tempMap.addAll(_availabilityModels!);

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
    _userDataProvider.userProfileModel!.selectedOccuspaceLocations = order;
    // Commented out as this method updates the userDataProvider before it is set up,
    // posting null userProfile, was causing issues for parking preferences
    // _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  /// add or remove location availability display from card based on user selection
  void toggleLocation(String? location) {
    if (_locationViewState[location] ?? true) {
      _locationViewState[location] = false;
    } else {
      _locationViewState[location] = true;
    }
    _userDataProvider
        .updateUserProfileModel(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  ///UPLOAD SELECTED LOCATIONS IN THE CORRECT ORDER TO THE DATABASE
  ///IF NOT LOGGED IN THEN SAVE LOCATIONS TO LOCAL PROFILE
  uploadAvailabilityData(List<String> locations) {
    var userProfile = _userDataProvider.userProfileModel!;

    ///set the local user profile to the given lots
    userProfile.selectedOccuspaceLocations = locations;
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

  Map<String?, bool> get locationViewState => _locationViewState;

  List<AvailabilityModel?> get availabilityModels {
    if (_availabilityModels != null) {
      ///check if we have an offline _userProfileModel
      if (_userDataProvider.userProfileModel != null) {
        return makeOrderedList(
            _userDataProvider.userProfileModel!.selectedOccuspaceLocations);
      }
      return _availabilityModels!.values.toList();
    }
    return [];
  }

  /// get all locations
  List<String?> locations() {
    List<String?> locationsToReturn = [];
    for (AvailabilityModel model
        in _availabilityModels as Iterable<AvailabilityModel>? ?? []) {
      locationsToReturn.add(model.name);
    }
    return locationsToReturn;
  }
}
