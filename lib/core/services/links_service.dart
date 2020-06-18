import 'dart:async';

import 'package:campus_mobile_experimental/core/models/links_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class LinksService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String endpoint =
      "https://ucsd-its-wts-dev.s3-us-west-1.amazonaws.com/replatform/v1/links.json";

  List<LinksModel> _linksModels = List<LinksModel>();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      _linksModels = linksModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;

  List<LinksModel> get linksModels => _linksModels;
}
