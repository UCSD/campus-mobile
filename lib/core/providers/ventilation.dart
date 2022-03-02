import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/ventilation.dart';
import 'package:flutter/material.dart';

import '../../app_constants.dart';

class VentilationDataProvider extends ChangeNotifier {
  VentilationDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// initialize services here
    _ventilationService = VentilationService();
  }

  /// STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  Map<String?, VentilationLocationsModel>? _ventilationLocationModels;
  List<String?> ventilationIDs = [];
  List<VentilationDataModel?> ventilationDataModels = [];
  UserDataProvider? _userDataProvider;
  String? buildingID;
  String? floorID;

  /// SERVICES
  late VentilationService _ventilationService;

  void fetchLocationsAndData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// creating new map ensures we remove all unsupported locations
    Map<String?, VentilationLocationsModel> mapOfVentilationLocations =
        Map<String?, VentilationLocationsModel>();

    if (await _ventilationService.fetchLocations()) {
      for (VentilationLocationsModel model in _ventilationService.locations!) {
        mapOfVentilationLocations[model.buildingId] = model;
      }

      _ventilationLocationModels = mapOfVentilationLocations;
    } else {
      if (_error != null &&
          _error!.contains(ErrorConstants.invalidBearerToken)) {
        if (await _ventilationService.getNewToken()) {
          fetchVentilationLocations();
        }
      }
      _error = _ventilationService.error;
    }

    // create new list of ventilation data to display
    List<VentilationDataModel?> tempModels = [];

    if (_userDataProvider != null) {
      ventilationIDs =
          _userDataProvider!.userProfileModel!.selectedVentilationLocations!;

      for (String? bfrID in ventilationIDs) {
        print("ID: $bfrID");
        if (await _ventilationService.fetchData(bfrID!)) {
          tempModels.add(_ventilationService.data);
        } else {
          if (_error != null &&
              _error!.contains(ErrorConstants.invalidBearerToken)) {
            if (await _ventilationService.getNewToken()) {
              fetchVentilationData();
            }
          }

          _error = _ventilationService.error;
        }
      }
    }

    ventilationDataModels = tempModels;

    _isLoading = false;
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
      _ventilationLocationModels = mapOfVentilationLocations;
    } else {
      if (_error != null &&
          _error!.contains(ErrorConstants.invalidBearerToken)) {
        if (await _ventilationService.getNewToken()) {
          fetchVentilationLocations();
        }
      }
      _error = _ventilationService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void fetchVentilationData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // create new list of ventilation data to display
    List<VentilationDataModel?> tempModels = [];

    if (_userDataProvider != null) {
      ventilationIDs =
          _userDataProvider!.userProfileModel!.selectedVentilationLocations!;

      for (String? bfrID in ventilationIDs) {
        print("ID: $bfrID");
        if (await _ventilationService.fetchData(bfrID!)) {
          tempModels.add(_ventilationService.data);
        } else {
          if (_error != null &&
              _error!.contains(ErrorConstants.invalidBearerToken)) {
            if (await _ventilationService.getNewToken()) {
              fetchVentilationData();
            }
          }

          _error = _ventilationService.error;
        }
      }
    }

    ventilationDataModels = tempModels;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLocation(String? roomID) async {
    try {
      // creates the bfrID and then adds the ID to the user's list
      String bfrID = buildingID! + '/' + floorID! + '/' + roomID!;

      if (ventilationIDs.isNotEmpty) {
        ventilationIDs = [];
        ventilationDataModels = [];
        _userDataProvider!.userProfileModel!.selectedVentilationLocations = [];
        await _userDataProvider!
            .postUserProfile(_userDataProvider!.userProfileModel);
        notifyListeners();
      }

      _userDataProvider!.userProfileModel!.selectedVentilationLocations!
          .add(bfrID);
      _userDataProvider!.postUserProfile(_userDataProvider!.userProfileModel);

      // calls ventilationService to get this bfrID's data and adds it to the list
      await _ventilationService.fetchData(bfrID);
      ventilationDataModels.add(_ventilationService.data);
      ventilationIDs =
          _userDataProvider!.userProfileModel!.selectedVentilationLocations!;
    } catch (e) {
      _error = VentilationConstants.addLocationFailed;
      print("Error while adding location:  $e");
    }
    notifyListeners();
  }

  /// MIGHT BE A GOOD IDEA TO ADD SOME SORT OF LIMIT HERE AS WELL
  Future<void> removeLocation(String? roomID) async {
    try {
      // creates the bfrID and then removes the ID to the user's list
      String bfrID = buildingID! + '/' + floorID! + '/' + roomID!;
      _userDataProvider!.userProfileModel!.selectedVentilationLocations!
          .remove(bfrID);
      ventilationIDs =
          _userDataProvider!.userProfileModel!.selectedVentilationLocations!;
      _userDataProvider!.postUserProfile(_userDataProvider!.userProfileModel);

      ///TODO: MIGHT BE GOOD TO HAVE SOME CATCH IN CASE THE FETCH RETURNS FALSE
      // calls ventilationService to get this bfrID's data and removes it from the list
      await _ventilationService.fetchData(bfrID);
      ventilationDataModels.remove(_ventilationService.data);

      notifyListeners();
    } catch (e) {
      _error = VentilationConstants.removeLocationFailed;
      notifyListeners();
      print("Error while removing location:  $e");
    }
  }

  void addBuildingID(String id) {
    buildingID = id;
  }

  void addFloorID(String id) {
    floorID = id;
  }

  String bfrID(String roomID) {
    return buildingID! + '/' + floorID! + '/' + roomID;
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// SIMPLE GETTERS
  bool? get isLoading => _isLoading;

  String? get error => _error;

  DateTime? get lastUpdated => _lastUpdated;

  List<VentilationLocationsModel?> get ventilationLocations =>
      _ventilationLocationModels!.values.toList();

  List<VentilationDataModel?> get locationsToRenderInCard =>
      ventilationDataModels;

  List<String> get locationsToRenderInRooms {
    List<String> locationsToRenderInRooms = [];
    for (String? bfrID in ventilationIDs) {
      if (bfrID != null) {
        locationsToRenderInRooms.add(bfrID);
      }
    }
    return locationsToRenderInRooms;
  }
}
