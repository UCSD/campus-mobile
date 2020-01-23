import 'package:campus_mobile_experimental/core/models/authentication_model.dart';
import 'package:campus_mobile_experimental/core/models/user_profile_model.dart';
import 'package:campus_mobile_experimental/core/services/authentication_service.dart';
import 'package:campus_mobile_experimental/core/services/user_profile_service.dart';
import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {
  UserDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _authenticationService = AuthenticationService();
    _userProfileService = UserProfileService();

    ///default authentication model is needed in this class to check login state
    ///in most classes the model data can remain null
    _authenticationModel = AuthenticationModel.fromJson({});
    _userProfileModel = UserProfileModel.fromJson({});
    _cardStates = {
      'dining': true,
      'links': true,
      'availability': true,
      'parking': true,
      'weather': true,
      'events': true,
      'special_events': true,
      'news': true,
      'schedule': true
    };
    _cardOrder = [
      'special_events',
      'weather',
      'availability',
      'parking',
      'dining',
      'news',
      'events',
      'links',
      'schedule',
    ];
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  AuthenticationModel _authenticationModel;
  UserProfileModel _userProfileModel;

  ///SERVICES
  AuthenticationService _authenticationService;
  UserProfileService _userProfileService;
  Map<String, bool> _cardStates;

  List<String> _cardOrder;

  ///authenticate a user given an email and password
  ///upon logging in we should make sure that users upload the correct
  ///ucsdaffiliation and classification
  void login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    bool response = await _authenticationService.login(email, password);
    if (response) {
      _authenticationModel = _authenticationService.data;
      getUserProfile();
      _lastUpdated = DateTime.now();
    } else {
      /// here we know that the authentication failed but we still have access to stale data because it has not been overwritten
      /// however if this failure occurs on the first attempt then our data model will have a default expiration of 0
      /// TODO: make sure this is the correct error message to show the user in the AuthenticationService class
      /// this is the error we will display to the user
      _error = _authenticationService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleCard(String card) {
    _cardStates[card] = !_cardStates[card];
    notifyListeners();
  }

  void reorderCards(List<String> order) {
    _cardOrder = order;
    notifyListeners();
  }

  void logout() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _authenticationModel = AuthenticationModel.fromJson({});
    _userProfileModel = UserProfileModel.fromJson({});
    _isLoading = false;
    notifyListeners();
  }

  ///FETCH USER PROFILE FROM SERVER
  void getUserProfile() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    if (_authenticationModel.isLoggedIn(_authenticationService.lastUpdated)) {
      /// we fetch the user data now
      final Map<String, String> headers = {
        'Authorization': 'Bearer ' + _authenticationModel.accessToken
      };
      if (await _userProfileService.downloadUserProfile(headers)) {
        _userProfileModel = _userProfileService.userProfileModel;
        print('downlaoded user profile: ');
        print(_userProfileService.userProfileModel.toJson().toString());
      }
    } else {
      _error = 'not logged in';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// UPLOAD USER PROFILE TO SERVER
  void postUserProfile(UserProfileModel profile) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    if (_authenticationModel.isLoggedIn(_authenticationService.lastUpdated)) {
      final Map<String, String> headers = {
        'Authorization': "Bearer " + _authenticationModel.accessToken
      };
      if (await _userProfileService.uploadUserProfile(
          headers, profile.toJson())) {
        _error = null;
        _isLoading = false;
      }
    } else {
      _error = 'not logged in';
    }
    _userProfileModel = profile;
    _isLoading = false;
    notifyListeners();
  }

  ///GETTERS FOR MODELS
  UserProfileModel get userProfileModel => _userProfileModel;
  AuthenticationModel get data => _authenticationModel;

  ///GETTERS FOR STATES
  String get error => _error;
  bool get isLoggedIn => _authenticationModel.isLoggedIn(_lastUpdated);
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
  Map<String, bool> get cardStates => _cardStates;
  List<String> get cardOrder => _cardOrder;
}
