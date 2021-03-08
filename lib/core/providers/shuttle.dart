import 'dart:math' as Math;

import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/shuttle.dart';
import 'package:flutter/material.dart';

import '../models/shuttle_stop.dart';

class ShuttleDataProvider extends ChangeNotifier {
  ShuttleDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// TODO: initialize services here
//    _shuttleService = ShuttleService();
    init();
  }

  Coordinates _coordinates;
  bool _isLoading;
  String _error;
  UserDataProvider userDataProvider;
  ShuttleService _shuttleService;
  ShuttleStopModel _closestStop;
  double stopLat;
  double stopLong;
  double closestDistance = 10000000;
  Map<int, ShuttleStopModel> fetchedStops;
  Map<int, List<ArrivingShuttle>> arrivalsToRender;
  Coordinates _userCoords;

  init() {
    _shuttleService = ShuttleService();
    arrivalsToRender = Map<int, List<ArrivingShuttle>>();
  }

  void fetchStops(bool reloading) async {
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
      calculateClosestStop();
      getArrivalInformation();
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
    if (userDataProvider.userProfileModel.selectedStops.contains(stopID)) {
      userDataProvider.userProfileModel.selectedStops.remove(stopID);
      // update userprofilemodel locally and in database after a stop is removed
      userDataProvider.postUserProfile(userDataProvider.userProfileModel);
    }
    notifyListeners();
  }

  void calculateClosestStop() {
    //make sure we have users location before we do any calculations
    if (_userCoords == null ||
        _userCoords.lon == null ||
        _userCoords.lat == null) {
      return;
    }
    for (ShuttleStopModel shuttleStop in _shuttleService.data) {
      stopLat = shuttleStop.lat;
      stopLong = shuttleStop.lon;

      if (getHaversineDistance(
              _userCoords.lat, _userCoords.lon, stopLat, stopLong) <
          closestDistance) {
        closestDistance = getHaversineDistance(
            _userCoords.lat, _userCoords.lon, stopLat, stopLong);
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

  void getArrivalInformation() async {
    if (_closestStop != null) {
      arrivalsToRender[_closestStop.id] =
          await fetchArrivalInformation(_closestStop.id);
      for (ShuttleStopModel stop in stopsToRender) {
        arrivalsToRender[stop.id] = await fetchArrivalInformation(stop.id);
      }
    }
  }

  Future<List<ArrivingShuttle>> fetchArrivalInformation(int stopID) async {
    List<ArrivingShuttle> output =
        await _shuttleService.getArrivingInformation(stopID);

    output.sort((a, b) => a.secondsToArrival.compareTo(b.secondsToArrival));
    return output;
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

  set userCoords(Coordinates value) {
    _userCoords = value;
  }

  set coordinates(Coordinates value) {
    _coordinates = value;
  }
}
