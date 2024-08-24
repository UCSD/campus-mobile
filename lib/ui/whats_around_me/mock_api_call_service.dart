// Creates Network Request (i.e. generates tokens, uses NetworkHelper())
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/mock_api_call_model.dart';

/// Step 3) Create the service class to perform API call
class MockAPIService {
  // Instance Variables
  bool _isLoading = false;                              // For Network Request Status
  String? _error;                                       // For Error Catch
  DateTime? _lastUpdated;                               // Timestamp
  final NetworkHelper _networkHelper = NetworkHelper(); // For networkHelper use
  final Map<String, String> headers = {                 // Build Headers
    "accept": "application/json",
  };                                                    // You also need a Request URL (where is the API located)
  final String getLocationTitleURL =
      "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?f=pjson&SingleLine=";
  MockAPIModel _mockAPIModel = MockAPIModel();          // For Model use (we'll feed it with the API response data)

  // Services have noArgs Constructor.
  MockAPIService();

  /// Step 4) Perform API call to desired endpoint and give the data to Model
  Future<bool> fetchLocation(String locationTitle) async {  // Bool because data will be at model and we need to know whether it succeeded.
    // Update Status Variables
    _error = null;
    _isLoading = true;

    /// Step 5) Generate ArcGIS token (last thing needed to perform the API call
    try {
      // Generate ArcGIS token
      String token = await _networkHelper.generateArcGISToken();
      print('Generated ArcGIS Token: $token');

      // Perform API Call using network helper (ESRI doesn't use Authorization token in the header).
      final _response = await _networkHelper.authorizedFetch(
          getLocationTitleURL + locationTitle + " ucsd CA&maxLocations=1&f=pjson&token=" + token,
          headers);  // recall that headers is declared atop.

      // Check the response status
      if (_response.statusCode == 200) {
        /// Step 6) Successful request, place data in Model
        _mockAPIModel = mockAPIModelFromJson(_response);
        print('Response data: $_mockAPIModel');
        // Update Request Status
        _isLoading = false;
        return true;
      } else {
        // Error Handling
        print('Request failed with status: ${_response.statusCode}');
        print('Response body: ${_response.body}');
      }
      // Update Request Status
      _isLoading = false;
      return false;
    }
    catch (e) {
      // Handle any errors that occur during the request
      _error = e.toString();
      // Update Request Status
      _isLoading = false;
      print('Error: $e');
      return false;
    }
  }

  /// Step 7) Put these getters here so that the Provider file can easily access this service.
  String? get error => _error;
  MockAPIModel? get getMockAPIModel => _mockAPIModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
