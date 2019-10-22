import 'dart:async';

import 'package:campus_mobile_beta/core/models/links_model.dart';
import 'package:campus_mobile_beta/core/services/networking.dart';

class LinksService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": ":application/json",
  };
  final String endpoint =
      "https://tbk5wko7a9.execute-api.us-west-1.amazonaws.com/dev/msm-linksservice/v1";

  Future<List<LinksModel>> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      final data = linksModelFromJson(_response);
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return List<LinksModel>();
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
