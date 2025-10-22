import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProfileService {
  UserProfileService();

  /// STATES
  bool _isLoading = false;
  String? _error;
  late final _endpoint = dotenv.get('USER_ENDPOINT');

  /// MODELS
  late UserProfileModel _userProfileModel;

  Future<bool> downloadUserProfile(Map<String, String> headers) async {
    _error = null;
    _isLoading = true;
    try {
      _userProfileModel = userProfileModelFromJson(
          await NetworkHelper.authorizedFetch(_endpoint + '/profile', headers));
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> uploadUserProfile(Map<String, String> headers, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    try {
      final response = await NetworkHelper.authorizedPost(
          _endpoint + '/profile', headers, createAttributeValueJson(body));
      return response.toString() == 'Success' ? true : throw response.toString();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
    return false;
  }

  /// correctly format the profile to be uploaded
  /// required json format:
  /// [{'attribute': 'name of column to edit in db, 'value': 'value to put in db'}]
  /// if attribute does not exists in db then it will be created
  List<Map<String, dynamic>> createAttributeValueJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> correctlyFormattedData = [];
    json.forEach((key, value) {
      correctlyFormattedData.add({"attribute": key, "value": value});
    });
    return correctlyFormattedData;
  }

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  UserProfileModel get userProfileModel => _userProfileModel;
}
