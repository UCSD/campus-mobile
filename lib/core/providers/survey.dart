import 'package:campus_mobile_experimental/core/models/survey.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/survey.dart';
import 'package:flutter/material.dart';

class SurveyDataProvider extends ChangeNotifier {
  SurveyDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _surveyService = SurveyService();
    _surveyModels = [SurveyModel()];
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  List<SurveyModel> _surveyModels;
  UserDataProvider _userDataProvider;

  ///SERVICES
  SurveyService _surveyService;

  set userDataProvider(UserDataProvider userDataProvider) {
    _userDataProvider = userDataProvider;
  }

  ///DOWNLOADS SURVEYS AND UPDATES SURVEY MODEL
  void fetchSurvey() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _surveyService.fetchData()) {
      _surveyModels = _surveyService.surveyModel;

      for (String id in _userDataProvider.userProfileModel.surveyCompletion) {
        for (SurveyModel survey in _surveyModels) {
          if (survey.surveyId == id) {
            survey.surveyActive = false;
          }
        }
      }
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _surveyService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///This method is to upload the completion status of a survey
  void submitSurvey(String surveyID) {
    if (!_userDataProvider.userProfileModel.surveyCompletion
        .contains(surveyID)) {
      _userDataProvider.userProfileModel.surveyCompletion.add(surveyID);
    }
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  List<SurveyModel> get surveyModels => _surveyModels;
}
