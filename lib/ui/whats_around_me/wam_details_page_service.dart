import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page_model.dart';

class PlaceDetailsService {
  // Instance Variables
  bool _isLoading = false;                              // For Network Request Status
  String? _error;                                       // For Error Catch
  DateTime? _lastUpdated;                               // Timestamp
  PlaceDetailsModel? _data;
  final NetworkHelper _networkHelper = NetworkHelper(); // For networkHelper use   // You also need a Request URL (where is the API located)
  final String _placeDetailsAPIEndPoint = "https://places-api.arcgis.com/arcgis/rest/services/places-service/v1/places";
  String requestedFields = "address:streetAddress,address:locality,address:designatedMarketArea,address:region,address:postcode,address:poBox,address:country,location,categories,name,description,contactInfo:telephone,contactInfo:website,contactInfo:fax,contactInfo:email,socialMedia:facebookId,socialMedia:twitter,socialMedia:instagram,rating:price,rating:user,hours:opening,hours:popular,hours:openingText";
  PlaceDetailsService();                                // Service's noArgs Constructor
  PlaceDetailsModel _placeDetailsModel = PlaceDetailsModel();

  // Fetch place details by place ID
  Future<bool> fetchPlaceDetails(String placeId) async {
    _isLoading = true;
    _error = null;

    try {
      // Generate ArcGIS token
      String token = await _networkHelper.generateArcGISToken();
      print('Generated ArcGIS Token: $token');

      // Fetch Place Details Data
      final _response = await (_networkHelper.fetchData('$_placeDetailsAPIEndPoint/$placeId?requestedFields=$requestedFields&f=pjson&token=$token'));
      
      // Parse Data                                    // If Future<PlaceDetailsModel?>, then if (_response.statusCode == 200) { return PlaceDetailsModel.fromJson(_response.data); }
      final data = placeDetailsFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      print('Error fetching place details: $e');
    }
    return false;
  }

  PlaceDetailsModel? get placeDetailsData => _data;
  String? get error => _error;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}