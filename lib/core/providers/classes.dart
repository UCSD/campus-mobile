import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/classes.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ClassScheduleDataProvider extends ChangeNotifier {
  /// STATES
  bool _isLoading = false;
  String? _refreshingCardId;
  bool _linkedRefreshActive = false;
  bool _modelInitialized = false;
  bool _fetchStarted = false;
  bool? _wasLoggedIn;
  int _sessionGeneration = 0;
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

  /// Resets the day maps and rebuilds them from the given model.
  void _applyModel(ClassScheduleModel model) {
    _classScheduleModel = model;

    /// remove all old classes
    _enrolledClasses = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};
    _finals = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};
    _midterms = {'MI': [], 'OTHER': []};

    try {
      _createMapOfClasses();
      _modelInitialized = true;
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadFromCache() async {
    if (_modelInitialized) return;
    final int generation = _sessionGeneration;

    try {
      final box = await Hive.openBox('ClassScheduleModel');
      final cachedJson = box.get('ClassScheduleModel') as String?;
      if (cachedJson == null || cachedJson.isEmpty) return;

      final cachedModel = classScheduleModelFromJson(cachedJson);
      if (_modelInitialized || generation != _sessionGeneration) return;

      /// A fast failed fetch may have set an error before this cache load
      /// completed; good cached data wins.
      _error = null;

      _applyModel(cachedModel);
      notifyListeners();
    } catch (_) {
      /// A cache miss or unreadable cache is not an error;
      /// the network fetch remains the source of truth.
    }
  }

  /// Called from the app_provider proxy update whenever UserDataProvider notifies.
  void handleLoginStateChange() {
    final bool isLoggedIn = _userDataProvider.isLoggedIn;
    final bool wasLoggedIn = _wasLoggedIn ?? false;
    _wasLoggedIn = isLoggedIn;

    if (wasLoggedIn && !isLoggedIn) {
      reset();
      return;
    }

    if (!wasLoggedIn && isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final studentId = _userDataProvider.studentIdDataProvider;
        if (studentId != null) {
          await Future.any([studentId.whenSettled(), Future<void>.delayed(const Duration(milliseconds: 1000))]);
        }
        startFetchIfNeeded();
      });
    }
  }

  /// Single-flight per login session; the reload menu bypasses this gate.
  void startFetchIfNeeded() {
    if (_fetchStarted || _isLoading) return;
    if (!_userDataProvider.isLoggedIn) return;

    _fetchStarted = true;
    fetchData();
  }

  Future<void> fetchData() async {
    if (_isLoading) return;

    _selectedCourse = 0;
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!_userDataProvider.isLoggedIn) {
      // TODO: determine what error to show to the user - December 2025
      _isLoading = false;
      notifyListeners();
      return;
    }

    final int generation = _sessionGeneration;

    /// fetch actual data
    final bool termFetched = await _classScheduleService.fetchAcademicTerm();
    if (generation != _sessionGeneration) return;
    if (!termFetched) {
      if (!_modelInitialized) _error = _classScheduleService.error;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _academicTermModel = _classScheduleService.academicTermModel!;
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${_userDataProvider.authenticationModel.accessToken}',
    };

    /// erase old model
    ClassScheduleModel fetchedModel = ClassScheduleModel();
    bool fetchedAnyCourses = false;

    /// fetch grad courses
    final bool grCoursesFetched = await _classScheduleService.fetchGRCourses(headers, _academicTermModel.termCode!);
    if (generation != _sessionGeneration) return;
    if (grCoursesFetched) {
      fetchedModel = _classScheduleService.grData;
      fetchedAnyCourses = true;
    }

    /// fetch undergrad courses
    final bool unCoursesFetched = await _classScheduleService.fetchUNCourses(headers, _academicTermModel.termCode!);
    if (generation != _sessionGeneration) return;
    if (unCoursesFetched) {
      if (fetchedModel.data != null) {
        if (_classScheduleService.unData.data != null) {
          fetchedModel.data!.addAll(_classScheduleService.unData.data!);
        }
      } else {
        fetchedModel = _classScheduleService.unData;
      }
      fetchedAnyCourses = true;
    }

    /// If we have nothing fresh to show, keep whatever is already displayed.
    if (!fetchedAnyCourses) {
      if (!_modelInitialized) _error = _classScheduleService.error;
      _isLoading = false;
      notifyListeners();
      return;
    }

    /// Never replace a complete displayed schedule with partial data;
    /// partial results are only applied when nothing is displayed.
    if (_modelInitialized && (!grCoursesFetched || !unCoursesFetched)) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final String newJson = classScheduleModelToJson(fetchedModel);

    /// Skip the redundant apply and cache write if the fresh data
    /// matches what is already displayed.
    if (_modelInitialized && newJson == classScheduleModelToJson(_classScheduleModel)) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_refreshingCardId != null) {
      _linkedRefreshActive = true;
    }

    _applyModel(fetchedModel);
    _lastUpdated = DateTime.now();
    _isLoading = false;
    notifyListeners();

    /// A failed cache write must not discard the fresh UI update. Re-check
    /// the generation so a logout during the box open cannot re-persist the
    /// previous user's schedule into the just-cleared box.
    try {
      final box = await Hive.openBox('ClassScheduleModel');
      if (generation != _sessionGeneration) return;
      await box.put('ClassScheduleModel', newJson);
    } catch (_) {}
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

    // print('\x1B[33m${enrolledCourses.length}\x1B[0m');
    if (enrolledCourses.isEmpty) {
      _error = "No enrolled courses found.";
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

  Future<void> reset() async {
    _sessionGeneration++;
    _modelInitialized = false;
    _fetchStarted = false;
    _isLoading = false;
    _refreshingCardId = null;
    _linkedRefreshActive = false;
    _error = null;
    _selectedCourse = 0;
    _lastUpdated = DateTime.now();
    _enrolledClasses = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};
    _finals = {'MO': [], 'TU': [], 'WE': [], 'TH': [], 'FR': [], 'SA': [], 'SU': [], 'OTHER': []};
    _midterms = {'MI': [], 'OTHER': []};
    notifyListeners();

    try {
      final box = await Hive.openBox('ClassScheduleModel');
      await box.clear();
    } catch (_) {}
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

  Future<void> reload(String cardId) async {
    if (_isLoading || _refreshingCardId != null) return;

    _refreshingCardId = cardId;
    try {
      await fetchData();
    } finally {
      _refreshingCardId = null;
      _linkedRefreshActive = false;
      notifyListeners();
    }
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
  bool isRefreshing(String cardId) => _refreshingCardId == cardId || _linkedRefreshActive;
  bool get hasData => _modelInitialized;
  get error => _error;
  get lastUpdated => _lastUpdated;
  get selectedCourse => _selectedCourse;
  Map<String, List<ScheduledClass>> get finals => _finals;
  Map<String, List<ScheduledClass>> get midterms => _midterms;
  Map<String, List<ScheduledClass>> get enrolledClasses => _enrolledClasses;
  ClassScheduleModel get classScheduleModel => _classScheduleModel;
}
