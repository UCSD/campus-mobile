/// WAM Service used to fetch the points of interest around you
import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/wam_list_model.dart';
import 'package:campus_mobile_experimental/core/models/wam_nearby_search_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../app_networking.dart';
import 'package:geolocator/geolocator.dart';

/// Fetches a list of nearby places using the ESRI "Nearby Search" API.
///
/// This function retrieves the user's current location,
/// constructs a query to the ESRI Nearby Search API,
/// and parses the response into a list of `Place` objects.
///
/// **Parameters:**
/// - `count` (*int*): The maximum number of results to fetch from the API.
///
/// **Returns:**
/// - A `Future` that resolves to a `List<Place>` containing the nearby points of interest.
///
/// **API Reference:**
/// - [ESRI Nearby Search API Documentation](https://developers.arcgis.com/documentation/mapping-and-location-services/place-finding/nearby-search/#url-request)
///
/// **Notes:**
/// - The search radius is currently set to 650 meters (~0.4 miles) and can be made configurable in the future.
/// - If location services are unavailable or permissions are denied, the function defaults to the Geisel Library coordinates.
/// - The function requires the following environment variables to be set:
///   - `WAM_NEARBY_SEARCH_TOKEN`: The API token for authentication.
///   - `WAM_NEARBY_SEARCH_ENDPOINT`: The base URL of the ESRI Nearby Search API.
///
/// **Exceptions:**
/// - Prints error messages to the console if location services fail or the API request encounters an issue.
///
/// **Example Usage:**
/// ```dart
/// List<Place> places = await fetchNearbySearchPlaces(10);
/// ```
Future<List<Place>> fetchNearbySearchPlaces(int count) async {
  // Default coordinates (Geisel Library)
  var x_longitude = -117.23767559484368;
  var y_latitude = 32.88115782225114;

  // Fetch environment variables
  String? esriToken = dotenv.env['WAM_NEARBY_SEARCH_TOKEN'];
  String? nearbySearchURL = dotenv.env['WAM_NEARBY_SEARCH_ENDPOINT'];

  // Attempt to get the current location
  try {
    Position position = await getCurrentLocation();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    x_longitude = position.longitude;
    y_latitude = position.latitude;
  } catch (e) {
    print('Error getting location: $e');
  }

  // Define query parameters
  const int radius = 650; // About 0.4 miles // TODO: Make this a user setting
  Map<String, String> queryParams = {
    "f": "json",
    "x": x_longitude.toString(),
    "y": y_latitude.toString(),
    "radius": radius.toString(),
    "pageSize": count.toString(),
    "token": esriToken!,
  };

  // Construct the URI
  Uri uri = Uri.parse(nearbySearchURL!).replace(queryParameters: queryParams);
  print(uri.toString());

  // Fetch and process data
  try {
    String _nearbySearchResponse = await NetworkHelper.fetchData(uri.toString());
    final placesResponse = PlacesResponse.fromJson(json.decode(_nearbySearchResponse));

    // Extract the list of places
    final places = placesResponse.results.map((result) {
      return Place(
        name: result.name,
        location: "${result.location.y}, ${result.location.x}",
        distanceMeters: result.distance,
        category: result.categories.isNotEmpty
            ? result.categories.first.label
            : "N/A",
      );
    }).toList();

    return places;
  } catch (e) {
    print("Error fetching points of interest: $e");
    return [];
  }
}

/// Retrieves the user's current location with high accuracy.
///
/// This function checks if location services are enabled and ensures the necessary
/// permissions are granted. If location services are disabled or permissions are denied,
/// it throws an exception. Once all checks pass, it fetches the user's current location
/// using the `Geolocator` package.
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
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

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
void fetchUserLocation() async {
  try {
    Position position = await getCurrentLocation();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  } catch (e) {
    print('Error: $e');
  }
}
