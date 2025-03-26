import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthenticationService {
  AuthenticationService();

  /// STATES
  String? _error;
  AuthenticationModel? _data;
  DateTime? _lastUpdated;

  /// Logs in silently with provided credentials
  Future<bool> silentLogin(String base64EncodedWithEncryptedPassword) async {
    _error = null;
    print("AuthenticationService.silentLogin: Starting silent login with encoded credentials: $base64EncodedWithEncryptedPassword");
    try {
      final Map<String, String> authServiceHeaders = {
        'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
        'Authorization': base64EncodedWithEncryptedPassword,
      };
      print("AuthenticationService.silentLogin: Using headers: $authServiceHeaders");

      var response = await NetworkHelper.authorizedPublicPost(
          dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);
      print("AuthenticationService.silentLogin: Received response: $response");

      if (response['errorMessage'] != null) throw (response['errorMessage']);

      final authenticationModel = AuthenticationModel.fromJson(response);
      _data = authenticationModel;
      _lastUpdated = DateTime.now();
      return true;
    } catch (e) {
      print("AuthenticationService.silentLogin: Error occurred: $e");
      _error = e.toString();
      return false;
    }
  }

  /// Logs in manually with provided credentials
  Future<bool> login(String base64EncodedWithEncryptedPassword) async {
    _error = null;
    print("AuthenticationService.login: Starting manual login with encoded credentials: $base64EncodedWithEncryptedPassword");
    try {
      final Map<String, String> authServiceHeaders = {
        'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
        'Authorization': base64EncodedWithEncryptedPassword,
      };
      print("AuthenticationService.login: Using headers: $authServiceHeaders");

      var response = await NetworkHelper.authorizedPost(
          dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);
      print("AuthenticationService.login: Received response: $response");

      if (response['errorMessage'] != null) throw (response['errorMessage']);

      final authenticationModel = AuthenticationModel.fromJson(response);
      _data = authenticationModel;
      _lastUpdated = DateTime.now();
      return true;
    } catch (e) {
      print("AuthenticationService.login: Error occurred: $e");
      _error = e.toString();
      return false;
    }
  }

  /// SIMPLE GETTERS
  get lastUpdated => _lastUpdated;
  get error => _error;
  AuthenticationModel? get data => _data;
}


// import 'package:campus_mobile_experimental/app_networking.dart';
// import 'package:campus_mobile_experimental/core/models/authentication.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// class AuthenticationService {
//   AuthenticationService();
//
//   /// STATES
//   String? _error;
//   AuthenticationModel? _data;
//   DateTime? _lastUpdated;
//   /// add state related things for view model here
//   /// add any type of data manipulation here so it can be accessed via provider
//
//   Future<bool> silentLogin(String base64EncodedWithEncryptedPassword) async {
//     _error = null;
//     try {
//       final Map<String, String> authServiceHeaders = {
//         'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
//         'Authorization': base64EncodedWithEncryptedPassword,
//       };
//
//       /// fetch data
//       /// MODIFIED TO USE EXPONENTIAL RETRY
//       var response = await NetworkHelper.authorizedPublicPost(
//           dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);
//
//       /// check to see if response has an error
//       if (response['errorMessage'] != null) throw (response['errorMessage']);
//
//       /// parse data
//       final authenticationModel = AuthenticationModel.fromJson(response);
//       _data = authenticationModel;
//       _lastUpdated = DateTime.now();
//       return true;
//     } catch (e) {
//       /// TODO: handle errors thrown by the network class for different types of error responses
//       _error = e.toString();
//       return false;
//     }
//   }
//
//   Future<bool> login(String base64EncodedWithEncryptedPassword) async {
//     _error = null;
//     try {
//       final Map<String, String> authServiceHeaders = {
//         'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
//         'Authorization': base64EncodedWithEncryptedPassword,
//       };
//
//       /// fetch data
//       /// MODIFIED TO USE EXPONENTIAL RETRY
//       var response = await NetworkHelper.authorizedPost(
//         dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);
//
//       /// check to see if response has an error
//       if (response['errorMessage'] != null) throw (response['errorMessage']);
//
//       /// parse data
//       final authenticationModel = AuthenticationModel.fromJson(response);
//       _data = authenticationModel;
//       _lastUpdated = DateTime.now();
//       return true;
//     } catch (e) {
//       /// TODO: handle errors thrown by the network class for different types of error responses
//       _error = e.toString();
//       return false;
//     }
//   }
//
//   /// SIMPLE GETTERS
//   get lastUpdated => _lastUpdated;
//   get error => _error;
//   AuthenticationModel? get data => _data;
// }
