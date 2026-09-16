import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/classes.dart';
import 'package:flutter/foundation.dart';
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
  // MA-470 tss-classes START - initialize Classes model
  ClassScheduleModel _classScheduleModel = ClassScheduleModel();
  // MA-470 tss-classes END - initialize Classes model
  late AcademicTermModel _academicTermModel;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  var _classScheduleService = ClassScheduleService();

  // MA-470 tss-classes START - expose QA mode
  bool get isAnonymousQaPreview => _classScheduleService.isTssAnonymousQaPreviewEnabled;
  bool get hasTssQaStudentOverride => _classScheduleService.hasTssQaStudentOverride;
  bool get isTssDirectQaEnabled => _classScheduleService.isTssDirectQaEnabled;
  // MA-470 tss-classes END - expose QA mode

  // MA-470 tss-classes START - keep booked courses without meetings
  // Booked module without meeting stays enrolled
  // Never create a weekday or time just to show it
  List<ClassData> get bookedCourses =>
      List<ClassData>.unmodifiable((_classScheduleModel.data ?? []).where((course) => course.enrollmentStatus == 'EN'));
  List<ClassData> get unscheduledCourses => List<ClassData>.unmodifiable(
    bookedCourses.where((course) => course.sectionData == null || course.sectionData!.isEmpty),
  );
  // MA-470 tss-classes END - keep booked courses without meetings

  void fetchData() async {
    if (!_isLoading) {
      if (kDebugMode) debugPrint('[MA470 Classes QA] fetch start; anonymous=$isAnonymousQaPreview');
      _isLoading = true;
      _error = null;
      notifyListeners();
      final bool termFetched = await _classScheduleService.fetchAcademicTerm();
      if (kDebugMode) debugPrint('[MA470 Classes QA] term selected=$termFetched');
      final bool isLoggedIn = _userDataProvider.isLoggedIn;
      // MA-470 tss-classes START - choose QA TSS or signed-in flow
      // Signed-in flow stays unchanged
      // Student override bypasses login only for local QA
      if (termFetched && (isLoggedIn || isAnonymousQaPreview)) {
        _academicTermModel = _classScheduleService.academicTermModel!;

        /// erase old model
        _classScheduleModel = ClassScheduleModel();
        // MA-470 tss-classes START - select direct TSS Booking in QA mode
        if (_classScheduleService.isTssDirectQaEnabled) {
          final studentNumber = _classScheduleService.qaTssStudentNumber(_userDataProvider.authenticationModel);
          if (studentNumber == null) {
            _error = 'A TSN is required for the direct TSS QA Classes proof.';
            _isLoading = false;
            notifyListeners();
            return;
          }
          final fetched = await _classScheduleService.fetchTssCourses(studentNumber, _academicTermModel.termCode!);
          if (kDebugMode) debugPrint('[MA470 Classes QA] TSS fetch complete; success=$fetched');
          if (!fetched) {
            _error = _classScheduleService.error.toString();
            _isLoading = false;
            notifyListeners();
            return;
          }
          _classScheduleModel = _classScheduleService.tssData;
        } else {
          final Map<String, String> headers = {
            'Authorization': 'Bearer ${_userDataProvider.authenticationModel.accessToken}',
          };

          /// fetch grad courses
          final bool grCoursesFetched = await _classScheduleService.fetchGRCourses(
            headers,
            _academicTermModel.termCode!,
          );
          if (grCoursesFetched) {
            _classScheduleModel = _classScheduleService.grData;
          } else {
            _error = _classScheduleService.error.toString();
          }

          /// fetch undergrad courses
          final bool unCoursesFetched = await _classScheduleService.fetchUNCourses(
            headers,
            _academicTermModel.termCode!,
          );
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
        }
        // MA-470 tss-classes END - select direct TSS Booking in QA mode

        /// remove all old classes
        _enrolledClasses = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};

        _finals = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};

        _midterms = {'MI': [], 'OTHER': []};

        try {
          _createMapOfClasses();
          if (kDebugMode)
            debugPrint(
              '[MA470 Classes QA] mapped booked courses=${_classScheduleModel.data?.length ?? 0}; upcoming meetings=${upcomingCourses.length}',
            );
        } catch (e) {
          if (kDebugMode) debugPrint('[MA470 Classes QA] map failed: ${e.runtimeType}');
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
  // MA-470 tss-classes END - choose QA TSS or signed-in flow

  void _createMapOfClasses() {
    List<ClassData> enrolledCourses = [];

    /// add only enrolled classes because api returns wait-listed and dropped
    /// courses as well
    // MA-470 tss-classes START - map TSS Booking model
    for (ClassData classData in _classScheduleModel.data ?? []) {
      if (classData.enrollmentStatus == 'EN') enrolledCourses.add(classData);
    }
    // MA-470 tss-classes END - map TSS Booking model

    if (enrolledCourses.isEmpty) {
      _error = "No enrolled courses found.";
      _isLoading = false;
      notifyListeners();
    }
    for (ClassData classData in enrolledCourses) {
      for (SectionData sectionData in classData.sectionData ?? []) {
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
  Map<String, List<SectionData>> get finals => _finals;
  Map<String, List<SectionData>> get midterms => _midterms;
  Map<String, List<SectionData>> get enrolledClasses => _enrolledClasses;
  ClassScheduleModel get classScheduleModel => _classScheduleModel;
}
