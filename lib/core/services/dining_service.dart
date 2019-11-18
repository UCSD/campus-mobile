import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'package:flutter/material.dart';

class DiningService extends ChangeNotifier {
  DiningService() {
    fetchData();
  }

  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  List<DiningModel> _data;
  DiningMenuItemsModel _menuData;

  List<DiningModel> get data => _data;
  final NetworkHelper _networkHelper = NetworkHelper();
  final String baseEndpoint =
      "https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v3/dining/";

  fetchData() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      /// fetch data
      String _response =
          await _networkHelper.fetchData(baseEndpoint + 'locations');

      /// parse data
      final data = diningModelFromJson(_response);
      _isLoading = false;

      _data = data;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  fetchMenu(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.fetchData(baseEndpoint + 'menu/' + id);

      /// parse data
      final data = diningMenuItemsModelFromJson(_response);
      _menuData = data;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  DiningMenuItemsModel get menuData => _menuData;
}
