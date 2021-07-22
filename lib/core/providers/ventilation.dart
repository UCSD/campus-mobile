import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
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
  Map<String?, VentilationLocationsModel>? _ventilationLocationModels;
  Map<String, VentilationDataModel?> _ventilationDataModels =
      Map<String, VentilationDataModel?>();
  late UserDataProvider _userDataProvider;

  ///
  /// DATA PROVIDERS
  /// TODO: add data providers that will be needed if this is a dependent data provider
  /// create setters for each of these providers

  /// SERVICES
  /// TODO: add any services that will be needed for this data provider
  late VentilationService _ventilationService;

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
      _ventilationLocationModels = mapOfVentilationLocations;
    } else {
      _error = _ventilationService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void fetchVentilationData(String bfrId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _ventilationService.fetchData(bfrId)) {
      _ventilationDataModels[bfrId] = _ventilationService.data;
    } else {
      _error = _ventilationService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// MIGHT BE A GOOD IDEA TO ADD SOME SORT OF LIMIT HERE AS WELL
  void addLocation(String? bfrId) {
    _ventilationViewState.add(bfrId);
    _userDataProvider.userProfileModel!.selectedVentilationLocations =
        _ventilationViewState;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  /// MIGHT BE A GOOD IDEA TO ADD SOME SORT OF LIMIT HERE AS WELL
  void removeLocation(String? bfrId) {
    _ventilationViewState.remove(bfrId);
    _userDataProvider.userProfileModel!.selectedVentilationLocations =
        _ventilationViewState;
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  // List<VentilationLocationsModel?> makeOrderedList(List<String?>? order) {
  //   if (order == null) {
  //     return _ventilationLocationModels!.values.toList();
  //   }
  //
  //   ///create an empty list that will be returned
  //   List<VentilationLocationsModel?> orderedListOfLots = [];
  //   Map<String?, VentilationLocationsModel> tempMap =
  //       Map<String?, VentilationLocationsModel>();
  //   tempMap.addAll(_ventilationLocationModels!);
  //
  //   /// remove lots as we add them to the ordered list
  //   for (String? lotName in order) {
  //     orderedListOfLots.add(tempMap.remove(lotName));
  //   }
  //
  //   /// add remaining lots
  //   orderedListOfLots.addAll(tempMap.values);
  //   return orderedListOfLots;
  // }
  //
  // void reorderLocations(List<String?>? order) {
  //   ///edit the profile and upload user selected lots
  //   _userDataProvider.userProfileModel!.selectedVentilationLocations = order;
  //   // Commented out as this method updates the userDataProvider before it is set up,
  //   // posting null userProfile, was causing issues for parking preferences
  //   // _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
  //   notifyListeners();
  // }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// SIMPLE GETTERS
  bool? get isLoading => _isLoading;

  String? get error => _error;

  DateTime? get lastUpdated => _lastUpdated;

  List<VentilationDataModel?> get ventilationData =>
      _ventilationDataModels.values.toList();

  List<VentilationLocationsModel?> get ventilationLocations =>
      _ventilationLocationModels!.values.toList();
}
