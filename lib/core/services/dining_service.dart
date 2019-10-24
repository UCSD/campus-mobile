import 'dart:async';
import 'package:campus_mobile_beta/core/models/dining_menu_items_model.dart';
import 'package:campus_mobile_beta/core/models/dining_model.dart';
import 'package:campus_mobile_beta/core/services/networking.dart';

class DiningService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final String baseEndpoint =
      "https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v3/dining/";

  Future<List<DiningModel>> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.fetchData(baseEndpoint + 'locations');

      /// parse data
      final data = diningModelFromJson(_response);
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return List<DiningModel>();
    }
  }

  Future<DiningMenuItemsModel> fetchMenu(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.fetchData(baseEndpoint + 'menu/' + id);

      /// parse data
      final data = diningMenuItemsModelFromJson(_response);
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return DiningMenuItemsModel();
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
