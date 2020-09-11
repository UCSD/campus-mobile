import 'dart:async';
import 'package:campus_mobile_experimental/core/data_providers/bluetooth_singleton.dart';
import 'package:campus_mobile_experimental/core/models/coordinates_model.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationDataProvider {
  final Location _locationService = new Location();
  bool _permission = false;
  String error;

  StreamController<Coordinates> _locationController =
      StreamController<Coordinates>.broadcast();
  Stream<Coordinates> get locationStream => _locationController.stream;

  LocationDataProvider() {
    locationStream;
    _init();
  }

  _init() async {
    /// create the settings for location access
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.HIGH, distanceFilter: 100);
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

        /// request the user to turn on gps
     /* PermissionStatus permissionGranted = await  _locationService.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await _locationService.requestPermission();
          if(permissionGranted != PermissionStatus.granted) {
            _permission = false;
          }
          else {
            _enableListener();
          }
      }*/


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
