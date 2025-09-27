import 'dart:async';
import 'package:campus_mobile/app_networking.dart';
import 'package:campus_mobile/core/models/map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapSearchService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<MapSearchModel> _results = [];

  Future<bool> fetchLocations(String location) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String? _response = await NetworkHelper.fetchData(
          dotenv.get('MAP_BASE_ENDPOINT') + '?query=' + location + '&region=0');
      if (_response != 'null') {
        /// parse data
        final data = mapSearchModelFromJson(_response!);
        _results = data;
      } else {
        _results = [];
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<MapSearchModel> get results => _results;
}
