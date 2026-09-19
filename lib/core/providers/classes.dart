import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/classes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClassScheduleDataProvider extends ChangeNotifier {
  /// STATES
  bool _isLoading = false;
  DateTime _lastUpdated = DateTime.now();
  String? _error;
  int _selectedCourse = 0;
  String nextDayWithClass = 'Monday';
  Map<String, List<ScheduledClass>> _enrolledClasses = {
    'MO': [],
    'TU': [],
    'WE': [],
    'TH': [],
    'FR': [],
    'SA': [],
    'SU': [],
    'OTHER': [],
  };
  Map<String, List<ScheduledClass>> _finals = {
    'MO': [],
    'TU': [],
    'WE': [],
    'TH': [],
    'FR': [],
    'SA': [],
    'SU': [],
    'OTHER': [],
  };
  Map<String, List<ScheduledClass>> _midterms = {'MI': [], 'OTHER': []};

  /// MODELS
  late ClassScheduleModel _classScheduleModel;
  late AcademicTermModel _academicTermModel;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  var _classScheduleService = ClassScheduleService();

  void fetchData() async {
    if (!_isLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final bool termFetched = await _classScheduleService.fetchAcademicTerm();
      final bool isLoggedIn = _userDataProvider.isLoggedIn;
      if (termFetched && isLoggedIn) {
        _academicTermModel = _classScheduleService.academicTermModel!;
        final Map<String, String> headers = {
          'Authorization': 'Bearer ${_userDataProvider.authenticationModel.accessToken}',
        };

        /// erase old model
        _classScheduleModel = ClassScheduleModel();

        /// fetch grad courses
        final bool grCoursesFetched = await _classScheduleService.fetchGRCourses(headers, _academicTermModel.termCode!);
        if (grCoursesFetched) {
          _classScheduleModel = _classScheduleService.grData;
        } else {
          _error = _classScheduleService.error.toString();
        }

        /// fetch undergrad courses
        final bool unCoursesFetched = await _classScheduleService.fetchUNCourses(headers, _academicTermModel.termCode!);
        if (unCoursesFetched) {
          if (_classScheduleModel.data != null) {
            _classScheduleModel.data!.addAll(_classScheduleService.unData.data!);
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
        _enrolledClasses = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};
        _finals = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};
        _midterms = {'MI': [], 'OTHER': []};

        try {
          _createMapOfClasses();
        } catch (e) {
          _error = e.toString();
        }

        _lastUpdated = DateTime.now();
      } else {
        // TODO: determine what error to show to the user - December 2025
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
    for (ClassData classData in _classScheduleModel.data!) {
      // print('\x1B[33m${classData.toJson()}\x1B[0m');
      final isBooked = classData.enrollmentStatus == 'Booked';
      if (isBooked) enrolledCourses.add(classData);
    }

    print('\x1B[33m${enrolledCourses.length}\x1B[0m');
    if (enrolledCourses.isEmpty) {
      _error = "No enrolled courses found.";
      _isLoading = false;
      notifyListeners();
    }

    /// Now that we obtained the classes the student is enrolled in, let's display them!
    for (ClassData classData in enrolledCourses) {
      // print('\x1B[34mCurrent Class: ${classData.toJson()}\x1B[0m');
      for (SectionData sectionData in classData.sectionData!) {
        // print('\x1B[35mCurrent Section Data: ${sectionData.toJson()}\x1B[0m');

        /// Get the detailed information of each class
        final scheduledClass = ScheduledClass(course: classData, section: sectionData);

        final days = RegExp(
          r'MO|TU|WE|TH|FR|SA|SU',
        ).allMatches(sectionData.days ?? '').map((match) => match.group(0)!).toList();
        if (days.isEmpty) days.add('OTHER');

        if (sectionData.specialMtgCode == 'MI') {
          _midterms['MI']!.add(scheduledClass);
        } else {
          for (final day in days) {
            if (sectionData.specialMtgCode == 'FI') {
              _finals[day]!.add(scheduledClass);
            } else {
              _enrolledClasses[day]!.add(scheduledClass);
            }
          }
        }
      }
    }

    /// chronologically sort classes for each day
    for (List<ScheduledClass> listOfClasses in _enrolledClasses.values.toList()) {
      listOfClasses.sort((a, b) => _compare(a, b));
    }
    for (List<ScheduledClass> listOfFinals in _finals.values.toList()) {
      listOfFinals.sort((a, b) => _compare(a, b));
    }
    for (List<ScheduledClass> listOfMidterms in _midterms.values.toList()) {
      listOfMidterms.sort((a, b) => _compare(a, b));
      listOfMidterms.sort((a, b) => _compareMidterms(a, b));
    }
  }

  static int _compareMidterms(ScheduledClass a, ScheduledClass b) {
    var dateTimeA = DateFormat('yyyy-M-dd').parse(a.section.date!);
    var dateTimeB = DateFormat('yyyy-M-dd').parse(b.section.date!);
    if (dateTimeA.compareTo(dateTimeB) == 0) return 0;
    if (dateTimeA.compareTo(dateTimeB) < 0) return -1;
    return 1;
  }

  /// comparator that sorts according to start time of class
  static int _compare(ScheduledClass a, ScheduledClass b) {
    final bool aTimeIsNull = a.section.time == null;
    final bool bTimeIsNull = b.section.time == null;
    if (aTimeIsNull || bTimeIsNull) return 0;
    DateTime aStartTime = _getStartTime(a.section.time!);
    DateTime bStartTime = _getStartTime(b.section.time!);

    if (aStartTime == bStartTime) return 0;
    if (aStartTime.isBefore(bStartTime)) return -1;
    return 1;
  }

  static String buildGradeEvaluation(String gradeEvaluation) {
    switch (gradeEvaluation) {
      case 'L':
        return 'Letter Grade';
      case 'P':
        return 'Pass/No Pass';
      case 'S':
        return 'Sat/Unsat';
      default:
        return 'Other';
    }
  }

  static DateTime _getStartTime(String time) {
    var times = time.split("-");
    final format = DateFormat.Hm();
    return format.parse(times[0]);
  }

  void selectCourse(int index) {
    _selectedCourse = index;
    notifyListeners();
  }

  List<ScheduledClass> get upcomingCourses {
    try {
      /// get weekday and return scheduled classes associated with current weekday
      List<ScheduledClass> listToReturn = [];
      String today = DateFormat('EEEE').format(DateTime.now()).toString().toUpperCase().substring(0, 2);
      nextDayWithClass = DateFormat('EEEE').format(DateTime.now()).toString();

      /// if no classes are scheduled for today then find the next day with classes
      var daysToAdd = 1;
      while (_enrolledClasses[today]!.isEmpty && daysToAdd <= 7) {
        today = DateFormat(
          'EEEE',
        ).format(DateTime.now().add(Duration(days: daysToAdd))).toString().toUpperCase().substring(0, 2);
        nextDayWithClass = DateFormat('EEEE').format(DateTime.now().add(Duration(days: daysToAdd)));
        daysToAdd += 1;
      }

      if (_enrolledClasses[today]!.isNotEmpty) {
        listToReturn.addAll(_enrolledClasses[today]!);
      } else {
        listToReturn.addAll([]);
      }
      return listToReturn;
    } catch (err) {
      print('classes provider err');
      print(err);
      return [];
    }
  }

  /// SIMPLE SETTERS
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  get selectedCourse => _selectedCourse;
  Map<String, List<ScheduledClass>> get finals => _finals;
  Map<String, List<ScheduledClass>> get midterms => _midterms;
  Map<String, List<ScheduledClass>> get enrolledClasses => _enrolledClasses;
  ClassScheduleModel get classScheduleModel => _classScheduleModel;
}
