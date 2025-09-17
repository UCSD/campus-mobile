/// WAM Service used to fetch the points of interest around you
import 'dart:math';
import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:campus_mobile_experimental/core/models/wam.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campus_mobile_experimental/app_networking.dart';

// Default coordinates (Geisel Library)
var x_longitude = -117.23767559484368;
var y_latitude = 32.88115782225114;

// Default radius TODO: Make this a user setting
const double radius = 0.3;

// Vessel to hold the fetched nearby locations from POI
List<MapSearchModel> _nearbyLocations = [];

/// Fetches a list of nearby places by querying Points of Interest with different
/// categories such as restaurants, buildings, shops, cafes, etc.
///
/// **Parameters:**
/// - `count` (*int*): The maximum number of results to fetch from the API.
///
/// **Returns:**
/// - A `List<Place>` containing nearby points of interest in a `Place` format.
///
/// **Notes:**
/// - The search radius is currently set to 650 meters (~0.4 miles) and can be made configurable in the future.
/// - If location services are unavailable or permissions are denied, the function defaults to the Geisel Library coordinates.
///
/// **Example Usage:**
/// ```dart
/// List<Place> places = await fetchNearbySearchPlaces(13);
/// ```
Future<List<Place>> fetchWhatsAroundMe(int count) async {
  // Attempt to get the student's current location
  try {
    Position position = await getCurrentLocation();
    // print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    x_longitude = position.longitude;
    y_latitude = position.latitude;
  } catch (e) {
    print(
        'Error getting location: $e, using Geisel Library coordinates instead.');
  }

  // Prepare Points of Interest call
  final Map<String, String> headers = {
    "x-api-key": dotenv.get('CAMPUS_MAP_SEARCH_KEY'),
  };

  // Perform the API call
  try {
    var _response = await NetworkHelper.authorizedFetch(
        dotenv.get('CAMPUS_MAP_SEARCH_ENDPOINT') +
            '?isWAM=true', headers);

    if (_response != 'null') {
      /// parse data
      final data = mapFeatureFromJson(_response);
      _nearbyLocations = data;
    } else {
      _nearbyLocations = [];
    }
  } catch (e) {
    print("Error fetching WAM results: $e");
    return [];
  }

  // Populate distance from student for each location
  for (MapSearchModel model in _nearbyLocations) {
    if (model.attributes.Latitude != null &&
        model.attributes.Longitude != null) {
      var distance = calculateDistance(y_latitude, x_longitude,
          model.attributes.Latitude!, model.attributes.Longitude!);
      model.distance = distance as double?;
    }
  }

  // Sort locations by distance from user
  _nearbyLocations.sort((MapSearchModel a, MapSearchModel b) {
    if (a.distance != null && b.distance != null) {
      return a.distance!.compareTo(b.distance!);
    }
    return 0;
  });

  // Extract only `count` amount of desired attributes to show in the WAM list
  // while avoiding potential duplicates based on `objectId`.
  // Note that distanceFromUser becomes 1000.0 if distance is null so it never shows in the list.
  // Note that places with an "Unknown Location" are also filtered out at the end.
  try {
    final seen = <dynamic>{};
    final wamResults = _nearbyLocations
        .where((result) => seen.add(result.attributes.ObjectId))
        .take(count * 2) // Take more to account for possible filtering
        .map((result) {
          final name = result.attributes.UpdatedName ??
              ((result.attributes.Subclass != null &&
                      result.attributes.FacilityLongName != null)
                  ? result.attributes.Subclass! +
                      " - " +
                      result.attributes.FacilityLongName!
                  : "Unknown Location");
          return Place(
            name: name,
            location:
                "${result.attributes.Latitude}, ${result.attributes.Longitude}",
            distanceFromUser: result.distance ?? 1000.0,
            category: result.attributes.Subclass ?? " ",
          );
        })
        .where((place) => place.name != "Unknown Location")
        .take(count)
        .toList();

    // print("/////////////////////// wamResults ////////////////////////");
    // print("WAM Results: ${wamResults.map((place) => place.toString()).toList()}");
    return wamResults;
  } catch (e) {
    print("Error feeding wamResults: $e");
    return [];
  }
}

num calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  return 12742 * asin(sqrt(a)) * 0.621371;
}

/// If location is enabled, this retrieves the user's location using the `Geolocator` package.
///
/// **Returns:**
/// - A `Future` that resolves to a `Position` object containing the user's current latitude and longitude.
///
/// **Exceptions:**
/// - Throws an `Exception` if:
///   - Location services are disabled.
///   - Location permissions are denied.
///   - Location permissions are permanently denied.
///
/// **Notes:**
/// - Ensure that the app has the required permissions for accessing location services.
/// - This function uses `LocationAccuracy.high` for precise location data.
///
/// **Example Usage:**
/// ```dart
/// try {
///   Position position = await getCurrentLocation();
///   print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
/// } catch (e) {
///   print('Error: $e');
/// }
/// ```
Future<Position> getCurrentLocation() async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Location services are disabled.');

  // Check for location permissions
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied.');
  }

  // Get the current location
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

// Function to print the user's location to the console.
// For testing purposes only.
// void fetchUserLocation() async {
//   try {
//     Position position = await getCurrentLocation();
//     print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
//   } catch (e) {
//     print('Error: $e');
//   }
// }
