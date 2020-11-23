import 'package:campus_mobile_experimental/core/models/survey_model.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/survey_service.dart';
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
    print("in fetch survey");
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _surveyService.fetchData()) {
      print("in await if statement");
      _surveyModels = _surveyService.surveyModel;

      for (String id in _userDataProvider.userProfileModel.surveyCompletion) {
        for (SurveyModel survey in _surveyModels) {
          if (survey.surveyId == id) {
            survey.surveyActive = false;
          }
        }
      }

      /*
       _userDataProvider.userProfileModel.surveyCompletion.forEach((id, value) {
        _surveyModels.forEach((survey) {
          print(survey);
          print("data survey active: " + survey.surveyActive.toString());
          print("data survey id: " + survey.surveyId);
          print("data survey url: " + survey.surveyUrl);

          if (survey.surveyId == id) {
            print(survey.surveyId + " survey is not active anymore");
            survey.surveyActive = false;
          }
        });
      });

       */
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
    print("in submit survey");
    print("adding this survey: " + surveyID);
//    _userDataProvider.userProfileModel.surveyCompletion.clear();
    if (!_userDataProvider.userProfileModel.surveyCompletion
        .contains(surveyID)) {
      _userDataProvider.userProfileModel.surveyCompletion.add(surveyID);
    }
//    _userDataProvider.userProfileModel.surveyCompletion
//        .addAll({surveyID: true});
    _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
    notifyListeners();
    print("survey completion: ");
    print(_userDataProvider.userProfileModel.surveyCompletion.toString());
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  List<SurveyModel> get surveyModels => _surveyModels;
}
