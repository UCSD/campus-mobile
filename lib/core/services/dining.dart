import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';

class DiningService {
  DiningService() {
    fetchData();
  }

  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<DiningModel>? _data;
  DiningMenuItemsModel? _menuData;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
    "Authorization":
        "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
  };
  String baseEndpoint = "https://api-qa.ucsd.edu:8243/dining/v4.0.0";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          baseEndpoint + '/locations', headers);

      /// parse data
      final data = diningModelFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchMenu(String id) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          baseEndpoint + '/menu/' + id, headers);

      /// parse data
      final data = diningMenuItemsModelFromJson(_response);
      _menuData = data;
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
  List<DiningModel>? get data => _data;
  DiningMenuItemsModel? get menuData => _menuData;
}
