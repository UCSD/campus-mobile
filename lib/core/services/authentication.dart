import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:result_dart/result_dart.dart';

class AuthenticationService {
  AuthenticationService();

  Future<Result<AuthenticationModel>> silentLogin(
      String base64EncodedWithEncryptedPassword
  ) async {
    try {
      final Map<String, String> authServiceHeaders = {
        'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
        'Authorization': base64EncodedWithEncryptedPassword,
      };

      var response = await NetworkHelper.authorizedPublicPost(
          dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);

      if (response['errorMessage'] != null) {
        return Failure(Exception(response['errorMessage'].toString()));
      }

      final authenticationModel = AuthenticationModel.fromJson(response);
      return Success(authenticationModel);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString())); //Change (return the string option) consider only catching exotic errors (like out of memory) memories that don't derive from the exception class
    }
  }

  Future<Result<AuthenticationModel>> login(
      String base64EncodedWithEncryptedPassword
  ) async {
    try {
      final Map<String, String> authServiceHeaders = {
        'x-api-key': dotenv.get('AUTH_SERVICE_API_KEY'),
        'Authorization': base64EncodedWithEncryptedPassword,
      };

      var response = await NetworkHelper.authorizedPost(
          dotenv.get('AUTH_SERVICE_API_ENDPOINT'), authServiceHeaders, null);

      if (response['errorMessage'] != null) {
        return Failure(Exception(response['errorMessage'].toString()));
      }

      final authenticationModel = AuthenticationModel.fromJson(response);
      return Success(authenticationModel);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString())); //Change as above
    }
  }
}