import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotTypesService {
  SpotTypesService() {
    fetchSpotTypesData();
  }
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  SpotTypeModel _spotTypeModel = SpotTypeModel();

  Future<bool> fetchSpotTypesData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(dotenv.get('SPOT_TYPES_ENDPOINT'));
      _spotTypeModel = spotTypeModelFromJson(_response);

      _isLoading = false;
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
  SpotTypeModel get spotTypeModel => _spotTypeModel;
}
