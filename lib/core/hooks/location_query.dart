import 'dart:async';
import 'package:fquery/fquery.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/cupertino.dart';

UseQueryResult<Coordinates, dynamic> useFetchLocation() {
  return useQuery(['location'], () async {
    bool _permission = false;
    late LocationPermission locationPermission;
    String? error;
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Position? storedPosition;
    double distanceThreshold = 100;
    late Coordinates coordinates;


    // enable listener in order to get positions in a stream
    _enableListener() {
      if (_permission) {
        Timer.periodic(Duration(seconds: 5), (timer) {
          // fetch position and compare it
          Position? currentPosition;
          Geolocator.getCurrentPosition().then((position) {
            currentPosition = position;
            if (storedPosition == null) {
              storedPosition = currentPosition;
              coordinates = Coordinates(
                  lat: storedPosition?.latitude,
                  lon: storedPosition?.longitude);
            } else if (Geolocator.distanceBetween(
                storedPosition!.latitude,
                storedPosition!.longitude,
                currentPosition!.latitude,
                currentPosition!.longitude) > distanceThreshold){
              // update the storedPosition
              storedPosition = currentPosition;
              // do something
              coordinates = Coordinates(
                  lat: storedPosition?.latitude,
                  lon: storedPosition?.longitude);
            } else {
              coordinates = Coordinates(
                  lat: currentPosition?.latitude,
                  lon: currentPosition?.longitude);
            }
          });
        });
      }
    }


    /*
    Modified in dining_card.dart

    Debug console:
    Error: The following ProviderNotFoundException was thrown building _SelectionKeepAlive(state:
    I/flutter ( 8495): _SelectionKeepAliveState#27541):
    I/flutter ( 8495): Error: Could not find the correct Provider<Coordinates> above this
    I/flutter ( 8495): _InheritedProviderScope<ShuttleDataProvider?> Widget
    I/flutter ( 8495):
    I/flutter ( 8495): This happens because you used a `BuildContext` that does not include the provider
    I/flutter ( 8495): of your choice. There are a few common scenarios:

    Run time console:
    framework.dart: failed assertion
     */
    /// check to see if gps service is enabled on device
    bool serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (!serviceStatus) {
      /// check to see if permission has been granted to the app
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission.name == "always"
          || locationPermission.name == "whileInUse") {
        storedPosition = await Geolocator.getLastKnownPosition();
        coordinates = Coordinates(
            lat: storedPosition?.latitude,
            lon: storedPosition?.longitude);
        _enableListener();
      }
    } else {
      _permission = true;
      storedPosition = await Geolocator.getLastKnownPosition();
      coordinates = Coordinates(
          lat: storedPosition?.latitude,
          lon: storedPosition?.longitude);
      _enableListener();
    }


    return coordinates;
  });
}
