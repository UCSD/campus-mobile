import 'dart:math';
import 'package:campus_mobile_experimental/ui/WhatsAroundMe/places_list_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
/// TODO: Place this in "app_networking.dart

List<Place> fetchPointsOfInterest(int count) {
  // USE ESRI API to fetch points of interest


  // For each point of interest, extract the following (a.k.a. fill out the model)
  final placeNames = []; // Extract placeNames from ESRI API response
  final streets = []; // Extract streets from ESRI API response
  final distancesMi = []; // Extract distances from ESRI API response
  final businessHours = []; // Extract business hours from ESRI API response

  // For loop that feeds these lists goes here:


  // Putting it all together - list of ALL nearby points of interest
  return List.generate(count, (i) {
    return Place(
      name: placeNames[i],
      location: streets[i],
      distanceMi: distancesMi[i],
      businessHours: businessHours[i],
    );
  });
}

// Generate ESRI Token to access the Points of Interest API
Future<String> generateESRIToken() async {
  final _dio = Dio();
  // Prepare Network Parameters
  final Map<String, String> params = {
    'client_id': dotenv.get('ESRI_CLIENT_ID'),
    'client_secret': dotenv.get('ESRI_CLIENT_SECRET'),
    'grant_type': 'client_credentials',
    'expiration': '1440',
    'f': 'json'
  };

  try {
    final response = await _dio.post(
      dotenv.get('ESRI_TOKEN_ENDPOINT'),
      data: params,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

  // Decode the response (token)
    final Map<String, dynamic> data = response.data;
  // Check for errors in the response
    if (data.containsKey('error')) {
      throw Exception(data['error']['message']);
    }
  // Return the access token
    return data['access_token'];
  } catch (e) {
    throw Exception('Failed to generate ESRI token: $e');
  }
}

////////////////////////////////////////////////////////////////////////////////
// Random Places Generator (for static, mock data)
List<Place> generateRandomPlaces(int count) {
  final random = Random();
  final names = [
    "Cafe Luna",
    "Green Market",
    "Sunny Park",
    "Blue Library",
    "Book Nook",
    "Rose Garden",
    "Fit Gym",
    "Olive Deli",
    "Bike World",
    "Tech Hub",
    "Sunset Cinema",
    "Java Bean",
    "Bloom Florist",
    "Fresh Cuts",
    "Smoothie Lab",
    "Cozy Corner",
    "Vibe Bar",
    "Glow Spa",
    "Crafted Studio",
    "Snack Shack"
  ];
  final streets = [
    "Main St",
    "Elm Ave",
    "Hill Rd",
    "Maple St",
    "Oak St",
    "Pine St",
    "Cedar Ln",
    "Birch Rd",
    "River Blvd",
    "Ocean Way"
  ];
  final hours = [
    "8AM–6PM",
    "9AM–9PM",
    "6AM–10PM",
    "10AM–8PM",
    "7AM–8PM",
    "5AM–11PM",
    "9AM–6PM",
    "8AM–5PM",
    "11AM–7PM",
    "12PM–12AM"
  ];
  return List.generate(count, (i) {
    return Place(
      name: names[i % names.length],
      location: streets[random.nextInt(streets.length)],
      distanceMi: (random.nextDouble() * 5).clamp(0.3, 4.9),
      businessHours: hours[random.nextInt(hours.length)],
    );
  });
}
