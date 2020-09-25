import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/location_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/services/shuttle_service.dart';
import 'package:location/location.dart';
import 'dart:math' as Math;

class ShuttleDataProvider extends ChangeNotifier {
  ShuttleDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// TODO: initialize services here
    _shuttleService = ShuttleService();
    init();
  }

  bool _isLoading;
  String _error;
  UserDataProvider userDataProvider;
  ShuttleService _shuttleService;
  Location location;
  ShuttleStopModel closestStop;
  double userLat;
  double userLong;
  double stopLat;
  double stopLong;
  double closestDistance = 10000000;
  Map<int, ShuttleStopModel> _fetchedStops;
  Set<int> userStops;
  Map<int, List<ArrivingShuttle>> arrivalsToRender;
  LocationDataProvider _locationDataProvider;

  init() {
    _locationDataProvider = LocationDataProvider();
    _shuttleService = ShuttleService();
    location = Location();
    _locationDataProvider.locationStream.listen((event) {
      userLat = event.lat;
      userLong = event.lon;
    });

    // hardcoded for debugging purposes
    userStops = {34893, 434353, 4348634};

    arrivalsToRender = Map<int, List<ArrivingShuttle>>();
  }

  void fetchStops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // create new map of shuttles/stops to display
    Map<int, ShuttleStopModel> newMapOfStops = Map<int, ShuttleStopModel>();
    if (await _shuttleService.fetchData()) {
      for (ShuttleStopModel model in _shuttleService.data) {
        newMapOfStops[model.id] = model;
      }
      _fetchedStops = newMapOfStops;

      /// if the user is logged in we want to sync the order of parking lots amongst all devices
      if (userDataProvider != null) {
        print("user logged in");
        reorderStops(userDataProvider.userProfileModel.selectedStops);
      }
      //getUserStops();

      // get closest stop to current user
      await calculateClosestStop();

      print("user latitude: " + userLat.toString());
      print("user longitude: " + userLat.toString());
      print("CLOSEST STOP: " + closestStop.id.toString());


      // for debug purposes, we will only have 3 cards
      // later on, this will be replaced
      await getArrivalInformation();
    }
    // get information about stops in list
    //await getStopInformation();

    _isLoading = false;
    notifyListeners();
  }

  void getUserStops() {
    // need to get stops from user in this method

    // need to add stops to the list of stops
  }

  void reorderStops(List<int> order) {
    ///edit the profile and upload user selected lots
    print("reordering lists");
    userDataProvider.userProfileModel.selectedStops = order;
    userDataProvider.postUserProfile(userDataProvider.userProfileModel);
    notifyListeners();
  }

  Future<void> addStop(int stopID) async {
    print(stopID);
    if (!userDataProvider.userProfileModel.selectedStops
        .contains(stopID)) {
      userDataProvider.userProfileModel.selectedStops.add(stopID);
      print("UDP - ${userDataProvider.userProfileModel.selectedStops}");
      await getArrivalInformation();
      notifyListeners();
    }
  }

  Future<List<ArrivingShuttle>> fetchArrivalInformation(ShuttleStopModel stop) async {
    return await _shuttleService.getArrivingInformation(stop.id);
    //notifyListeners();
  }

  Future<void> calculateClosestStop() async {
    await checkLocationPermission();
    await location.getLocation().then((value) {
      userLat = value.latitude;
      userLong = value.longitude;
    });

    for(ShuttleStopModel shuttleStop in _shuttleService.data) {
      stopLat = shuttleStop.lat;
      stopLong = shuttleStop.lon;

      if(getHaversineDistance(userLat, userLong, stopLat, stopLong) < closestDistance) {
        closestDistance = getHaversineDistance(userLat, userLong, stopLat, stopLong);
        closestStop = shuttleStop;
      }
    }
    print(closestStop.id);
  }

  double getHaversineDistance(lat1,lon1,lat2,lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1);
    var a =
        Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
                Math.sin(dLon/2) * Math.sin(dLon/2)
    ;
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
  }

  double deg2rad(deg) {
    return deg * (Math.pi/180);
  }

  Future<void> checkLocationPermission() async {
    // Set up new location object to get current location
    location = Location();
    location.changeSettings(accuracy: LocationAccuracy.low);
    PermissionStatus hasPermission;
    bool _serviceEnabled;

    // check if gps service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    //check if permission is granted
    hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      hasPermission = await location.requestPermission();
      if (hasPermission != PermissionStatus.granted) {
        return;
      }
    }
  }

  bool get isLoading => _isLoading;
  String get error => _error;

  List<ShuttleStopModel> get stopsToRender {
    List<ShuttleStopModel> output = List<ShuttleStopModel>();
    if (_fetchedStops != null) {
      if (userDataProvider.userProfileModel != null) {
        for (int stopID in userDataProvider.userProfileModel.selectedStops) {
          output.add(_fetchedStops[stopID]);
        }
      }
      output.insert(0, closestStop);
    }
    print("stops - $output");
    return output;
  }

  Future<void> getArrivalInformation() async {
    for (ShuttleStopModel stop in stopsToRender) {
      arrivalsToRender[stop.id] = await fetchArrivalInformation(stop);
    }
  }
}

