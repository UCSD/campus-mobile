import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await (_networkHelper.authorizedFetch(
          dotenv.get('AVAILABILITY_API_ENDPOINT'), {
        "Authorization": dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY')
      }));

      /// parse data
      final data = availabilityStatusFromJson(_response);
      _data = data.data;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
}
