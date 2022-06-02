import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';

class ShuttleService {
  ShuttleService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<ShuttleStopModel> _data = [];

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  List<ShuttleStopModel> get data => _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;

    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(
          "https://3nla0bf9z3.execute-api.us-west-2.amazonaws.com/dev-v2/stops");

      /// parse data
      var data = shuttleStopModelFromJson(_response);
      _data = data;
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<List<ArrivingShuttle>> getArrivingInformation(stopId) async {
    print('getArrivingInformation:------------------ stopId: ' +
        stopId.toString());
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String arrivingEndpoint =
          "https://3nla0bf9z3.execute-api.us-west-2.amazonaws.com/dev-v2/stops/$stopId/arrivals";
      String _response = await _networkHelper.fetchData(arrivingEndpoint);

      /// parse data
      final arrivingData = getArrivingShuttles(_response);
      _isLoading = false;
      return arrivingData;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return [];
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
}
