import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';
import 'package:geolocator/geolocator.dart';

// Location Service (Performs API Calls)
class PlacesByCategoryService {
  // Instance Variables
  bool _isLoading = false;                              // For Network Request Status
  String? _error;                                       // For Error Catch
  DateTime? _lastUpdated;                               // Timestamp
  PlacesByCategoryModel? _data;
  final NetworkHelper _networkHelper = NetworkHelper(); // For networkHelper use   // You also need a Request URL (where is the API located)
  final String _nearbySearchAPIEndPoint = "https://places-api.arcgis.com/arcgis/rest/services/places-service/v1/places/near-point";
  PlacesByCategoryService();                            // Service's noArgs Constructor
  PlacesByCategoryModel _placesByCategoryModel = PlacesByCategoryModel();

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
  
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
  
    // Check for permission to access location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
  
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  
    // Get the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Fetch place details by place ID
  Future<bool> fetchPlacesByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;

    try {
      // Generate ArcGIS token
      String token = await _networkHelper.generateArcGISToken();
      print('Generated ArcGIS Token: $token');

      // Get student's x and y coordinates
      Position position = await _getCurrentLocation();
      double x = position.longitude;
      double y = position.latitude;
      // double x = -117.237;      // Longitude
      // double y = 32.88;         // Latitude

      // Fetch Place Details Data
      final _response = await (_networkHelper.fetchData('$_nearbySearchAPIEndPoint?x=$x&y=$y&radius=1000&$categoryId&pageSize=5&f=pjson&token=$token'));

      // Parse Data
      final data = placesByCategoryFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      print('Error fetching place details: $e');
    }
    return false;
  }

  PlacesByCategoryModel? get placesByCategoryData => _data;
  String? get error => _error;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
