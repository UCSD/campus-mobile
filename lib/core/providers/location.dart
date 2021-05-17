import 'dart:async';

import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

class LocationDataProvider extends ChangeNotifier {
  final Location _locationService = new Location();
  bool _permission = false;
  String error;

  StreamController<Coordinates> _locationController =
      StreamController<Coordinates>.broadcast();
  Stream<Coordinates> get locationStream => _locationController.stream;

  Location get locationObject => _locationService;
  LocationDataProvider() {
    locationStream;
    _init();
  }

  _init() async {
    /// create the settings for location access
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 100);

    /// check to see if gps service is enabled on device
    bool serviceStatus = await _locationService.serviceEnabled();
    if (!serviceStatus) {
      /// check to see if permission has been granted to the app
      _permission = await _locationService.requestService();
      if (_permission) {
        _enableListener();
      }
    } else {
      _permission = true;
      _enableListener();
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
