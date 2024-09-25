import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClassScheduleService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  ClassScheduleModel _unData = ClassScheduleModel();
  ClassScheduleModel _grData = ClassScheduleModel();
  AcademicTermModel? _academicTermModel;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchUNCourses(Map<String, String> headers, String term) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          dotenv.get('MY_ACADEMIC_HISTORY_API_ENDPOINT') + '?academic_level=UN&term_code=' + term,
          headers);

      /// parse data
      _unData = classScheduleModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchGRCourses(Map<String, String> headers, String term) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = _networkHelper.authorizedFetch(
          dotenv.get('MY_ACADEMIC_HISTORY_API_ENDPOINT') + '?academic_level=GR&term_code=' + term,
          headers) as String;

      /// parse data
      _grData = classScheduleModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchAcademicTerm() async {
    _error = null;
    _isLoading = true;
    try {
      String _response = await _networkHelper.fetchData(dotenv.get('ACADEMIC_TERM_API_ENDPOINT'));
      _academicTermModel = academicTermModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String? get error => _error;
  ClassScheduleModel get unData => _unData;
  ClassScheduleModel get grData => _grData;
  AcademicTermModel? get academicTermModel => _academicTermModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
