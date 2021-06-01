

import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/classes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClassScheduleDataProvider extends ChangeNotifier {
  ClassScheduleDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    _lastUpdated = DateTime.now();
    _selectedCourse = 0;
    nextDayWithClass = 'Monday';
    _enrolledClasses = {
      'MO': [],
      'TU': [],
      'WE': [],
      'TH': [],
      'FR': [],
      'SA': [],
      'SU': [],
      'OTHER': [],
    };
    _finals = {
      'MO': [],
      'TU': [],
      'WE': [],
      'TH': [],
      'FR': [],
      'SA': [],
      'SU': [],
      'OTHER': [],
    };

    _midterms = {
      'MI': [],
      'OTHER': [],
    };

    ///INITIALIZE SERVICES
    _classScheduleService = ClassScheduleService();
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  int? _selectedCourse;

  String? nextDayWithClass;

  ///MODELS
  ClassScheduleModel? _classScheduleModel;
  Map<String, List<SectionData>>? _enrolledClasses;
  Map<String, List<SectionData>>? _finals;
  Map<String, List<SectionData>>? _midterms;
  AcademicTermModel? _academicTermModel;
  late UserDataProvider _userDataProvider;

  ///SERVICES
  late ClassScheduleService _classScheduleService;

  void fetchData() async {
    if (!_isLoading!) {
      _isLoading = true;
      _error = null;
      notifyListeners();
      if (await _classScheduleService.fetchAcademicTerm() &&
          _userDataProvider.isLoggedIn) {
        _academicTermModel = _classScheduleService.academicTermModel;
        final Map<String, String> headers = {
          'Authorization':
              'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
        };

        /// erase old model
        _classScheduleModel = ClassScheduleModel();

        /// fetch grad courses
        if (await _classScheduleService.fetchGRCourses(
            headers, _academicTermModel!.termCode!)) {
          _classScheduleModel = _classScheduleService.grData;
        } else {
          _error = _classScheduleService.error.toString();
        }

        /// fetch undergrad courses
        if (await _classScheduleService.fetchUNCourses(
            headers, _academicTermModel!.termCode!)) {
          if (_classScheduleModel!.data != null) {
            _classScheduleModel!.data!.addAll(_classScheduleService.unData.data!);
          } else {
            _classScheduleModel = _classScheduleService.unData;
          }
          _error = null;
        } else {
          _error = _classScheduleService.error.toString();
          _isLoading = false;
          notifyListeners();

          /// short circuit
          return;
        }

        /// remove all old classes
        _enrolledClasses = {
          'MO': [],
          'TU': [],
          'WE': [],
          'TH': [],
          'FR': [],
          'SA': [],
          'SU': [],
          'OTHER': [],
        };

        _finals = {
          'MO': [],
          'TU': [],
          'WE': [],
          'TH': [],
          'FR': [],
          'SA': [],
          'SU': [],
          'OTHER': [],
        };

        _midterms = {
          'MI': [],
          'OTHER': [],
        };
        try {
          _createMapOfClasses();
        } catch (e) {
          _error = e.toString();
        }

        _lastUpdated = DateTime.now();
      } else {
        ///TODO: determine what error to show to the user
        _error = _classScheduleService.error;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void _createMapOfClasses() {
    List<ClassData> enrolledCourses = [];

    /// add only enrolled classes because api returns wait-listed and dropped
    /// courses as well
    for (ClassData classData in _classScheduleModel!.data!) {
      if (classData.enrollmentStatus == 'EN') {
        enrolledCourses.add(classData);
      }
    }

    if (enrolledCourses.isEmpty) {
      _error = "No enrolled courses found.";
      _isLoading = false;
      notifyListeners();
    }

    for (ClassData classData in enrolledCourses) {
      for (SectionData sectionData in classData.sectionData!) {
        /// copy over info from [ClassData] object and put into [SectionData] object
        sectionData.subjectCode = classData.subjectCode;
        sectionData.courseCode = classData.courseCode;
        sectionData.courseTitle = classData.courseTitle;
        sectionData.gradeOption = buildGradeEvaluation(classData.gradeOption);
        String? day = 'OTHER';
        if (sectionData.days != null) {
          day = sectionData.days;
        } else {
          continue;
        }

        if (sectionData.specialMtgCode != 'FI' &&
            sectionData.specialMtgCode != 'MI') {
          _enrolledClasses![day!]!.add(sectionData);
        } else if (sectionData.specialMtgCode == 'FI') {
          _finals![day!]!.add(sectionData);
        } else if (sectionData.specialMtgCode == 'MI') {
          _midterms!['MI']!.add(sectionData);
        }
      }
    }

    /// chronologically sort classes for each day
    for (List<SectionData> listOfClasses in _enrolledClasses!.values.toList()) {
      listOfClasses.sort((a, b) => _compare(a, b));
    }

    for (List<SectionData> listOfFinals in _finals!.values.toList()) {
      listOfFinals.sort((a, b) => _compare(a, b));
    }

    for (List<SectionData> listOfMidterms in _midterms!.values.toList()) {
      listOfMidterms.sort((a, b) => _compare(a, b));
      listOfMidterms.sort((a, b) => _compareMidterms(a, b));
    }
  }

  int _compareMidterms(SectionData a, SectionData b) {
    DateTime dateTimeA = DateFormat('yyyy-M-dd').parse(a.date!);
    DateTime dateTimeB = DateFormat('yyyy-M-dd').parse(b.date!);

    if (dateTimeA.compareTo(dateTimeB) == 0) {
      return 0;
    }
    if (dateTimeA.compareTo(dateTimeB) < 0) {
      return -1;
    }
    return 1;
  }

  /// comparator that sorts according to start time of class
  int _compare(SectionData a, SectionData b) {
    if (a.time == null || b.time == null) {
      return 0;
    }
    DateTime aStartTime = _getStartTime(a.time!);
    DateTime bStartTime = _getStartTime(b.time!);

    if (aStartTime == bStartTime) {
      return 0;
    }
    if (aStartTime.isBefore(bStartTime)) {
      return -1;
    }
    return 1;
  }

  buildGradeEvaluation(String? gradeEvaluation) {
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

  List<SectionData> get upcomingCourses {
    /// get weekday and return [List<SectionData>] associated with current weekday
    List<SectionData> listToReturn = [];
    String today = DateFormat('EEEE')
        .format(DateTime.now())
        .toString()
        .toUpperCase()
        .substring(0, 2);
    nextDayWithClass = DateFormat('EEEE').format(DateTime.now()).toString();

    /// if no classes are scheduled for today then find the next day with classes
    int daysToAdd = 1;
    while (_enrolledClasses![today]!.isEmpty) {
      today = DateFormat('EEEE')
          .format(DateTime.now().add(Duration(days: daysToAdd)))
          .toString()
          .toUpperCase()
          .substring(0, 2);
      nextDayWithClass = DateFormat('EEEE')
          .format(DateTime.now().add(Duration(days: daysToAdd)));
      daysToAdd += 1;
    }
    listToReturn.addAll(_enrolledClasses![today]!);
    return listToReturn;
  }

  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  ///SIMPLE GETTERS
  Map<String, List<SectionData>>? get finals => _finals;
  Map<String, List<SectionData>>? get midterms => _midterms;

  Map<String, List<SectionData>>? get enrolledClasses => _enrolledClasses;
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  ClassScheduleModel? get classScheduleModel => _classScheduleModel;
  int? get selectedCourse => _selectedCourse;
}
