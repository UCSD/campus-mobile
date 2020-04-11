import 'package:campus_mobile_experimental/core/models/free_food_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class FreeFoodService {
  final String base_endpoint =
      'https://9tqs71by9h.execute-api.us-west-2.amazonaws.com/dev/v1/';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  FreeFoodModel _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  FreeFoodService() {
    fetchData();
  }

  Future<bool> fetchData() async {
    print("in fetch data");
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(base_endpoint + 'count/1');

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
      print(base_endpoint + 'increment/' + id);
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
