import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClassScheduleService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  ClassScheduleModel _unData = ClassScheduleModel();
  ClassScheduleModel _grData = ClassScheduleModel();
  AcademicTermModel? _academicTermModel;

  Future<bool> fetchUNCourses(Map<String, String> headers, String term) async {
    // print('\x1B[31m================ Fetch UN Courses ================\x1B[0m');
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
      // print('\x1B[31m$_response\x1B[0m');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> fetchGRCourses(Map<String, String> headers, String term) async {
    // print('\x1B[32m================ Fetch GR Courses ================\x1B[0m');
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
      // print('\x1B[32m$_response\x1B[0m');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> fetchAcademicTerm() async {
    // print('\x1B[32m================ Fetch Academic Term ================\x1B[0m');
    _error = null;
    _isLoading = true;
    try {
      String _response = await NetworkHelper.fetchData(dotenv.get('ACADEMIC_TERM_API_ENDPOINT'));
      _academicTermModel = academicTermModelFromJson(_response);
      // print('\x1B[32m$_response\x1B[0m');
      return true;
    } catch (e) {
      _error = e.toString();
      // print('\x1B[32m$_error\x1B[0m');
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
