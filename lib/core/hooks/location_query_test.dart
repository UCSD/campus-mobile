import 'dart:async';
import 'dart:ffi';
import 'package:fquery/fquery.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:geolocator/geolocator.dart';

UseQueryResult<Coordinates, dynamic> useFetchLocation() {
  final hook = useQuery(['location'], () async {
    // check permission
    bool serviceStatus = await Geolocator.isLocationServiceEnabled();
    Position? currentPosition;

    if (!serviceStatus) {
      LocationPermission locationPermission =
          await Geolocator.requestPermission();
      if (locationPermission.name == "always" ||
          locationPermission.name == "whileInUse") {
        // fetch position coordinates?

        // Geolocator.getPositionStream
        Geolocator.getCurrentPosition().then((position) {
          currentPosition = position;
        });
      }
    } else {
      // fetch position coordinates?
      Position? currentPosition;
      // Geolocator.getPositionStream
      Geolocator.getCurrentPosition().then((position) {
        currentPosition = position;
      });
    }
    return Coordinates(
        lat: currentPosition?.latitude, lon: currentPosition?.longitude);
  }); //  refetchInterval: const Duration(seconds: 5)

  return hook;
}
