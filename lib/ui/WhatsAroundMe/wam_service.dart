/// WAM Service used to fetch the points of interest around you
import 'dart:convert';
import 'package:campus_mobile_experimental/ui/WhatsAroundMe/wam_list_model.dart';
import 'package:campus_mobile_experimental/ui/WhatsAroundMe/wam_nearby_search_model.dart';
import '../../app_networking.dart';
import 'package:geolocator/geolocator.dart';

/// Uses ESRI "Nearby Search" API to fetch all the points of interest around you: https://developers.arcgis.com/documentation/mapping-and-location-services/place-finding/nearby-search/#url-request
Future<List<Place>> fetchNearbySearchPlaces(int count) async {
  var _error;
  var _isLoading = true;
  const String esriToken = "AAPTxy8BH1VEsoebNVZXo8HurEBECxvQNl6npvATkbb_hlcfhfk79rCfKobWrsCcCmQweTxAFJBE9fJ-1TkjS0p-g1FP66bFWCf4wCndJBDLUIDaQMTFwe2spC_xe_TM6D03tEp47Bj9_1kjxhWECOxgsf61xi_HdThJnG04h7tseaSMG2xVQAovU4RQwiMjCHb15BCaGW5rPqt0_VbB1ogchLzpuxHI4gLW4wzJihTee3I.AT1_jIaJXaPU";
  // Get the current location (default to Geisel Library)
  var x_longitude = -117.23767559484368;
  var y_latitude = 32.88115782225114;
  try {
    Position position = await getCurrentLocation();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    x_longitude = position.longitude;
    y_latitude = position.latitude;
  } catch (e) {
    print('Error: $e');
  }
  const int radius = 650; // About 0.4 miles
  const String url = "https://places-api.arcgis.com/arcgis/rest/services/places-service/v1/places/near-point";
  Map<String, String> queryParams = {
    "f": "json",
    "x": x_longitude.toString(),
    "y": y_latitude.toString(),
    "radius": radius.toString(),
    "pageSize": count.toString(),
    "token": esriToken,
  };

  Uri uri = Uri.parse(url).replace(queryParameters: queryParams);
  print(uri.toString());

  try {
    /// Fetch data
    String _nearbySearchResponse = await NetworkHelper.fetchData(uri.toString());
    print("===================== API RESPONSE ======================");
    print(_nearbySearchResponse);

    /// Parse the response into the PlacesResponse model
    final placesResponse = PlacesResponse.fromJson(
      json.decode(_nearbySearchResponse),
    );

    /// Extract the list of places
    final places = placesResponse.results.map((result) {
      return Place(
        name: result.name,
        location: "${result.location.y}, ${result.location.x}",
        distanceMi: result.distance,
        category: result.categories.isNotEmpty
            ? result.categories.first.label
            : "N/A",
      );
    }).toList();

    return places;
  } catch (e) {
    _error = e.toString();
    print("Error fetching points of interest: $_error");
    return [];
  } finally {
    _isLoading = false;
  }
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  // Check for location permissions
  permission = await Geolocator.checkPermission();
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

void fetchUserLocation() async {
  try {
    Position position = await getCurrentLocation();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  } catch (e) {
    print('Error: $e');
  }
}

////////////////////////////////////////////////////////////////////////////////
// Random Places Generator (for static, mock data)
// List<Place> generateRandomPlaces(int count) {
//   final random = Random();
//   final names = [
//     "Cafe Luna",
//     "Green Market",
//     "Sunny Park",
//     "Blue Library",
//     "Book Nook",
//     "Rose Garden",
//     "Fit Gym",
//     "Olive Deli",
//     "Bike World",
//     "Tech Hub",
//     "Sunset Cinema",
//     "Java Bean",
//     "Bloom Florist",
//     "Fresh Cuts",
//     "Smoothie Lab",
//     "Cozy Corner",
//     "Vibe Bar",
//     "Glow Spa",
//     "Crafted Studio",
//     "Snack Shack"
//   ];
//   final streets = [
//     "Main St",
//     "Elm Ave",
//     "Hill Rd",
//     "Maple St",
//     "Oak St",
//     "Pine St",
//     "Cedar Ln",
//     "Birch Rd",
//     "River Blvd",
//     "Ocean Way"
//   ];
//   final hours = [
//     "8AM–6PM",
//     "9AM–9PM",
//     "6AM–10PM",
//     "10AM–8PM",
//     "7AM–8PM",
//     "5AM–11PM",
//     "9AM–6PM",
//     "8AM–5PM",
//     "11AM–7PM",
//     "12PM–12AM"
//   ];
//   return List.generate(count, (i) {
//     return Place(
//       name: names[i % names.length],
//       location: streets[random.nextInt(streets.length)],
//       distanceMi: (random.nextDouble() * 5).clamp(0.3, 4.9),
//       category: hours[random.nextInt(hours.length)],
//     );
//   });
// }
