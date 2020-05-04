import 'package:campus_mobile_experimental/core/models/links_model.dart';
import 'package:campus_mobile_experimental/core/models/notices_model.dart';
import 'package:campus_mobile_experimental/core/services/links_service.dart';
import 'package:campus_mobile_experimental/core/services/notices_service.dart';
import 'package:flutter/material.dart';

class NoticesDataProvider extends ChangeNotifier {
  NoticesDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _noticesService = NoticesService();
    _noticesModel = List<NoticesModel>();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  List<NoticesModel> _noticesModel;

  ///SERVICES
  NoticesService _noticesService;

  void fetchNotices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _noticesService.fetchData()) {
      _noticesModel = _noticesService.noticesModel;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _noticesService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  List<NoticesModel> get noticesModel => _noticesModel;
}
