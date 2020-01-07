import 'dart:async';
import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class SpecialEventsService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String endpoint =
      "https://2wxnokqsz2.execute-api.us-west-2.amazonaws.com/dev/GetActiveSpecialEvent";

  Future<SpecialEventsModel> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      final specialEventsModel = specialEventsModelFromJson(_response);
      _isLoading = false;
      return specialEventsModel;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return SpecialEventsModel();
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
