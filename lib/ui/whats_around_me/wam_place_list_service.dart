import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';

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

  // Fetch place details by place ID
  Future<bool> fetchPlacesByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;

    try {
      // Generate ArcGIS token
      String token = await _networkHelper.generateArcGISToken();
      print('Generated ArcGIS Token: $token');

      // Get student's x and y coordinates
      double x = -117.237;      // Longitude
      double y = 32.88;         // Latitude

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
