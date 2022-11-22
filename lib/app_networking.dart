import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkHelper {
  ///TODO: inside each service that file place a switch statement to handle all
  ///TODO: different errors thrown by the Dio client DioErrorType.RESPONSE
  const NetworkHelper();

  static const int SSO_REFRESH_MAX_RETRIES = 3;
  static const int SSO_REFRESH_RETRY_INCREMENT = 5000;
  static const int SSO_REFRESH_RETRY_MULTIPLIER = 3;

  Future<dynamic> fetchData(String url) async {
    final _response = await http.get(Uri.parse(url));

    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.body;
    } else {
      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch data: ' + _response.body);
    }
  }

  Future<dynamic> authorizedFetch(
      String url, Map<String, String> headers) async {
    final _response = await http.get(Uri.parse(url), headers: headers);
    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.body;
    } else {
      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.

      throw Exception('Failed to fetch data: ' + _response.body);
    }
  }

  Widget getSilentLoginDialog() {
    return AlertDialog(
      title: const Text(LoginConstants.silentLoginFailedTitle),
      content: Text(LoginConstants.silentLoginFailedDesc),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            primary: ucLabelColor,
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
    final _response = await http.post(Uri.parse(url), headers: headers, body: body);
    if (_response.statusCode == 200 || _response.statusCode == 201) {
      return _response.body;
    } else if (_response.statusCode == 400) {
      // If that response was not OK, throw an error.
      String message = _response.body;
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 401) {
      throw Exception(ErrorConstants.authorizedPostErrors +
          ErrorConstants.invalidBearerToken);
    } else if (_response.statusCode == 404) {
      String message = _response.body;
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 500) {
      String message = _response.body;
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 409) {
      String message = _response.body;
      throw Exception(ErrorConstants.duplicateRecord + message);
    } else {
      throw Exception(ErrorConstants.authorizedPostErrors + 'unknown error');
    }
  }

  Future<dynamic> authorizedPut(
      String url, Map<String, String> headers, dynamic body) async {
    final _response = await http.put(Uri.parse(url), headers: headers, body: body);
    if (_response.statusCode == 200 || _response.statusCode == 201) {
      // If server returns an OK response, return the body
      return _response.body;
    } else if (_response.statusCode == 400) {
      // If that response was not OK, throw an error.
      String message = _response.body;
      throw Exception(ErrorConstants.authorizedPutErrors + message);
    } else if (_response.statusCode == 401) {
      throw Exception(ErrorConstants.authorizedPutErrors +
          ErrorConstants.invalidBearerToken);
    } else if (_response.statusCode == 404) {
      String message = _response.body;
      throw Exception(ErrorConstants.authorizedPutErrors + message);
    } else if (_response.statusCode == 500) {
      String message = _response.body;
      throw Exception(ErrorConstants.authorizedPutErrors + message);
    } else {
      throw Exception(ErrorConstants.authorizedPutErrors + 'unknown error');
    }
  }

  Future<dynamic> authorizedDelete(
      String url, Map<String, String> headers) async {
    try {
      final _response = await http.delete(Uri.parse(url), headers: headers);
      if (_response.statusCode == 200) {
        // If server returns an OK response, return the body
        return _response.body;
      } else {
        ///TODO: log this as a bug because the response was bad
        // If that response was not OK, throw an error.
        throw Exception('Failed to delete data: ' + _response.body);
      }
    } on TimeoutException catch (err) {
      print(err);
    } catch (err) {
      print('network error');
      print(err);
      return null;
    }
  }
}
