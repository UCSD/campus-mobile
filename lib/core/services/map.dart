import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/esri_poi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapSearchService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<EsriPOIModel> _esriResults = [];

  /// Fetches locations from a ESRI's POINTS OF INTEREST
  /// This function is used for the Search bar.
  Future<bool> fetchESRILocations(String searchText) async {
    // Stem the search text by removing trailing 's' and trimming whitespace
    final stemmedSearchText = searchText.trim().replaceAll(RegExp(r's$'), '');
    // Escape any single-quotes in the user’s text
    final escapedSearchText = stemmedSearchText.replaceAll("'", "''");
    // Build a raw SQL WHERE clause for general search
    final whereClause = dotenv.get('MAP_POI_WHERE_CLAUSE').replaceAll('{query}', escapedSearchText);
    final params = {
      'where': whereClause,
      'outFields': '*',
      'f': 'json',
    };
    final uri = Uri.parse(dotenv.get('MAP_POI_ENDPOINT')).replace(queryParameters: params);
    _error = null;
    _isLoading = true;

    try {
      // print('======== Fetching ' + escapedSearchText + ' data from: ' + uri.toString());
      var _response = await NetworkHelper.fetchData(uri.toString());
      if (_response != 'null') {
        /// parse data
        // print(_response);
        final data = esriPOIModelFromJson(_response);
        _esriResults = data;
        print(_esriResults);
      } else {
        _esriResults = [];
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
  List<EsriPOIModel> get esriResults => _esriResults;
}
