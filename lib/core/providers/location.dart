import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class LocationDataProvider extends ChangeNotifier {
  /// STATES
  bool serviceEnabled = false;
  String? error;
  late LocationPermission permission = LocationPermission.denied;

  /// SERVICES
  final locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100);
  var _locationController = StreamController<Coordinates>.broadcast();

  LocationDataProvider() {
    locationStream;
    permission;
    _init();
  }

  _init() async {
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _enableListener();
    return await Geolocator.getCurrentPosition();
  }

  void _enableListener() {
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      if (position == null) error = ErrorConstants.locationFailed;
      _locationController.add(Coordinates(lat: position?.latitude, lon: position?.longitude));
    });
  }

  /// SIMPLE GETTERS
  Stream<Coordinates> get locationStream => _locationController.stream;
}
