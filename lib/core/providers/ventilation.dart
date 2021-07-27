import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/ventilation.dart';
import 'package:flutter/material.dart';

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

  void fetchVentilationData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    print("Items in Ventilation IDS");

    // create new list of ventilation data to display
    List<VentilationDataModel?> tempModels = [];

    if (_userDataProvider != null) {
      ventilationIDs =
          _userDataProvider!.userProfileModel!.selectedVentilationLocations!;

      for (String? bfrID in ventilationIDs) {
        print("ID: $bfrID");
        if (await _ventilationService.fetchData(bfrID!)) {
          tempModels.add(_ventilationService.data);
        }
      }
    }

    ventilationDataModels = tempModels;

    ///TODO: MIGHT NEED THIS if the user is logged in we want to sync the order of parking lots amongst all devices
    // if (userDataProvider != null && !reloading) {
    //   reorderStops(userDataProvider!.userProfileModel!.selectedStops);
    // }

    _isLoading = false;
    notifyListeners();
  }

  /// MIGHT BE A GOOD IDEA TO ADD SOME SORT OF LIMIT HERE AS WELL
  Future<void> addLocation(String? roomID) async {
    // creates the bfrID and then adds the ID to the user's list
    String bfrID = buildingID! + floorID! + roomID!;
    _userDataProvider!.userProfileModel!.selectedVentilationLocations!
        .add(bfrID);
    _userDataProvider!.postUserProfile(_userDataProvider!.userProfileModel);

    ///TODO: MIGHT BE GOOD TO HAVE SOME CATCH IN CASE THE FETCH RETURNS FALSE
    // calls ventilationService to get this bfrID's data and adds it to the list
    await _ventilationService.fetchData(bfrID);
    ventilationDataModels.add(_ventilationService.data);
    // fetchVentilationData();

    print("Length in addLocation: ${ventilationDataModels.length}");

    notifyListeners();
  }

  /// MIGHT BE A GOOD IDEA TO ADD SOME SORT OF LIMIT HERE AS WELL
  Future<void> removeLocation(String? roomID) async {
    // creates the bfrID and then removes the ID to the user's list
    String bfrID = buildingID! + floorID! + roomID!;
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
  }

  void addBuildingID(String id) {
    buildingID = id;
  }

  void addFloorID(String id) {
    floorID = id;
  }

  String bfrID(String roomID) {
    return buildingID! + floorID! + roomID;
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
