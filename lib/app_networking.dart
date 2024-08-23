import 'dart:async';
import 'dart:ffi';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkHelper {
  ///TODO: inside each service that file place a switch statement to handle all
  ///TODO: different errors thrown by the Dio client DioErrorType.RESPONSE
  const NetworkHelper();

  static const int SSO_REFRESH_MAX_RETRIES = 3;
  static const int SSO_REFRESH_RETRY_INCREMENT = 5000;
  static const int SSO_REFRESH_RETRY_MULTIPLIER = 3;
  static final int DEFAULT_TIMEOUT = int.parse(dotenv.get('DEFAULT_TIMEOUT'));

  Future<dynamic> fetchData(String url) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.responseType = ResponseType.plain;
    final _response = await dio.get(url);

    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.data;
    } else {
      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch data: ' + _response.data);
    }
  }

  Future<dynamic> authorizedFetch(
      String url, Map<String, String> headers) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.responseType = ResponseType.plain;
    dio.options.headers = headers;
    final _response = await dio.get(
      url,
    );
    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.data;
    } else {
      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.

      throw Exception('Failed to fetch data: ' + _response.data);
    }
  }

  Widget getSilentLoginDialog() {
    return AlertDialog(
      title: const Text(LoginConstants.silentLoginFailedTitle),
      content: Text(LoginConstants.silentLoginFailedDesc),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: ucLabelColor,
          ),
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
  Future<dynamic> authorizedPublicPost(
      String url, Map<String, String> headers, dynamic body) async {
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
    throw new Exception(ErrorConstants.silentLoginFailed);
  }

  Future<dynamic> authorizedPost(
      String url, Map<String, String>? headers, dynamic body) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.headers = headers;
    final _response = await dio.post(url, data: body);
    if (_response.statusCode == 200 || _response.statusCode == 201) {
      // If server returns an OK response, return the body
      return _response.data;
    } else if (_response.statusCode == 400) {
      // If that response was not OK, throw an error.
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 401) {
      throw Exception(ErrorConstants.authorizedPostErrors +
          ErrorConstants.invalidBearerToken);
    } else if (_response.statusCode == 404) {
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 500) {
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 409) {
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.duplicateRecord + message);
    } else {
      throw Exception(ErrorConstants.authorizedPostErrors + 'unknown error');
    }
  }

  Future<dynamic> authorizedPut(
      String url, Map<String, String> headers, dynamic body) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = DEFAULT_TIMEOUT;
    dio.options.receiveTimeout = DEFAULT_TIMEOUT;
    dio.options.headers = headers;
    final _response = await dio.put(url, data: body);

    if (_response.statusCode == 200 || _response.statusCode == 201) {
      // If server returns an OK response, return the body
      return _response.data;
    } else if (_response.statusCode == 400) {
      // If that response was not OK, throw an error.
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPutErrors + message);
    } else if (_response.statusCode == 401) {
      throw Exception(ErrorConstants.authorizedPutErrors +
          ErrorConstants.invalidBearerToken);
    } else if (_response.statusCode == 404) {
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPutErrors + message);
    } else if (_response.statusCode == 500) {
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPutErrors + message);
    } else {
      throw Exception(ErrorConstants.authorizedPutErrors + 'unknown error');
    }
  }

  Future<dynamic> authorizedDelete(
      String url, Map<String, String> headers) async {
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
        ///TODO: log this as a bug because the response was bad
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

  Future<bool> getNewToken(Map<String, String> headers) async {
    final String tokenEndpoint = dotenv.get('NEW_TOKEN_ENDPOINT');
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization": dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY')
    };
    try {
      var response = await authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");
      headers["Authorization"] = "Bearer " + response["access_token"];
      return true;
    } catch (e) {
      return false;
    }
  }
}
