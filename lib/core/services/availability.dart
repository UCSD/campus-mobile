import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';

class AvailabilityService {
  AvailabilityService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<AvailabilityModel>? _data;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider
  List<AvailabilityModel>? get data => _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (_networkHelper.authorizedFetch(
          "https://api-qa.ucsd.edu:8243/campusbusyness/v1/busyness", {
        "Authorization":
            "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
      }));

      /// parse data
      final data = availabilityStatusFromJson(_response);

      _isLoading = false;
      _data = data.data;
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
}
