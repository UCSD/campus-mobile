import 'dart:async';
import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class SpecialEventsService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  SpecialEventsModel _specialEventsModel = SpecialEventsModel();

  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String endpoint =
      "https://2wxnokqsz2.execute-api.us-west-2.amazonaws.com/dev/GetActiveSpecialEvent/v2";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      _specialEventsModel = specialEventsModelFromJson(_response.toString());
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

  SpecialEventsModel get specialEventsModel => _specialEventsModel;
}