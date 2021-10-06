import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/map.dart';

class MapSearchService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<MapSearchModel> _results = [];
  final NetworkHelper _networkHelper = NetworkHelper();
  final String baseEndpoint =
      "https://0dakeo6qfi.execute-api.us-west-2.amazonaws.com/qa/v2/map/search";

  Future<bool> fetchLocations(String location) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String? _response = await _networkHelper
          .fetchData(baseEndpoint + '?query=' + location + '&region=0');
      if (_response != 'null') {
        /// parse data
        final data = mapSearchModelFromJson(_response!);
        _results = data;
      } else {
        _results = [];
        _isLoading = false;
        return false;
      }
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  bool get isLoading => _isLoading;

  String? get error => _error;

  DateTime? get lastUpdated => _lastUpdated;

  List<MapSearchModel> get results => _results;
}
