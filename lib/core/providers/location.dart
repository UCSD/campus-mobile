import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class LocationDataProvider extends ChangeNotifier {
  /// STATES
  String? error;
  var _permission = false;
  late LocationPermission locationPermission;

  /// SERVICES
  final locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  var _locationController = StreamController<Coordinates>.broadcast();

  LocationDataProvider() {
    locationStream;
    _init();
  }

  _init() async {
    /// check to see if gps service is enabled on device
    var serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (!serviceStatus) {
      /// check to see if permission has been granted to the app
      locationPermission = await Geolocator.requestPermission();
      if (_permission) _enableListener();
    } else {
      _permission = true;
      _enableListener();
    }
  }

  _enableListener() {
    if (_permission) {
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position? position) {
                if (position == null) error = ErrorConstants.locationFailed;
                _locationController.add(Coordinates(
                  lat: position?.latitude,
                  lon: position?.longitude
                ));
          });
    }
  }

  /// SIMPLE GETTERS
  Stream<Coordinates> get locationStream => _locationController.stream;
}
