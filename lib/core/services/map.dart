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

  /// Fetches locations from ESRI POINTS OF INTEREST
  Future<bool> fetchESRILocations(String poi) async {
    final poi_endpoint = 'https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Points_Of_Interest/FeatureServer/0';
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      print("============Fetching data from: ");
      print(poi_endpoint + '/query?where=Subclass=\'' + poi + '\'' + '&outFields=*' + '&f=json');
      // https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Points_Of_Interest/FeatureServer/0/query?where=Subclass='ATMs'&outFields=*&f=json
      var _response = await NetworkHelper.fetchData(
          poi_endpoint + '/query?where=Subclass=\'' + poi + '\'' + '&outFields=*' + '&f=json');
      if (_response != 'null') {
        /// parse data
        final data = esriPOIModelFromJson(_response!);
        _esriResults = data;
        print("============Data fetched: ");
        print(_esriResults);
      } else {
        _esriResults = [];
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
  List<EsriPOIModel> get esriResults => _esriResults;
}
