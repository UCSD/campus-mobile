import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Names of the machine environment variables that hold the OneBusAway API
/// base endpoint and API key (MA-685). The values are read from the machine
/// environment at runtime and must never be hardcoded, committed, or logged.
const String oneBusAwayApiEnvVar = 'ONE_BUS_AWAY_API';
const String oneBusAwayApiKeyEnvVar = 'ONE_BUS_AWAY_API_KEY';

/// Compile-time fallbacks, populated via
/// `flutter run --dart-define=ONE_BUS_AWAY_API=...` for device builds where
/// machine environment variables are not propagated into the app process.
/// Like the environment variables, these values are never stored in code.
const String _oneBusAwayApiDartDefine = String.fromEnvironment(oneBusAwayApiEnvVar);
const String _oneBusAwayApiKeyDartDefine = String.fromEnvironment(oneBusAwayApiKeyEnvVar);

/// Sanitized error type for all OneBusAway failures. Messages never include
/// request URLs, which embed the API key as a query parameter.
class OneBusAwayException implements Exception {
  const OneBusAwayException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Holds the OneBusAway API configuration read from the machine environment.
///
/// Explicit [apiEndpoint]/[apiKey] values (used by dependency injection and
/// tests) always take precedence over the environment.
class OneBusAwayConfig {
  OneBusAwayConfig({String? apiEndpoint, String? apiKey})
    : apiEndpoint = (apiEndpoint ?? Platform.environment[oneBusAwayApiEnvVar] ?? _oneBusAwayApiDartDefine).trim(),
      apiKey = (apiKey ?? Platform.environment[oneBusAwayApiKeyEnvVar] ?? _oneBusAwayApiKeyDartDefine).trim();

  final String apiEndpoint;
  final String apiKey;

  bool get isConfigured => apiEndpoint.isNotEmpty && apiKey.isNotEmpty;

  /// Redacted representation: the endpoint and key must never appear in logs.
  @override
  String toString() => 'OneBusAwayConfig(configured: $isConfigured)';
}

/// Thin REST client for the OneBusAway APIs used by the Transit feature.
///
/// All responses use the standard OneBusAway envelope:
/// `{"code":200,"currentTime":...,"data":{...}}`. This client validates the
/// envelope and returns the decoded map to the caller for model mapping.
class OneBusAwayClient {
  OneBusAwayClient({OneBusAwayConfig? config, Dio? dio, Duration? timeout})
    : _config = config ?? OneBusAwayConfig(),
      _timeout = timeout ?? const Duration(seconds: 15) {
    _dio = dio ?? Dio();
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.responseType = ResponseType.plain;
  }

  /// Agency whose stops power the campus Transit screen.
  static const String defaultAgencyId = 'UCSD';

  static const String _stopsForAgencyPathTemplate = '/api/where/stops-for-agency';
  static const String _arrivalsForStopPathTemplate = '/api/where/arrivals-and-departures-for-stop';

  late final Dio _dio;
  final OneBusAwayConfig _config;
  final Duration _timeout;

  /// Fetches all stops served by [agencyId] (the campus shuttle agency by
  /// default). OneBusAway replaces the legacy shuttle stops feed with
  /// `GET {base}/api/where/stops-for-agency/{agencyId}.json`.
  Future<Map<String, dynamic>> fetchStopsForAgency({String agencyId = defaultAgencyId}) =>
      _get('$_stopsForAgencyPathTemplate/$agencyId.json');

  /// Fetches upcoming arrivals and departures for [stopId] (the raw
  /// OneBusAway stop id, e.g. `UCSD_10772`). OneBusAway replaces the legacy
  /// arrivals feed with
  /// `GET {base}/api/where/arrivals-and-departures-for-stop/{stopId}.json`.
  Future<Map<String, dynamic>> fetchArrivalsAndDeparturesForStop(String stopId) =>
      _get('$_arrivalsForStopPathTemplate/${Uri.encodeComponent(stopId)}.json');

  /// Builds the request [Uri] for [path], attaching the API key as the
  /// standard OneBusAway `key` query parameter.
  Uri _buildUri(String path) {
    final String base = _config.apiEndpoint.endsWith('/')
        ? _config.apiEndpoint.substring(0, _config.apiEndpoint.length - 1)
        : _config.apiEndpoint;
    return Uri.parse('$base$path').replace(queryParameters: <String, String>{'key': _config.apiKey});
  }

  Future<Map<String, dynamic>> _get(String path) async {
    if (!_config.isConfigured) {
      throw const OneBusAwayException(
        'The OneBusAway API is not configured. Set the ONE_BUS_AWAY_API and '
        'ONE_BUS_AWAY_API_KEY environment variables.',
      );
    }
    try {
      final Response<dynamic> response = await _dio.getUri(_buildUri(path));
      final dynamic body = response.data;
      final dynamic decoded = body is String ? jsonDecode(body) : body;
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected OneBusAway response shape.');
      }
      final int? code = (decoded['code'] as num?)?.toInt();
      if (code != 200) {
        throw OneBusAwayException('OneBusAway returned error code $code.');
      }
      return decoded;
    } on OneBusAwayException {
      rethrow;
    } on DioException catch (e) {
      // Never surface the request URI: it contains the API key.
      final int? status = e.response?.statusCode;
      throw OneBusAwayException(
        status == null ? 'Failed to reach the OneBusAway API.' : 'Failed to reach the OneBusAway API (HTTP $status).',
      );
    } catch (_) {
      // Deliberately discard the original error: network/parsing error text
      // can embed the full request URL, which contains the API key.
      throw const OneBusAwayException('Failed to process OneBusAway data.');
    }
  }
}
