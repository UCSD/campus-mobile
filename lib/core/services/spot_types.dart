import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotTypesService {
  SpotTypesService() {
    fetchSpotTypesData();
  }

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  /// MODELS
  SpotTypeModel _spotTypeModel = SpotTypeModel();

  Future<bool> fetchSpotTypesData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await NetworkHelper.fetchData(dotenv.get('SPOT_TYPES_ENDPOINT'));
      _spotTypeModel = spotTypeModelFromJson(_response);
      return true;
    } catch (e) {
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
  SpotTypeModel get spotTypeModel => _spotTypeModel;
}
