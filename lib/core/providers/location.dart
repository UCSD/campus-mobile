import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class LocationDataProvider extends ChangeNotifier {
  /// STATES
  bool _permission = false;
  String? error;
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

  @override
  void dispose() {
    _locationController.close();
    super.dispose();
  }

  _init() async {
    /// Check to see if GPS service is enabled on device
    var serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (!serviceStatus) {
      // Prompt the user to enable the GPS
      error = 'Location services are disabled. Please enable them in settings.';
    } else {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        error = 'Location permissions are denied';
      } else if (locationPermission == LocationPermission.deniedForever) {
        error =
            'Location permissions are permanently denied, we cannot request permissions.';
      } else {
        _permission = true;
        _enableListener();
      }
    }
  }

  void _enableListener() {
    if (_permission) {
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
        if (position == null) {
          error = 'Failed to get location. Position is null.';
          _locationController.addError('Failed to get location');
        } else {
          _locationController.add(
              Coordinates(lat: position.latitude, lon: position.longitude));
        }
      }, onError: (e) {
        error = e.toString();
        _locationController.addError('Failed to get location: $e');
      });
    }
  }

  /// SIMPLE GETTERS
  Stream<Coordinates> get locationStream => _locationController.stream;
}
