

import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/survey.dart';

class SurveyService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/survey/active_survey.json';

  SurveyModel _surveyModel = SurveyModel();
  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      _surveyModel = surveyModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String? get error => _error;
  SurveyModel get surveyModel => _surveyModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
