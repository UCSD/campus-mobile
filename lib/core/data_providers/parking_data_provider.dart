import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/core/services/parking_service.dart';
import 'package:flutter/material.dart';

class ParkingDataProvider extends ChangeNotifier {
  ParkingDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _parkingService = ParkingService();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  Map<String, ParkingModel> _parkingModels;
  UserDataProvider _userDataProvider;

  ///SERVICES
  ParkingService _parkingService;

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
      }

      ///replace old list of lots with new one
      _parkingModels = newMapOfLots;

      /// if the user is logged in we want to sync the order of parking lots amongst all devices
      if (_userDataProvider != null) {
        reorderLots(_userDataProvider.userProfileModel.selectedLots);
      }
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _parkingService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///TODO: MOVE TO UTILITY FOLDER/FILE WHEN CREATED
  ///THIS IS A UTILITY FUNCTION THAT SHOULD BE EXPORTED TO BE USED FOR ANY OBJECT TYPE <T>
  ///WILL TAKE A Map<String,T> Data and List<String> THAT WILL REPRESENT THE ORDER OF ITEMS
  ///RETURNED BY THIS METHOD.
  List<ParkingModel> makeOrderedList(List<String> order) {
    if (order == null) {
      return _parkingModels.values.toList();
    }

    ///create an empty list that will be returned
    List<ParkingModel> orderedListOfLots = List<ParkingModel>();
    Map<String, ParkingModel> tempMap = Map<String, ParkingModel>();
    tempMap.addAll(_parkingModels);

    /// remove lots as we add them to the ordered list
    for (String lotName in order) {
      orderedListOfLots.add(tempMap.remove(lotName));
    }

    /// add remaining lots
    orderedListOfLots.addAll(tempMap.values);
    return orderedListOfLots;
  }

  ///REORDER THE LOTS GIVEN AN ARRAY OF STRINGS CONTAINING LOT NAMES
  ///UPLOAD CHANGES TO DB IF LOGGED IN OTHER WISE SAVE IT LOCALLY
  void reorderLots(List<String> order) {
    ///edit the profile and upload user selected lots
    _userDataProvider.userProfileModel.selectedLots = order;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  ///ADD A PARKING LOT IF IT HAS NOT ALREADY BEEN ADDED
  void addLot(ParkingModel model) {
    if (!_userDataProvider.userProfileModel.selectedLots
        .contains(model.locationName)) {
      _userDataProvider.userProfileModel.selectedLots.add(model.locationName);
    }
  }

  ///REMOVE PARKING LOT
  void removeLot(ParkingModel model) {
    _userDataProvider.userProfileModel.selectedLots.remove(model.locationName);
  }

  ///UPLOAD SELECTED LOTS IN THE CORRECT ORDER TO THE DATABASE
  ///IF NOT LOGGED IN THEN SAVE LOTS TO LOCAL PROFILE
  uploadParkingLotData(List<String> lots) {
    var userProfile = _userDataProvider.userProfileModel;

    ///set the local user profile to the given lots
    userProfile.selectedLots = lots;
    _userDataProvider.postUserProfile(userProfile);
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  ///RETURNS A List<ParkingModels> IN THE CORRECT ORDER
  List<ParkingModel> get parkingModels {
    ///check if we have an offline _parkingModel
    if (_parkingModels != null) {
      ///check if we have an offline _userProfileModel
      if (_userDataProvider.userProfileModel != null) {
        return makeOrderedList(_userDataProvider.userProfileModel.selectedLots);
      }
      return _parkingModels.values.toList();
    }
    return List<ParkingModel>();
  }
}
