import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NoticesService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  List<NoticesModel> _noticesModel = [];

  Future<bool> fetchData() async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(dotenv.get('NOTICES_ENDPOINT'));

      /// parse data
      _noticesModel = noticesModelFromJson(_response);

      // todo: remove dummy data and call notices endpoint when available
      //_noticesModel = noticesModelFromJson('[{"notice-title": "Coronavirus Information","notice-banner-image": "https://mobile.ucsd.edu/feeds/_resources/media/promo-banners/covid-19-app-20-03-04.png","notice-banner-link": "https://go.ucsd.edu/38nb0Pf"}]');
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
  NetworkHelper get availabilityService => _networkHelper;
  List<NoticesModel> get noticesModel => _noticesModel;
}
