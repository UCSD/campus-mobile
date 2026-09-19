import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// MA-707 TGPT debug logging START
String _endpointLabel(String endpoint) {
  final Uri? uri = Uri.tryParse(endpoint);
  return uri == null ? 'invalid-endpoint' : '${uri.host}${uri.path}';
}

String tgptSessionLabel(String? sessionId) {
  if (sessionId == null || sessionId.isEmpty) return 'none';
  return sessionId.length <= 8 ? sessionId : sessionId.substring(0, 8);
}

void tgptDebugLog(
  String operation, {
  required String endpoint,
  required String authMode,
  String? sessionId,
  int? statusCode,
  String? detail,
}) {
  if (!kDebugMode) return;
  final List<String> parts = <String>[
    '[TGPT][$operation]',
    'endpoint=${_endpointLabel(endpoint)}',
    'auth=$authMode',
    if (sessionId != null) 'session=${tgptSessionLabel(sessionId)}',
    if (statusCode != null) 'status=$statusCode',
    if (detail != null && detail.isNotEmpty) 'detail=$detail',
  ];
  debugPrint(parts.join(' '));
}

void tgptDebugDio(
  String operation, {
  required String endpoint,
  required String authMode,
  required DioException error,
  String? sessionId,
}) {
  final Object? responseData = error.response?.data;
  String? detail;
  if (responseData is Map) {
    final Object? candidate = responseData['detail'] ?? responseData['message'];
    if (candidate is String && candidate.trim().isNotEmpty) {
      detail = candidate.trim();
    }
  }
  tgptDebugLog(
    operation,
    endpoint: endpoint,
    authMode: authMode,
    sessionId: sessionId,
    statusCode: error.response?.statusCode,
    detail: detail ?? error.type.name,
  );
}

// MA-707 TGPT debug logging END
