import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_model.dart';
/// TODO FIX
// Location Service (Performs API Calls)
class PlaceService {
  PlaceService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  final String requestURL =
      "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?f=pjson&SingleLine=";

  PlaceModel _placeModel = PlaceModel();

  Future<bool> fetchPlaceData(String place) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
      await (_networkHelper.authorizedFetch(requestURL + place + "&token=", headers));  /// TODO: Find if this is the way to put access token in url

      /// parse data
      _placeModel = placeModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await getNewArcGISToken()) {
          return await fetchPlaceData(place);
        }
      }

      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> getNewArcGISToken() async {
    final clientId = "i4SJG8P4dIUx8j68";
    final clientSecret = "a5fd8ef37c4b4bcba7735725bbf49c2b";

    final String tokenEndpoint = "https://admin-enterprise-gis.ucsd.edu/portal/sharing/rest/oauth2/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization":
      "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
    };
    final Map<String, dynamic> params = {
      "client_id": clientId,
      "client_secret": clientSecret,
      "grant_type": "client_credentials",
      "f": "json"
    };

    try {
      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, params);

      headers["Authorization"] = "Bearer " + response["access_token"];

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String? get error => _error;
  PlaceModel? get placeModel => _placeModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
