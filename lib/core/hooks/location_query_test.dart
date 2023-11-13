import 'dart:async';
import 'dart:ffi';
import 'package:fquery/fquery.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:geolocator/geolocator.dart';

/*
 * For the version in this file, I'm fetching the Stream itself in the hook,
 * and change the return object coordinates according to the stream outside
 * the hook.
 *
 */
UseQueryResult<Coordinates, dynamic> useFetchLocation() {
  Stream<Position>? posStream;
  Position? currentPosition;
  late Coordinates coordinates;

  final hook = useQuery(['location'], () async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    // check permission
    bool serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (!serviceStatus) {
      LocationPermission locationPermission =
          await Geolocator.requestPermission();
      if (locationPermission.name == "always" ||
          locationPermission.name == "whileInUse") {
        // Geolocator.getPositionStream
        posStream =
            Geolocator.getPositionStream(locationSettings: locationSettings);
      }
    } else {
      // Geolocator.getPositionStream
      posStream =
          Geolocator.getPositionStream(locationSettings: locationSettings);
    }
    return coordinates;
  }); //  refetchInterval: const Duration(seconds: 5)

  posStream?.listen((Position? position) {
    // do something
    // ...
    coordinates =
        Coordinates(lat: position?.latitude, lon: position?.longitude);
  });

  return hook;
}
