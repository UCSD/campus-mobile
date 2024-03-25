import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/notifications_freefood.dart';

class FreeFoodService {
  final String baseEndpoint =
      'https://api-qa.ucsd.edu:8243/campusevents/1.0.0/';

  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  FreeFoodModel? _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
    "Authorization":
        "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
  };

  FreeFoodService();

  Future<bool> fetchData(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      var _response = await _networkHelper.authorizedFetch(
          baseEndpoint + 'events/' + id + '/rsvpCount', headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);

      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchMaxCount(String id) async {
    _error = null;
    _isLoading = true;
    try {
      String _url = baseEndpoint + 'events/' + id + '/rsvpLimit';

      /// fetch data
      var _response = await _networkHelper.authorizedFetch(_url, headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> updateCount(String id, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;

    try {
      String _url = baseEndpoint + 'events/' + id;

      /// update count
      var _response = await _networkHelper.authorizedPut(_url, headers, body);

      if (_response != null) {
        _isLoading = false;
        return true;
      } else {
        throw (_response.toString());
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  // getters
  String? get error => _error;
  FreeFoodModel? get freeFoodModel => _data;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
