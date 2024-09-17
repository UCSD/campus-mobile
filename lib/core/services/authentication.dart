import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthenticationService {
  AuthenticationService();
  String? _error;
  AuthenticationModel? _data;
  DateTime? _lastUpdated;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> silentLogin(String base64EncodedWithEncryptedPassword) async {
    _error = null;
    try {
      final Map<String, String> authServiceHeaders = {
        'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
        'Authorization': base64EncodedWithEncryptedPassword,
      };

      /// fetch data
      /// MODIFIED TO USE EXPONENTIAL RETRY
      var response = await _networkHelper.authorizedPublicPost(
          dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);

      /// check to see if response has an error
      if (response['errorMessage'] != null) {
        throw (response['errorMessage']);
      }

      /// parse data
      final authenticationModel = AuthenticationModel.fromJson(response);
      _data = authenticationModel;
      _lastUpdated = DateTime.now();
      return true;
    } catch (e) {
      ///TODO: handle errors thrown by the network class for different types of error responses
      _error = e.toString();
      return false;
    }
  }

  Future<bool> login(String base64EncodedWithEncryptedPassword) async {
    _error = null;
    try {
      final Map<String, String> authServiceHeaders = {
        'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
        'Authorization': base64EncodedWithEncryptedPassword,
      };

      /// fetch data
      /// MODIFIED TO USE EXPONENTIAL RETRY
      var response = await _networkHelper.authorizedPost(
        dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);

      /// check to see if response has an error
      if (response['errorMessage'] != null) {
        throw (response['errorMessage']);
      }

      /// parse data
      final authenticationModel = AuthenticationModel.fromJson(response);
      _data = authenticationModel;
      _lastUpdated = DateTime.now();
      return true;
    } catch (e) {
      ///TODO: handle errors thrown by the network class for different types of error responses
      _error = e.toString();
      return false;
    }
  }

  DateTime? get lastUpdated => _lastUpdated;
  AuthenticationModel? get data => _data;
  String? get error => _error;
  NetworkHelper get availabilityService => _networkHelper;
}
