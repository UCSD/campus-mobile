import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
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
  Map<String, List<SectionData>> _enrolledClasses = {
    'MO': [],
    'TU': [],
    'WE': [],
    'TH': [],
    'FR': [],
    'SA': [],
    'SU': [],
    'OTHER': [],
  };
  Map<String, List<SectionData>> _finals = {
    'MO': [],
    'TU': [],
    'WE': [],
    'TH': [],
    'FR': [],
    'SA': [],
    'SU': [],
    'OTHER': [],
  };
  Map<String, List<SectionData>> _midterms = {'MI': [], 'OTHER': []};

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
      if (classData.enrollmentStatus == 'EN') enrolledCourses.add(classData);
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
        sectionData.gradeOption = buildGradeEvaluation(classData.gradeOption ?? "");

        String day = 'OTHER';
        if (sectionData.days != null) {
          day = sectionData.days!;

          final bool isNotFinals = sectionData.specialMtgCode != 'FI';
          final bool isNotMidterm = sectionData.specialMtgCode != 'MI';
          if (isNotFinals && isNotMidterm) {
            _enrolledClasses[day]!.add(sectionData);
          } else if (sectionData.specialMtgCode == 'FI') {
            _finals[day]!.add(sectionData);
          } else if (sectionData.specialMtgCode == 'MI') {
            _midterms['MI']!.add(sectionData);
          }
        }
      }
    }

    /// chronologically sort classes for each day
    for (List<SectionData> listOfClasses in _enrolledClasses.values.toList()) {
      listOfClasses.sort((a, b) => _compare(a, b));
    }
    for (List<SectionData> listOfFinals in _finals.values.toList()) {
      listOfFinals.sort((a, b) => _compare(a, b));
    }
    for (List<SectionData> listOfMidterms in _midterms.values.toList()) {
      listOfMidterms.sort((a, b) => _compare(a, b));
      listOfMidterms.sort((a, b) => _compareMidterms(a, b));
    }
  }

  static int _compareMidterms(SectionData a, SectionData b) {
    var dateTimeA = DateFormat('yyyy-M-dd').parse(a.date!);
    var dateTimeB = DateFormat('yyyy-M-dd').parse(b.date!);
    if (dateTimeA.compareTo(dateTimeB) == 0) return 0;
    if (dateTimeA.compareTo(dateTimeB) < 0) return -1;
    return 1;
  }

  /// comparator that sorts according to start time of class
  static int _compare(SectionData a, SectionData b) {
    final bool aTimeIsNull = a.time == null;
    final bool bTimeIsNull = b.time == null;
    if (aTimeIsNull || bTimeIsNull) return 0;
    DateTime aStartTime = _getStartTime(a.time!);
    DateTime bStartTime = _getStartTime(b.time!);

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

  List<SectionData> get upcomingCourses {
    try {
      /// get weekday and return [List<SectionData>] associated with current weekday
      List<SectionData> listToReturn = [];
      String today = DateFormat('EEEE').format(DateTime.now()).toString().toUpperCase().substring(0, 2);
      nextDayWithClass = DateFormat('EEEE').format(DateTime.now()).toString();

      /// if no classes are scheduled for today then find the next day with classes
      var daysToAdd = 1;
      while (_enrolledClasses[today]!.isEmpty && daysToAdd <= 7) {
        today = DateFormat('EEEE')
            .format(DateTime.now().add(Duration(days: daysToAdd)))
            .toString()
            .toUpperCase()
            .substring(0, 2);
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
  Map<String, List<SectionData>> get finals => _finals;
  Map<String, List<SectionData>> get midterms => _midterms;
  Map<String, List<SectionData>> get enrolledClasses => _enrolledClasses;
  ClassScheduleModel get classScheduleModel => _classScheduleModel;
}
