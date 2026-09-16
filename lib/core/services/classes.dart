import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/services/tss_academic_history.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ClassScheduleService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  ClassScheduleModel _unData = ClassScheduleModel();
  ClassScheduleModel _grData = ClassScheduleModel();
  ClassScheduleModel _tssData = ClassScheduleModel();
  AcademicTermModel? _academicTermModel;
  final TssAcademicHistoryClient _tssClient = TssAcademicHistoryClient();

  // MA-470 tss-classes START - direct TSS Booking service
  bool get isTssDirectQaEnabled => _tssClient.enabled;
  bool get isTssAnonymousQaPreviewEnabled => _tssClient.anonymousQaPreviewEnabled;
  bool get hasTssQaStudentOverride => _tssClient.hasStudentOverride;
  ClassScheduleModel get tssData => _tssData;

  String? qaTssStudentNumber(AuthenticationModel authentication) => _tssClient.qaStudentNumber(authentication);

  Future<bool> fetchTssCourses(String studentNumber, String termCode) async {
    _error = null;
    _isLoading = true;
    try {
      _tssData = await _tssClient.classesForStudent(studentNumber, termCode);
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  // MA-470 tss-classes END - direct TSS Booking service

  Future<bool> fetchUNCourses(Map<String, String> headers, String term) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await NetworkHelper.authorizedFetch(
        dotenv.get('MY_ACADEMIC_HISTORY_API_ENDPOINT') + '?academic_level=UN&term_code=' + term,
        headers,
      );

      /// parse data
      _unData = classScheduleModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> fetchGRCourses(Map<String, String> headers, String term) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await NetworkHelper.authorizedFetch(
        dotenv.get('MY_ACADEMIC_HISTORY_API_ENDPOINT') + '?academic_level=GR&term_code=' + term,
        headers,
      );

      /// parse data
      _grData = classScheduleModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> fetchAcademicTerm() async {
    _error = null;
    _isLoading = true;
    try {
      // MA-470 tss-classes START - local term override
      // Local override skips AcademicTerm lookup
      // Normal mode still loads current term
      final overrideTerm = _tssClient.overrideTerm;
      if (overrideTerm != null) {
        _academicTermModel = overrideTerm;
        if (kDebugMode) debugPrint('[MA470 Classes QA] using local term override: ${overrideTerm.termCode}');
        return true;
      }
      // MA-470 tss-classes END - local term override
      String _response = await NetworkHelper.fetchData(dotenv.get('ACADEMIC_TERM_API_ENDPOINT'));
      _academicTermModel = academicTermModelFromJson(_response);
      // MA-470 tss-classes START - select TSS term
      if (_tssClient.enabled) {
        _academicTermModel = _tssClient.selectedTerm(_academicTermModel!);
      }
      // MA-470 tss-classes END - select TSS term
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
  ClassScheduleModel get unData => _unData;
  ClassScheduleModel get grData => _grData;
  AcademicTermModel? get academicTermModel => _academicTermModel;
}
