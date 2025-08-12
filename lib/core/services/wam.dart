/// WAM Service used to fetch the points of interest around you
import 'package:campus_mobile_experimental/core/models/wam.dart';
import 'package:geolocator/geolocator.dart';

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
Future<List<Place>> fetchWhatsAroundYou(int count) async {
  // Default coordinates (Geisel Library)
  var x_longitude = -117.23767559484368;
  var y_latitude = 32.88115782225114;

  // Attempt to get the current location
  try {
    Position position = await getCurrentLocation();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    x_longitude = position.longitude;
    y_latitude = position.latitude;
  } catch (e) {
    print('Error getting location: $e');
  }

  // Default radius // TODO: Make this a user setting
  const double radius = 0.3;

  // Gain access to the esriPOIModel, which contains the search results.
  try {
    /// TODO: Search for each of the categories (restaurant, building, shop, cafe, etc.)
    /// Use the map's Search Bar, you can see how that's done in "quickSearch buttons"
    /// Access the esriPOIModel, which contains the search results and get 3 places of each category.
    /// They should already be sorted by distance from the user.
    /// feed the Place (wam) model with this list
    /// return

    // // Extract the list of places
    // final places = placesResponse.results.map((result) {
    //   return Place(
    //     name: result.name,
    //     location: "${result.location.y}, ${result.location.x}",
    //     distanceFromUser: result.distance,
    //     category: result.categories.isNotEmpty
    //         ? result.categories.first.label
    //         : "N/A",
    //   );
    // }).toList();

    return [];
  } catch (e) {
    print("Error fetching points of interest: $e");
    return [];
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////
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