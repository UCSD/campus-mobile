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
  final NetworkHelper _networkHelper = NetworkHelper(); // For networkHelper use
  final Map<String, String> headers = {                 // Build Headers
    "accept": "application/json",
  };                                                    // You also need a Request URL (where is the API located)
  final String getLocationTitleURL =
      "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=";
  MockAPIModel _mockAPIModel = MockAPIModel();          // For Model use (we'll feed it with the API response data)

  // Services have noArgs Constructor.
  MockAPIService();

  /// Step 4) Generate ArcGIS token (last thing needed to perform the API call
  Future<String> generateArcGISToken() async {
    // These are fixed client variables that have access to ESRI APIs
    final String clientId = "i4SJG8P4dIUx8j68";
    final String clientSecret = "a5fd8ef37c4b4bcba7735725bbf49c2b";

    // Prepare Network Parameters
    final Map<String, String> params = {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'client_credentials',
      'expiration': '1440', // Token expiration time in minutes (optional)
      'f': 'json',
    };

    // Send the POST request to the endpoint that returns ArcGIS Access Tokens
    final response = await http.post(
      Uri.parse('https://admin-enterprise-gis.ucsd.edu/portal/sharing/rest/oauth2/token'),
      body: params,
    );

    // Decode the response (token)
    final Map<String, dynamic> data = json.decode(response.body);

    // Check for errors in the response
    if (data.containsKey('error')) {
      throw Exception(data['error']['message']);
    }

    // Return the access token
    return data['access_token'];
  }

  /// Step 5) Perform API call to desired endpoint and give the data to Model
  Future<void> fetchLocation(String locationTitle) async {  // Void because data will be at model
    // Update Status Variables
    _error = null;
    _isLoading = true;

    try {
      // Generate ArcGIS token
      String token = await generateArcGISToken();

      // Perform API Call using network helper (ESRI doesn't use Authorization token in the header).
      final _response = await _networkHelper.authorizedFetch(
          getLocationTitleURL + locationTitle + " ucsd CA&maxLocations=1&f=pjson&token=" + token,
          headers);  // recall that headers is declared atop.

      // Check the response status
      if (_response.statusCode == 200) {
        /// Step 6) Successful request, place data in Model
        _mockAPIModel = mockAPIModelFromJson(_response);
        print('Response data: $_mockAPIModel');
      } else {
        // Error Handling
        print('Request failed with status: ${_response.statusCode}');
        print('Response body: ${_response.body}');
      }

      // Update Request Status
      _isLoading = false;
    }
    catch (e) {
      // Handle any errors that occur during the request
      _error = e.toString();
      // Update Request Status
      _isLoading = false;
      print('Error: $e');
    }
  }

  /// Step 7) Put these getters here so that the Provider file can easily access this service.
  String? get error => _error;
  MockAPIModel? get getMockAPIModel => _mockAPIModel;
  bool get isLoading => _isLoading;
}
