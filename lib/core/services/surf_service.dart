import 'dart:async';

import 'package:campus_mobile_experimental/core/models/surf_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class SurfService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  SurfModel _surfModel = SurfModel();

  final String endpoint =
      "https://7stc0zwsa8.execute-api.us-west-1.amazonaws.com/dev/msm-surfservice/v1/surfforecast";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      _surfModel = surfModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  SurfModel get surfModel => _surfModel;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
}
