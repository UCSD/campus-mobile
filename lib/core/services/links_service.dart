import 'dart:async';

<<<<<<< HEAD
import 'package:campus_mobile_beta/core/models/links_model.dart';
import 'package:campus_mobile_beta/core/services/networking.dart';
=======
import 'package:campus_mobile/core/models/links_model.dart';
import 'package:campus_mobile/core/services/networking.dart';
>>>>>>> 41519e4... implement links card

class LinksService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": ":application/json",
  };
  final String endpoint =
      "https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/quick_links/ucsd-quicklinks-v3.json";

  Future<List<LinksModel>> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      final data = linksFromJson(_response);
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
