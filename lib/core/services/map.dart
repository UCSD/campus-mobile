import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapSearchService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<MapSearchModel> _mapSearchResults = [];

  /// Fetches locations from a ESRI's POINTS OF INTEREST
  /// This function is used for the Search bar.
  Future<bool> fetchESRILocations(String searchText) async {
    final params = {
      'isWAM': 'false',
      'searchTerm': searchText,
    };
    final uri = Uri.parse(dotenv.get('CAMPUS_MAP_SEARCH_ENDPOINT')).replace(queryParameters: params);
    _error = null;
    _isLoading = true;

    try {
      // print('======== Fetching ' + escapedSearchText + ' data from: ' + uri.toString());
      var _response = await NetworkHelper.fetchData(uri.toString());
      if (_response != 'null') {
        /// parse data
        // print(_response);
        final data = mapFeatureFromJson(_response);
        _mapSearchResults = data;
        print(_mapSearchResults);
      } else {
        _mapSearchResults = [];
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('======== Error fetching GENERAL data: ' + e.toString());
      return false;
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<MapSearchModel> get mapSearchResults => _mapSearchResults;
}
