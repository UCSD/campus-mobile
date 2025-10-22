import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AvailabilityService {
  AvailabilityService();

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  /// MODELS
  late List<AvailabilityModel> _data;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await NetworkHelper.authorizedFetch(dotenv.get('AVAILABILITY_API_ENDPOINT'), headers);

      /// parse data
      final data = availabilityStatusFromJson(_response);
      _data = data.data;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await NetworkHelper.getNewToken(headers)) return await fetchData();
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<AvailabilityModel> get data => _data;
}
