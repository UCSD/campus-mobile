import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/models/notifications_freefood.dart';

class FreeFoodService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  FreeFoodModel? _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  FreeFoodService();

  Future<bool> fetchData(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      var _response = await _networkHelper.authorizedFetch(
          dotenv.get('NOTIFICATIONS_GOING_ENDPOINT') +
              'events/' +
              id +
              '/rsvpCount',
          headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);

      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service

      if (e.toString().contains("401")) {
        if (await _networkHelper.getNewToken(headers)) {
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
      String _url = dotenv.get('NOTIFICATIONS_GOING_ENDPOINT') +
          'events/' +
          id +
          '/rsvpLimit';

      /// fetch data
      var _response = await _networkHelper.authorizedFetch(_url, headers);

      /// parse data
      final data = freeFoodModelFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await _networkHelper.getNewToken(headers)) {
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
      String _url = dotenv.get('NOTIFICATIONS_GOING_ENDPOINT') + 'events/' + id;

      /// update count
      var _response = await _networkHelper.authorizedPut(_url, headers, body);

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
        if (await _networkHelper.getNewToken(headers)) {
          return await updateCount(id, body);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> getNewToken() async {
    return _networkHelper.getNewToken(headers);
  }

  // getters
  String? get error => _error;
  FreeFoodModel? get freeFoodModel => _data;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
