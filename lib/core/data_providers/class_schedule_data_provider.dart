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

  List<SectionData> createListOFSectionData(ClassScheduleModel model) {
    List<SectionData> sectionDataList = List<SectionData>();
    for (ClassData classData in model.data) {
      for (SectionData sectionData in classData.sectionData) {
        sectionDataList.add(sectionData);

        ///TODO only add non final sections
        ///sort in chronological order
      }
    }
  }

  /// get the next class that the student has coming up
  ClassData getNextClass() {
    return ClassData();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  ClassScheduleModel get classScheduleModel => _classScheduleModel;
}
