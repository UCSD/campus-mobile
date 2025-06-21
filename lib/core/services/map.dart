import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/esri_poi.dart';
import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapSearchService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<MapSearchModel> _results = [];
  List<EsriPOIModel> _esriResults = [];

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

  /// Fetches locations from an ESRI POINTS OF INTEREST
  /// This function is used for the Search bar.
  Future<bool> fetchESRILocations(String searchText) async {
    final poi_endpoint = 'https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Points_Of_Interest/FeatureServer/0/query';
    // Escape any single-quotes in the user’s text
    final escapedSearchText = searchText.trim().replaceAll("'", "''");
    // Build a raw SQL WHERE clause for general search
    final whereClause = """
      C3DName            LIKE '$escapedSearchText%'
      OR UpdatedName     LIKE '$escapedSearchText%'
      OR C3DCategories   LIKE '$escapedSearchText%' 
      OR Class           LIKE '$escapedSearchText%'
      OR Subclass        LIKE '$escapedSearchText%'
      OR C3DKeywords     LIKE '$escapedSearchText%'
      OR UpdatedKeywords LIKE '$escapedSearchText%'
      OR C3DDescription  LIKE '$escapedSearchText%'
      """;
    final params = {
      'where': whereClause,
      'outFields': '*',
      'f': 'json',
    };
    final uri = Uri.parse(poi_endpoint).replace(queryParameters: params);
    _error = null;
    _isLoading = true;

    try {
      print('======== Fetching GENERAL data from: ' + uri.toString());
      var _response = await NetworkHelper.fetchData(uri.toString());
      if (_response != 'null') {
        /// parse data
        print(_response);
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
  List<MapSearchModel> get results => _results;
  List<EsriPOIModel> get esriResults => _esriResults;
}
