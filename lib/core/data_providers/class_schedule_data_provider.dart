import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';
import 'package:campus_mobile_experimental/core/services/class_schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClassScheduleDataProvider extends ChangeNotifier {
  ClassScheduleDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    _selectedCourse = 0;
    nextDayWithClass = 'Monday';
    _enrolledClasses = {
      'MO': List<SectionData>(),
      'TU': List<SectionData>(),
      'WE': List<SectionData>(),
      'TH': List<SectionData>(),
      'FR': List<SectionData>(),
      'SA': List<SectionData>(),
      'SU': List<SectionData>(),
      'OTHER': List<SectionData>(),
    };

    ///INITIALIZE SERVICES
    _classScheduleService = ClassScheduleService();
    _classScheduleModel = ClassScheduleModel();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int _selectedCourse;

  String nextDayWithClass;

  ///MODELS
  ClassScheduleModel _classScheduleModel;
  Map<String, List<SectionData>> _enrolledClasses;

  ///SERVICES
  ClassScheduleService _classScheduleService;

  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _classScheduleService.fetchData()) {
      _classScheduleModel = _classScheduleService.classScheduleModel;

      /// remove all old classes
      _enrolledClasses = {
        'MO': List<SectionData>(),
        'TU': List<SectionData>(),
        'WE': List<SectionData>(),
        'TH': List<SectionData>(),
        'FR': List<SectionData>(),
        'SA': List<SectionData>(),
        'SU': List<SectionData>(),
        'OTHER': List<SectionData>(),
      };
      _createMapOfClasses();
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _classScheduleService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void _createMapOfClasses() {
    List<ClassData> enrolledCourses = List<ClassData>();

    /// add only enrolled classes because api returns wait-listed and dropped
    /// courses as well
    for (ClassData classData in _classScheduleModel.data) {
      if (classData.enrollmentStatus == 'EN') {
        enrolledCourses.add(classData);
      }
    }

    for (ClassData classData in enrolledCourses) {
      for (SectionData sectionData in classData.sectionData) {
        /// copy over info from [ClassData] object and put into [SectionData] object
        sectionData.subjectCode = classData.subjectCode;
        sectionData.courseCode = classData.courseCode;
        sectionData.courseTitle = classData.courseTitle;
        sectionData.gradeOption = buildGradeEvaluation(classData.gradeOption);
        String day = 'OTHER';
        if (sectionData.days != null) {
          day = sectionData.days;
        }
        _enrolledClasses[day].add(sectionData);
      }
    }

    /// chronologically sort classes for each day
    for (List<SectionData> listOfClasses in _enrolledClasses.values.toList()) {
      listOfClasses.sort((a, b) => _compare(a, b));
    }
  }

  /// comparator that sorts according to start time of class
  int _compare(SectionData a, SectionData b) {
    DateTime aStartTime = _getStartTime(a.time);
    DateTime bStartTime = _getStartTime(b.time);

    if (aStartTime == bStartTime) {
      return 0;
    }
    if (aStartTime.isBefore(bStartTime)) {
      return -1;
    }
    return 1;
  }

  buildGradeEvaluation(String gradeEvaluation) {
    switch (gradeEvaluation) {
      case 'L':
        {
          return 'Letter Grade';
        }
      case 'P':
        {
          return 'Pass/No Pass';
        }
      case 'S':
        {
          return 'Sat/Unsat';
        }
      default:
        {
          return 'Other';
        }
    }
  }

  DateTime _getStartTime(String time) {
    List<String> times = time.split("-");
    final format = DateFormat.Hm();
    return format.parse(times[0]);
  }

  void selectCourse(int index) {
    _selectedCourse = index;
    notifyListeners();
  }

  /// returns a map of [String, List<SectionData>]
  /// finals are removed from this map
  Map<String, List<SectionData>> get classes {
    Map<String, List<SectionData>> mapToReturn = {
      'MO': List<SectionData>(),
      'TU': List<SectionData>(),
      'WE': List<SectionData>(),
      'TH': List<SectionData>(),
      'FR': List<SectionData>(),
      'SA': List<SectionData>(),
      'SU': List<SectionData>(),
      'OTHER': List<SectionData>(),
    };
    _enrolledClasses.forEach((key, value) {
      for (SectionData sectionData in value) {
        if (sectionData.specialMtgCode == "") {
          mapToReturn[key].add(sectionData);
        }
      }
    });
    return mapToReturn;
  }

  /// returns map of [String, List<SectionData>]
  /// only finals are returned in this map
  Map<String, List<SectionData>> get finals {
    Map<String, List<SectionData>> mapToReturn = {
      'MO': List<SectionData>(),
      'TU': List<SectionData>(),
      'WE': List<SectionData>(),
      'TH': List<SectionData>(),
      'FR': List<SectionData>(),
      'SA': List<SectionData>(),
      'SU': List<SectionData>(),
      'OTHER': List<SectionData>(),
    };
    _enrolledClasses.forEach((key, value) {
      for (SectionData sectionData in value) {
        if (sectionData.specialMtgCode == 'FI') {
          mapToReturn[key].add(sectionData);
        }
      }
    });
    return mapToReturn;
  }

  List<SectionData> get upcomingCourses {
    /// get weekday and return [List<SectionData>] associated with current weekday
    List<SectionData> listToReturn = List<SectionData>();
    String today = DateFormat('EEEE')
        .format(DateTime.now())
        .toString()
        .toUpperCase()
        .substring(0, 2);
    nextDayWithClass = DateFormat('EEEE').format(DateTime.now()).toString();

    /// if no classes are scheduled for today then find the next day with classes
    int daysToAdd = 1;
    while (classes[today].isEmpty) {
      today = DateFormat('EEEE')
          .format(DateTime.now().add(Duration(days: daysToAdd)))
          .toString()
          .toUpperCase()
          .substring(0, 2);
      nextDayWithClass = DateFormat('EEEE')
          .format(DateTime.now().add(Duration(days: daysToAdd)));
      daysToAdd += 1;
    }
    listToReturn.addAll(classes[today]);
    return listToReturn;
  }

  ///SIMPLE GETTERS
  Map<String, List<SectionData>> get enrolledClasses => _enrolledClasses;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  ClassScheduleModel get classScheduleModel => _classScheduleModel;
  int get selectedCourse => _selectedCourse;
}
