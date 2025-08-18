/// WAM Service used to fetch the points of interest around you
import 'dart:math';
import 'package:campus_mobile_experimental/core/models/wam.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campus_mobile_experimental/core/models/esri_poi.dart';
import 'package:campus_mobile_experimental/app_networking.dart';

List<EsriPOIModel> _nearbyLocations = [];

// Default coordinates (Geisel Library)
var x_longitude = -117.23767559484368;
var y_latitude = 32.88115782225114;

// Default radius // TODO: Make this a user setting
const double radius = 0.3;

/// Fetches a list of nearby places by querying Points of Interest with different categories
/// such as restaurants, buildings, shops, cafes, etc.
///
/// **Parameters:**
/// - `count` (*int*): The maximum number of results to fetch from the API.
///
/// **Returns:**
/// - A `Future` that resolves to a `List<Place>` containing the nearby points of interest.
///
/// **Notes:**
/// - The search radius is currently set to 650 meters (~0.4 miles) and can be made configurable in the future.
/// - If location services are unavailable or permissions are denied, the function defaults to the Geisel Library coordinates.
///
/// **Exceptions:**
/// - Prints error messages to the console if location services fail or the API request encounters an issue.
///
/// **Example Usage:**
/// ```dart
/// List<Place> places = await fetchNearbySearchPlaces(13);
/// ```
Future<List<Place>> fetchWhatsAroundMe(int count) async {
  // Attempt to get the current location
  try {
    Position position = await getCurrentLocation();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    x_longitude = position.longitude;
    y_latitude = position.latitude;
  } catch (e) {
    print('Error getting location: $e');
  }

  final whereClause = dotenv.get('WAM_WHERE_CLAUSE');
  final params = {
    'where': whereClause,
    'outFields': '*',
    'f': 'json',
  };
  final uri = Uri.parse(dotenv.get('MAP_POI_ENDPOINT'))
      .replace(queryParameters: params);

  // Gain access to the esriPOIModel, which contains the search results.
  try {
    /// TODO: Search for each of the categories (restaurant, building, shop, cafe, etc.)
    /// Use the map's Search Bar, you can see how that's done in "quickSearch buttons"
    ///  Provider.of<MapsDataProvider>(context, listen: false)
    //                     .searchBarController
    //                     .text = 'restaurants';
    ///
    ///  Provider.of<MapsDataProvider>(context, listen: false)
    //                     .searchBarController
    //                     .text = 'buildings';
    ///
    ///  Provider.of<MapsDataProvider>(context, listen: false)
    //                     .searchBarController
    //                     .text = 'stores';
    ///
    ///  Provider.of<MapsDataProvider>(context, listen: false)
    //                     .searchBarController
    //                     .text = 'Stuart';
    ///
    ///  Provider.of<MapsDataProvider>(context, listen: false)
    //                     .searchBarController
    //                     .text = 'centers';
    /// Access the esriPOIModel, which contains the search results and get 3 places of each category.
    /// They should already be sorted by distance from the user.
    /// feed the Place (wam) model with this list
    print('======== Fetching data from: ' + uri.toString());
    var _response = await NetworkHelper.fetchData(uri.toString());
    if (_response != 'null') {
      /// parse data
      final data = esriPOIModelFromJson(_response);
      _nearbyLocations = data;
      print("==========================");
      print(_nearbyLocations);
    } else {
      _nearbyLocations = [];
    }

    // Populate WAM distances
    for (EsriPOIModel model in _nearbyLocations) {
      if (model.attributes.latitude != null &&
          model.attributes.longitude != null) {
        var distance = calculateDistance(y_latitude, x_longitude,
            model.attributes.latitude!, model.attributes.longitude!);
        model.distance = distance as double?;
      }
    }

    // Sort locations by distance from user
    _nearbyLocations.sort((EsriPOIModel a, EsriPOIModel b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return 0;
    });

    // Extract the list of places
    final wamResults = _nearbyLocations.map((result) {
      return Place(
        name: result.attributes.updatedName ??
            ((result.attributes.subclass ?? "") +
                " - " +
                (result.attributes.facilityLongName ?? "")),
        location: "${result.geometry.y}, ${result.geometry.x}",
        distanceFromUser: result.distance ?? 1000.0, // Default to 1000 if distance is null
        category: result.attributes.classType ?? "N/A",
      );
    }).toList();

    print("/////////////////////////////////////////////////////");
    print("WAM Results: $wamResults");
    return wamResults;
  } catch (e) {
    print("Error fetching WAM results using POI: $e");
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
