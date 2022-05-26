import 'dart:async';

import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

class LocationDataProvider extends ChangeNotifier {
  Location location = new Location();
  String? error;

  StreamController<Coordinates> _locationController =
  StreamController<Coordinates>.broadcast();
  Stream<Coordinates> get locationStream => _locationController.stream;

  Location get locationObject => location;
  LocationDataProvider() {
    locationStream;
    _init();
  }

  _init() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check location service status
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check permission status
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Set high location accuracy
    await location.changeSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 100);

    // Enable location listener
    _enableListener();
  }

  _enableListener() {
    location.onLocationChanged.listen((locationData) {
      error = null;
      _locationController.add(Coordinates(
        lat: locationData.latitude,
        lon: locationData.longitude,
      ));
    });
  }
}
