import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:dio/dio.dart';

/// Maps TGPT HTTP/stream failures to short, user-safe copy (no stack traces or Dio internals).
String tgptUserMessageForError(Object error) {
  if (error is DioException) {
    // Uniform copy for outages, 5xx, timeouts, and transport errors — never use [error].toString() in UI.
    return ErrorConstants.TRITONGPT_UNAVAILABLE;
  }
  return ErrorConstants.TRITONGPT_UNAVAILABLE;
}
