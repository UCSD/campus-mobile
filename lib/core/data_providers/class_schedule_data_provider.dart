import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';
import 'package:campus_mobile_experimental/core/services/class_schedule_service.dart';
import 'package:flutter/material.dart';

class ClassScheduleDataProvider extends ChangeNotifier {
  ClassScheduleDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _classScheduleService = ClassScheduleService();
    _classScheduleModel = ClassScheduleModel();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  ClassScheduleModel _classScheduleModel;

  ///SERVICES
  ClassScheduleService _classScheduleService;

  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _classScheduleService.fetchData()) {
      _classScheduleModel = _classScheduleService.classScheduleModel;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _classScheduleService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  ClassScheduleModel get classScheduleModel => _classScheduleModel;
}
