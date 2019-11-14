import 'dart:async';
import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _locationService = new Location();
  bool _permission = false;
  String error;

  StreamController<Coordinates> _locationController =
      StreamController<Coordinates>.broadcast();
  Stream<Coordinates> get locationStream =>
      _locationController.stream.asBroadcastStream();

  LocationService() {
    _init();
  }

  _init() async {
    /// create the settings for location access
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.BALANCED, distanceFilter: 10);

    try {
      /// check to see if gps service is enabled on device
      bool serviceStatus = await _locationService.serviceEnabled();
      if (serviceStatus) {
        /// check to see if permission has been granted to the app
        _permission = await _locationService.requestPermission();
        if (_permission) {
          _enableListener();
        }
      } else {
        /// request the user to turn on gps
        bool serviceStatusResult = await _locationService.requestService();
        if (serviceStatusResult) {
          _init();
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        _permission = false;
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
    }
  }

  _enableListener() {
    if (_permission) {
      _locationService.onLocationChanged().listen((locationData) {
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
