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
    final whereClausePOI = dotenv.get('MAP_POI_WHERE_CLAUSE').replaceAll('{query}', escapedSearchText);
    final paramsPOI = {
      'where': whereClausePOI,
      'outFields': '*',
      'f': 'json',
    };
    final uriPOI = Uri.parse(dotenv.get('MAP_POI_ENDPOINT')).replace(queryParameters: paramsPOI);
    // Build a raw SQL WHERE clause for public buildings search
    final whereClausePublicBuildings = dotenv.get('MAP_PUBLIC_BUILDINGS_WHERE_CLAUSE').replaceAll('{query}', escapedSearchText);
    final paramsPublicBuildings = {
      'where': whereClausePublicBuildings,
      'outFields': '*',
      'f': 'json',
    };
    final uriPublicBuildings = Uri.parse(dotenv.get('MAP_PUBLIC_BUILDINGS_ENDPOINT')).replace(queryParameters: paramsPublicBuildings);

    _error = null;
    _isLoading = true;
    try {
      // print('======== Fetching ' + escapedSearchText + ' data from: ' + uri.toString());
      var _responsePOI = await NetworkHelper.fetchData(uriPOI.toString());
      if (_responsePOI != 'null') {
        /// parse data
        final data = esriPOIModelFromJson(_responsePOI);
        _esriResults = data;
      } else {
        _esriResults = [];
        return false;
      }
      // return true;
    } catch (e) {
      _error = e.toString();
      print('======== Error fetching Points of Interest data: ' + e.toString());
      return false;
    }

    try {
      // Fetch public buildings data
      var _responsePublicBuildings = await NetworkHelper.fetchData(uriPublicBuildings.toString());
      if (_responsePublicBuildings != 'null') {
        /// parse data (only extract relevant fields)
        final publicBuildingsData = esriPOIModelFromForeignJson(_responsePublicBuildings);
        print('======== Public Buildings results =============');
        print(publicBuildingsData);
        // Merge the two lists
        _esriResults.addAll(publicBuildingsData);
        print('======== Merged results =============');
      }

      print(_esriResults);
      return true;
    } catch (e) {
      _error = e.toString();
      print('======== Error fetching Public Buildings data: ' + e.toString());
      return false;
    }
    finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<EsriPOIModel> get esriResults => _esriResults;
}
