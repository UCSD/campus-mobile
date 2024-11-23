import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DiningService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  /// MODELS
  List<DiningModel>? _data;
  DiningMenuItemsModel? _menuData;

  /// SERVICES
  final _networkHelper = NetworkHelper();

  DiningService() { fetchData(); }

  Future<bool> fetchData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          dotenv.get('DINING_BASE_ENDPOINT') + '/locations', headers);

      /// parse data
      final data = diningModelFromJson(_response);
      _data = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await _networkHelper.getNewToken(headers)) {
          return await fetchData();
        }
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> fetchMenu(String id) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          dotenv.get('DINING_BASE_ENDPOINT') + '/menu/' + id, headers);

      /// parse data
      final data = diningMenuItemsModelFromJson(_response);
      _menuData = data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await _networkHelper.getNewToken(headers)) {
          return await fetchMenu(id);
        }
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<DiningModel>? get data => _data;
  DiningMenuItemsModel? get menuData => _menuData;
}
