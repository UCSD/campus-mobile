import 'package:campus_mobile_experimental/core/models/free_food_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class FreeFoodService {
  final String base_endpoint =
      'https://api-qa.ucsd.edu:8243/campusevents/1.0.0/';

  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  FreeFoodModel _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  FreeFoodService() {}

  Future<bool> fetchData(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          base_endpoint + 'events/' + id + '/rsvpCount', headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);

      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await fetchData(id);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchMaxCount(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          base_endpoint + 'events/' + id + '/rsvpLimit', headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await fetchMaxCount(id);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> updateCount(String id, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;

    try {
      /// update count
      var _response = await _networkHelper.authorizedPut(
          base_endpoint + 'events/' + id, headers, body);

      if (_response != null) {
        _isLoading = false;
        return true;
      } else {
        throw (_response.toString());
      }
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await updateCount(id, body);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization":
          "Basic RVRaeW9EZ2ZqR1J2VUpWaXNaQXlCcUp2Zk1nYTp6VFU4NXRmR2E0MTliNGh1N0RkYkNIM0JUQTRh"
    };
    try {
      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");
      headers["Authorization"] = "Bearer " + response["access_token"];
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // getters
  String get error => _error;
  FreeFoodModel get freeFoodModel => _data;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
