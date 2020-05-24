import 'package:campus_mobile_experimental/core/models/free_food_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class FreeFoodService {
  final String base_endpoint =
      'https://9tqs71by9h.execute-api.us-west-2.amazonaws.com/dev/v1/';
  // https://9tqs71by9h.execute-api.us-west-2.amazonaws.com/dev/v1/setmaxcount/
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  FreeFoodModel _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  FreeFoodService() {
  }

  Future<bool> fetchData(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(base_endpoint + 'count/' + id);

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
      /// fetch data
      String _response = await _networkHelper.fetchData(base_endpoint + 'maxcount/' + id);

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

  // Future<bool> setMaxCount(String id) async {
  //   _error = null;
  //   _isLoading = true;
  //   print("in fetch max count " + id);
  //   try {
  //     /// fetch data
  //     String _response = await _networkHelper.fetchData(base_endpoint + 'setmaxcount/' + id);
  //     print("response" + _response.toString());

  //     /// parse data
  //     final data = freeFoodModelFromJson(_response);
  //     _isLoading = false;
  //     _data = data;
  //     return true;
  //   } catch (e) {
  //     _error = e.toString();
  //     _isLoading = false;
  //     return false;
  //   }
  // }

  Future<bool> decrementCount(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(base_endpoint + 'decrement/' + id);

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

  Future<bool> incrementCount(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(base_endpoint + 'increment/' + id);

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

  // getters
  String get error => _error;
  FreeFoodModel get freeFoodModel => _data;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
