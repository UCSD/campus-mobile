import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:dio/dio.dart';

/// Maps TGPT HTTP/stream failures to short, user-safe copy (no stack traces or Dio internals).
String tgptErrorMessageFor(Object error) {
  if (error is DioException) {
    final int? code = error.response?.statusCode;
    if (code == 404) {
      return ErrorConstants.TRITONGPT_NOT_FOUND;
    }
    if (code != null && code >= 500 && code < 600) {
      return ErrorConstants.TRITONGPT_SERVER_ERROR;
    }
    if (code == 422 || code == 400) {
      return ErrorConstants.TRITONGPT_BAD_REQUEST;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ErrorConstants.TRITONGPT_UNAVAILABLE;
      default:
        break;
    }
    if (code != null && code >= 400 && code < 500) {
      return ErrorConstants.TRITONGPT_BAD_REQUEST;
    }
    return ErrorConstants.TRITONGPT_UNAVAILABLE;
  }

  final String s = error.toString();
  if (s.contains('[404]') || s.contains('status code of 404')) {
    return ErrorConstants.TRITONGPT_NOT_FOUND;
  }
  if (s.contains('[500]') ||
      s.contains('[502]') ||
      s.contains('[503]') ||
      s.contains('status code of 500') ||
      s.contains('status code of 502') ||
      s.contains('status code of 503')) {
    return ErrorConstants.TRITONGPT_SERVER_ERROR;
  }
  if (s.contains('[422]') || s.contains('status code of 422')) {
    return ErrorConstants.TRITONGPT_BAD_REQUEST;
  }
  return ErrorConstants.TRITONGPT_UNAVAILABLE;
}
