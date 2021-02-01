import 'dart:math' as Math;

import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/location.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/shuttle.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../models/shuttle_stop.dart';

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
  ShuttleStopModel _closestStop;
  double userLat;
  double userLong;
  double stopLat;
  double stopLong;
  double closestDistance = 10000000;
  Map<int, ShuttleStopModel> fetchedStops;
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

    arrivalsToRender = Map<int, List<ArrivingShuttle>>();
  }

  void fetchStops({bool reloading}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // create new map of shuttles/stops to display
    Map<int, ShuttleStopModel> newMapOfStops = Map<int, ShuttleStopModel>();
    if (await _shuttleService.fetchData()) {
      for (ShuttleStopModel model in _shuttleService.data) {
        newMapOfStops[model.id] = model;
      }
      fetchedStops = newMapOfStops;

      /// if the user is logged in we want to sync the order of parking lots amongst all devices
      if (userDataProvider != null && !reloading) {
        reorderStops(userDataProvider.userProfileModel.selectedStops);
      }

      // get closest stop to current user
      await calculateClosestStop();

      // print("user latitude: " + userLat.toString());
      // print("user longitude: " + userLat.toString());
      // print("CLOSEST STOP: " + closestStop.id.toString());

      await getArrivalInformation();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ShuttleStopModel> makeOrderedList(List<int> order) {
    if (order == null) {
      return [];
    }

    ///create an empty list that will be returned
    List<ShuttleStopModel> orderedListOfStops = List<ShuttleStopModel>();

    /// remove lots as we add them to the ordered list
    for (int stopID in order) {
      orderedListOfStops.add(fetchedStops[stopID]);
    }
    return orderedListOfStops;
  }

  void reorderStops(List<int> order) {
    /// update userProfileModel with selectedStops
    userDataProvider.userProfileModel.selectedStops = order;
    if (userDataProvider.isLoggedIn) {
      /// post updated userProfileModel for logged-in users
      userDataProvider.postUserProfile(userDataProvider.userProfileModel);
    }
    notifyListeners();
  }

  Future<void> addStop(int stopID) async {
    if (!userDataProvider.userProfileModel.selectedStops.contains(stopID)) {
      userDataProvider.userProfileModel.selectedStops.add(stopID);
      // update userprofilemodel locally and in database after a stop is added
      userDataProvider.postUserProfile(userDataProvider.userProfileModel);
      arrivalsToRender[stopID] = await fetchArrivalInformation(stopID);
    }
    notifyListeners();
  }

  Future<void> removeStop(int stopID) async {
    // print('remove');
    if (userDataProvider.userProfileModel.selectedStops.contains(stopID)) {
      userDataProvider.userProfileModel.selectedStops.remove(stopID);
      // update userprofilemodel locally and in database after a stop is removed
      userDataProvider.postUserProfile(userDataProvider.userProfileModel);
      // print("UDP - ${userDataProvider.userProfileModel.selectedStops}");
    }
    notifyListeners();
  }

  Future<List<ArrivingShuttle>> fetchArrivalInformation(int stopID) async {
    List<ArrivingShuttle> output =
        await _shuttleService.getArrivingInformation(stopID);

    output.sort((a, b) => a.secondsToArrival.compareTo(b.secondsToArrival));
    return output;
  }

  Future<void> calculateClosestStop() async {
    await checkLocationPermission();
    await location.getLocation().then((value) {
      userLat = value.latitude;
      userLong = value.longitude;
    });

    for (ShuttleStopModel shuttleStop in _shuttleService.data) {
      stopLat = shuttleStop.lat;
      stopLong = shuttleStop.lon;

      if (getHaversineDistance(userLat, userLong, stopLat, stopLong) <
          closestDistance) {
        closestDistance =
            getHaversineDistance(userLat, userLong, stopLat, stopLong);
        _closestStop = shuttleStop;
      }
    }
  }

  double getHaversineDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) *
            Math.cos(deg2rad(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double deg2rad(deg) {
    return deg * (Math.pi / 180);
  }

  Future<void> checkLocationPermission() async {
    print('Location Permission Request: shuttle_data_provider');
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

  ShuttleStopModel get closestStop => _closestStop;

  List<ShuttleStopModel> get stopsToRender {
    if (fetchedStops != null) {
      if (userDataProvider.userProfileModel != null)
        return makeOrderedList(userDataProvider.userProfileModel.selectedStops);
    }
    return List<ShuttleStopModel>();
  }

  Map<int, ShuttleStopModel> get stopsNotSelected {
    var output = new Map<int, ShuttleStopModel>.from(fetchedStops);
    for (ShuttleStopModel stop in stopsToRender) {
      output.remove(stop.id);
    }
    return output;
  }

  Future<void> getArrivalInformation() async {
    arrivalsToRender[closestStop.id] =
        await fetchArrivalInformation(closestStop.id);
    for (ShuttleStopModel stop in stopsToRender) {
      arrivalsToRender[stop.id] = await fetchArrivalInformation(stop.id);
    }
  }
}
