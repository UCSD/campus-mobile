import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/core/services/notices.dart';
import 'package:flutter/material.dart';

class NoticesDataProvider extends ChangeNotifier
{
  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  List<NoticesModel> _noticesModel = [];

  ///SERVICES
  final NoticesService _noticesService = NoticesService();

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
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<NoticesModel> get noticesModel => _noticesModel;
}
