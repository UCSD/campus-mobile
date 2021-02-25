import 'dart:async';

import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationDataProvider extends ChangeNotifier {
  final Location _locationService = new Location();
  bool _permission = false;
  String error;

  StreamController<Coordinates> _locationController =
      StreamController<Coordinates>.broadcast();
  Stream<Coordinates> get locationStream => _locationController.stream;

  LocationDataProvider() {
    _init();
  }

  _init() async {
    await _requestPermissions();
    if (_permission) {
      /// create the settings for location access
      await _locationService.changeSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 100);
    }
    notifyListeners();
  }

  _requestPermissions() async {
    PermissionStatus hasPermission;
    //check if permission is granted
    hasPermission = await _locationService.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      hasPermission = await _locationService.requestPermission();
      if (hasPermission == PermissionStatus.granted) {
        _permission = true;
        _enableListener();
      }
    }
  }

  _enableListener() {
    if (_permission) {
      _locationService.onLocationChanged.listen((locationData) {
        if (locationData != null) {
          error = null;
          _locationController.add(Coordinates(
            lat: locationData.latitude,
            lon: locationData.longitude,
          ));
        }
      });
    }
  }
}
