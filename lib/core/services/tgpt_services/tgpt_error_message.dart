import 'dart:convert';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:dio/dio.dart';

String? _parseTgptApiErrorMessageFromData(Object? data) {
  if (data == null) return null;
  if (data is Map) {
    final Object? m = data['message'];
    if (m is String) {
      final String t = m.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }
  if (data is String) {
    final String trimmed = data.trim();
    if (trimmed.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        final Object? m = decoded['message'];
        if (m is String) {
          final String t = m.trim();
          if (t.isNotEmpty) return t;
        }
      }
    } catch (_) {}
  }
  return null;
}

Future<String?> _readTgptErrorMessageFromResponseBody(ResponseBody body) async {
  try {
    final List<int> bytes = <int>[];
    await for (final List<int> chunk in body.stream) {
      bytes.addAll(chunk);
    }
    final String text = utf8.decode(bytes).trim();
    if (text.isEmpty) return null;
    return _parseTgptApiErrorMessageFromData(text);
  } catch (_) {
    return null;
  }
}

/// Resolves [DioException] for TGPT calls; reads stream bodies for HTTP 400 guardrails.
Future<String> tgptErrorMessageForDio(DioException e) async {
  if (e.response?.statusCode == 400) {
    final Object? data = e.response?.data;
    if (data is ResponseBody) {
      final String? fromBody = await _readTgptErrorMessageFromResponseBody(data);
      if (fromBody != null) return fromBody;
    } else {
      final String? parsed = _parseTgptApiErrorMessageFromData(data);
      if (parsed != null) return parsed;
    }
  }
  return tgptErrorMessageFor(e);
}

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
    if (code == 400) {
      final String? parsed = _parseTgptApiErrorMessageFromData(error.response?.data);
      if (parsed != null) return parsed;
      return ErrorConstants.TRITONGPT_BAD_REQUEST;
    }
    if (code == 422) {
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
  var has404Error = s.contains('[404]') || s.contains('status code of 404');
  if (has404Error) {
    return ErrorConstants.TRITONGPT_NOT_FOUND;
  }
  var has50xError = s.contains('[500]') ||
      s.contains('[502]') ||
      s.contains('[503]') ||
      s.contains('status code of 500') ||
      s.contains('status code of 502') ||
      s.contains('status code of 503');
  if (has50xError) {
    return ErrorConstants.TRITONGPT_SERVER_ERROR;
  }
  var has422Error = s.contains('[422]') || s.contains('status code of 422');
  if (has422Error) {
    return ErrorConstants.TRITONGPT_BAD_REQUEST;
  }
  var has400Error = s.contains('[400]') || s.contains('status code of 400');
  if (has400Error) {
    return ErrorConstants.TRITONGPT_BAD_REQUEST;
  }
  return ErrorConstants.TRITONGPT_UNAVAILABLE;
}
