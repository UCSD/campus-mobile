import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';

class UserProfileService {
  UserProfileService();
  bool? _isLoading;
  String? _error;
  UserProfileModel? _userProfileModel;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String _endpoint = 'https://api-qa.ucsd.edu:8243/mp-registration/2.0.0';

  Future<bool> downloadUserProfile(Map<String, String> headers) async {
    _error = null;
    _isLoading = true;
    try {
      _userProfileModel = userProfileModelFromJson(await _networkHelper
          .authorizedFetch(_endpoint + '/profile', headers));
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> uploadUserProfile(
      Map<String, String> headers, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    try {
      final response = await _networkHelper.authorizedPost(
          _endpoint + '/profile', headers, createAttributeValueJson(body));
      if (response.toString() == 'Success') {
        _isLoading = false;
        return true;
      } else {
        throw (response.toString());
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    return false;
  }

  ///correctly format the profile to be uploaded
  ///required json format:
  ///[{'attribute': 'name of column to edit in db, 'value': 'value to put in db'}]
  ///if attribute does not exists in db then it will be created
  List<Map<String, dynamic>> createAttributeValueJson(
      Map<String, dynamic> json) {
    List<Map<String, dynamic>> correctlyFormattedData = [];
    json.forEach((key, value) {
      correctlyFormattedData.add({"attribute": key, "value": value});
    });
    return correctlyFormattedData;
  }

  String? get error => _error;
  UserProfileModel? get userProfileModel => _userProfileModel;
  bool? get isLoading => _isLoading;
}
