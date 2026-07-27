import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkHelper {
  // TODO: different errors thrown by the Dio client DioErrorType.RESPONSE - December 2025

  // private constructor to show that this class should not be instantiated
  const NetworkHelper._();

  static const int SSO_REFRESH_MAX_RETRIES = 3;
  static const int SSO_REFRESH_RETRY_INCREMENT = 5000;
  static const int SSO_REFRESH_RETRY_MULTIPLIER = 3;
  static final DEFAULT_TIMEOUT = Duration(milliseconds: int.parse(dotenv.get('DEFAULT_TIMEOUT')));

  static Future<dynamic> fetchData(String url) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.responseType = ResponseType.plain;
    final _response = await dio.get(url);

    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.data;
    } else {
      // TODO: log this as a bug because the response was bad - December 2025
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch data: ' + _response.data);
    }
  }

  static Future<dynamic> authorizedFetch(String url, Map<String, String> headers) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = headers;
    final _response = await dio.get(url);
    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.data;
    } else {
      // TODO: log this as a bug because the response was bad - December 2025
      // If that response was not OK, throw an error.

      throw Exception('Failed to fetch data: ' + _response.data);
    }
  }

  static Widget getSilentLoginDialog() {
    return AlertDialog(
      title: const Text(LoginConstants.SILENT_LOGIN_FAILED_TITLE),
      content: const Text(LoginConstants.SILENT_LOGIN_FAILED_DESC),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: ucLabelColor),
          onPressed: () {
            Get.back(closeOverlays: true);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  // method for implementing exponential backoff for silentLogin
  // mimicking existing code from React Native versions of campus-mobile
  static Future<dynamic> authorizedPublicPost(String url, Map<String, String> headers, dynamic body) async {
    int retries = 0;
    int waitTime = 0;
    try {
      var response = await authorizedPost(url, headers, body);
      return response;
    } catch (e) {
      // exponential backoff here
      retries++;
      waitTime = SSO_REFRESH_RETRY_INCREMENT;
      while (retries <= SSO_REFRESH_MAX_RETRIES) {
        // wait for the wait time to elapse
        await Future.delayed(Duration(milliseconds: waitTime));

        // calculate new wait time (not exponential for now, mimicking previous code)
        waitTime *= SSO_REFRESH_RETRY_MULTIPLIER;
        // try to log in again
        try {
          var response = await authorizedPost(url, headers, body);

          // no exception thrown, success, return response
          return response;
        } catch (e) {
          // still raising an exception, increment retries and try again
          retries++;
        }
      }
    }
    // if here, silent login has failed
    // throw exception to inform caller
    await Get.dialog(getSilentLoginDialog());
    throw new Exception(ErrorConstants.SILENT_LOGIN_FAILED);
  }

  static Future<dynamic> authorizedPost(String url, Map<String, String>? headers, dynamic body) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.headers = headers;
    final _response = await dio.post(url, data: body);
    switch (_response.statusCode) {
      // If server returns an OK response, return the body
      case 200:
      case 201:
        return _response.data;
      // If that response was not OK, throw an error.
      case 400:
        String message = _response.data['message'] ?? '';
        throw Exception(ErrorConstants.AUTHORIZED_POST_ERRORS + message);

      case 401:
        throw Exception(ErrorConstants.AUTHORIZED_POST_ERRORS + ErrorConstants.INVALID_BEARER_TOKEN);

      case 404:
        String message = _response.data['message'] ?? '';
        throw Exception(ErrorConstants.AUTHORIZED_POST_ERRORS + message);

      case 409:
        String message = _response.data['message'] ?? '';
        throw Exception(ErrorConstants.DUPLICATE_RECORD + message);

      case 500:
        String message = _response.data['message'] ?? '';
        throw Exception(ErrorConstants.AUTHORIZED_POST_ERRORS + message);

      default:
        throw Exception(ErrorConstants.AUTHORIZED_POST_ERRORS + 'unknown error');
    }
  }

  static Future<dynamic> authorizedPut(String url, Map<String, String> headers, dynamic body) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.headers = headers;
    final _response = await dio.put(url, data: body);

    switch (_response.statusCode) {
      // If server returns an OK response, return the body
      case 200:
      case 201:
        return _response.data;
      // If that response was not OK, throw an error.
      case 400:
        String message = _response.data['message'] ?? '';
        throw Exception(ErrorConstants.AUTHORIZED_PUT_ERRORS + message);

      case 401:
        throw Exception(ErrorConstants.AUTHORIZED_PUT_ERRORS + ErrorConstants.INVALID_BEARER_TOKEN);

      case 404:
        String message = _response.data['message'] ?? '';
        throw Exception(ErrorConstants.AUTHORIZED_PUT_ERRORS + message);

      case 500:
        String message = _response.data['message'] ?? '';
        throw Exception(ErrorConstants.AUTHORIZED_PUT_ERRORS + message);

      default:
        throw Exception(ErrorConstants.AUTHORIZED_PUT_ERRORS + 'unknown error');
    }
  }

  static Future<dynamic> authorizedDelete(String url, Map<String, String> headers) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.headers = headers;
    try {
      final _response = await dio.delete(url);
      if (_response.statusCode == 200) {
        // If server returns an OK response, return the body
        return _response.data;
      } else {
        // TODO: log this as a bug because the response was bad - December 2025
        // If that response was not OK, throw an error.
        throw Exception('Failed to delete data: ' + _response.data);
      }
    } on TimeoutException catch (err) {
      print(err);
    } catch (err) {
      print('network error');
      print(err);
      return null;
    }
  }

  static Future<bool> getNewToken(Map<String, String> headers) async {
    final String tokenEndpoint = dotenv.get('NEW_TOKEN_ENDPOINT');
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization": dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY'),
    };
    try {
      var response = await authorizedPost(tokenEndpoint, tokenHeaders, "grant_type=client_credentials");
      headers["Authorization"] = "Bearer " + response["access_token"];
      return true;
    } catch (e) {
      return false;
    }
  }
}
