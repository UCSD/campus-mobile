import 'dart:async';
import 'package:campus_mobile/app_networking.dart';
import 'package:campus_mobile/core/models/shuttle_arrival.dart';
import 'package:campus_mobile/core/models/shuttle_stop.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShuttleService {
  ShuttleService();

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  /// MODELS
  List<ShuttleStopModel> _data = [];

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (NetworkHelper.authorizedFetch(
          dotenv.get('SHUTTLE_API_ENDPOINT'), headers));

      /// parse data
      var data = shuttleStopModelFromJson(_response);
      _data = data;
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

  Future<List<ArrivingShuttle>> getArrivingInformation(stopId) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (NetworkHelper.authorizedFetch(
          dotenv.get('SHUTTLE_API_ENDPOINT') + "/$stopId/arrivals", headers));

      /// parse data
      final arrivingData = getArrivingShuttles(_response);
      return arrivingData;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
      if (e.toString().contains("401")) {
        if (await NetworkHelper.getNewToken(headers))
          return await getArrivingInformation(stopId);
      }
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<ShuttleStopModel> get data => _data;
}
