import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_mobile_experimental/core/services/shuttle_request_trace.dart';

/// Names of the machine environment variables that hold the OneBusAway API
/// base endpoint and API key (MA-685). Values come from the machine environment,
/// Dart defines, or the app's loaded .env and must never be hardcoded, committed, or logged.
const String oneBusAwayApiEnvVar = 'ONE_BUS_AWAY_API';
const String oneBusAwayApiKeyEnvVar = 'ONE_BUS_AWAY_API_KEY';

/// Compile-time fallbacks, populated via
/// `flutter run --dart-define=ONE_BUS_AWAY_API=...` for device builds where
/// machine environment variables are not propagated into the app process.
/// Like the environment variables, these values are never stored in code.
const String _oneBusAwayApiDartDefine = String.fromEnvironment(oneBusAwayApiEnvVar);
const String _oneBusAwayApiKeyDartDefine = String.fromEnvironment(oneBusAwayApiKeyEnvVar);

String _readOneBusAwaySetting(String name, String dartDefine) {
  final String? environmentValue = Platform.environment[name];
  if (environmentValue != null && environmentValue.trim().isNotEmpty) return environmentValue.trim();
  if (dartDefine.trim().isNotEmpty) return dartDefine.trim();
  return dotenv.isInitialized ? (dotenv.env[name] ?? '').trim() : '';
}

/// Sanitized error type for all OneBusAway failures. Messages never include
/// request URLs, which embed the API key as a query parameter.
class OneBusAwayException implements Exception {
  const OneBusAwayException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Holds OneBusAway configuration from the environment, Dart defines, or .env.
///
/// Explicit [apiEndpoint]/[apiKey] values (used by dependency injection and
/// tests) always take precedence over the environment.
class OneBusAwayConfig {
  OneBusAwayConfig({String? apiEndpoint, String? apiKey})
    : apiEndpoint = (apiEndpoint ?? _readOneBusAwaySetting(oneBusAwayApiEnvVar, _oneBusAwayApiDartDefine)).trim(),
      apiKey = (apiKey ?? _readOneBusAwaySetting(oneBusAwayApiKeyEnvVar, _oneBusAwayApiKeyDartDefine)).trim();

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
  OneBusAwayClient({
    OneBusAwayConfig? config,
    Dio? dio,
    Duration? timeout,
    ShuttleRequestTraceObserver? requestTraceObserver,
  }) : _config = config ?? OneBusAwayConfig(),
       _timeout = timeout ?? const Duration(seconds: 15),
       _requestTraceObserver = requestTraceObserver {
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
  final ShuttleRequestTraceObserver? _requestTraceObserver;
  int _logicalRequestSequence = 0;

  /// Fetches all stops served by [agencyId] (the campus shuttle agency by
  /// default). OneBusAway replaces the legacy shuttle stops feed with
  /// `GET {base}/api/where/stops-for-agency/{agencyId}.json`.
  Future<Map<String, dynamic>> fetchStopsForAgency({
    String agencyId = defaultAgencyId,
    ShuttleRequestContext? requestContext,
  }) => _get(
    '$_stopsForAgencyPathTemplate/$agencyId.json',
    endpoint: ShuttleRequestEndpoint.catalog,
    requestContext: requestContext,
  );

  /// Fetches upcoming arrivals and departures for [stopId] (the raw
  /// OneBusAway stop id, e.g. `UCSD_10772`). OneBusAway replaces the legacy
  /// arrivals feed with
  /// `GET {base}/api/where/arrivals-and-departures-for-stop/{stopId}.json`.
  Future<Map<String, dynamic>> fetchArrivalsAndDeparturesForStop(
    String stopId, {
    ShuttleRequestContext? requestContext,
  }) => _get(
    '$_arrivalsForStopPathTemplate/' + Uri.encodeComponent(stopId) + '.json',
    endpoint: ShuttleRequestEndpoint.arrivals,
    stopId: stopId,
    requestContext: requestContext,
  );

  /// Builds the request [Uri] for [path], attaching the API key as the
  /// standard OneBusAway `key` query parameter.
  Uri _buildUri(String path) {
    final String base = _config.apiEndpoint.endsWith('/')
        ? _config.apiEndpoint.substring(0, _config.apiEndpoint.length - 1)
        : _config.apiEndpoint;
    return Uri.parse('$base$path').replace(queryParameters: <String, String>{'key': _config.apiKey});
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    required ShuttleRequestEndpoint endpoint,
    String? stopId,
    ShuttleRequestContext? requestContext,
  }) {
    final context =
        requestContext ?? const ShuttleRequestContext(operationId: 0, trigger: ShuttleRequestTrigger.unspecified);
    final logicalRequestId = ++_logicalRequestSequence;
    _emit(
      ShuttleRequestTraceEvent(
        kind: ShuttleRequestTraceKind.logicalRequestStarted,
        context: context,
        endpoint: endpoint,
        stopId: stopId,
        logicalRequestId: logicalRequestId,
      ),
    );
    return _getAttempt(
      path,
      endpoint: endpoint,
      stopId: stopId,
      context: context,
      logicalRequestId: logicalRequestId,
      retryAttempt: 0,
    );
  }

  Future<Map<String, dynamic>> _getAttempt(
    String path, {
    required ShuttleRequestEndpoint endpoint,
    required ShuttleRequestContext context,
    required int logicalRequestId,
    required int retryAttempt,
    String? stopId,
  }) async {
    if (!_config.isConfigured) {
      throw const OneBusAwayException(
        'The OneBusAway API is not configured. Set the ONE_BUS_AWAY_API and '
        'ONE_BUS_AWAY_API_KEY in .env, environment variables, or --dart-define.',
      );
    }
    final attempt = retryAttempt + 1;
    final stopwatch = Stopwatch()..start();
    _emit(
      ShuttleRequestTraceEvent(
        kind: ShuttleRequestTraceKind.httpAttemptStarted,
        context: context,
        endpoint: endpoint,
        stopId: stopId,
        logicalRequestId: logicalRequestId,
        attempt: attempt,
      ),
    );
    try {
      final Response<dynamic> response = await _dio.getUri(_buildUri(path));
      stopwatch.stop();
      _emit(
        ShuttleRequestTraceEvent(
          kind: ShuttleRequestTraceKind.httpAttemptSucceeded,
          context: context,
          endpoint: endpoint,
          stopId: stopId,
          logicalRequestId: logicalRequestId,
          attempt: attempt,
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        ),
      );
      final dynamic body = response.data;
      final dynamic decoded = body is String ? jsonDecode(body) : body;
      if (decoded is! Map<String, dynamic>) {
        throw const OneBusAwayException('OneBusAway returned an unexpected JSON response shape.');
      }
      final dynamic responseCode = decoded['code'];
      if (responseCode is! num) {
        throw const OneBusAwayException('OneBusAway response is missing a numeric status code.');
      }
      final int code = responseCode.toInt();
      if (code != 200) {
        throw OneBusAwayException('OneBusAway returned error code $code.');
      }
      return decoded;
    } on OneBusAwayException {
      rethrow;
    } on FormatException {
      throw const OneBusAwayException('OneBusAway returned invalid JSON.');
    } on DioException catch (e) {
      // Never surface the request URI: it contains the API key.
      final int? status = e.response?.statusCode;
      stopwatch.stop();
      _emit(
        ShuttleRequestTraceEvent(
          kind: ShuttleRequestTraceKind.httpAttemptFailed,
          context: context,
          endpoint: endpoint,
          stopId: stopId,
          logicalRequestId: logicalRequestId,
          attempt: attempt,
          statusCode: status,
          elapsed: stopwatch.elapsed,
        ),
      );
      if (status == 429 && retryAttempt < 2) {
        final retryDelay = _rateLimitRetryDelay(e.response, retryAttempt);
        _emit(
          ShuttleRequestTraceEvent(
            kind: ShuttleRequestTraceKind.retryScheduled,
            context: context,
            endpoint: endpoint,
            stopId: stopId,
            logicalRequestId: logicalRequestId,
            attempt: attempt,
            statusCode: status,
            retryDelay: retryDelay,
          ),
        );
        await Future<void>.delayed(retryDelay);
        return _getAttempt(
          path,
          endpoint: endpoint,
          stopId: stopId,
          context: context,
          logicalRequestId: logicalRequestId,
          retryAttempt: retryAttempt + 1,
        );
      }
      throw OneBusAwayException(
        status == null ? 'Failed to reach the OneBusAway API.' : 'Failed to reach the OneBusAway API (HTTP $status).',
      );
    } catch (_) {
      // Deliberately discard the original error: network/parsing error text
      // can embed the full request URL, which contains the API key.
      throw const OneBusAwayException('Failed to process OneBusAway data.');
    }
  }

  void _emit(ShuttleRequestTraceEvent event) => _requestTraceObserver?.call(event);

  Duration _rateLimitRetryDelay(Response<dynamic>? response, int retryAttempt) {
    final String? retryAfter = response?.headers.value(HttpHeaders.retryAfterHeader);
    final int? seconds = int.tryParse(retryAfter ?? '');
    if (seconds != null && seconds >= 0) return Duration(seconds: seconds);
    if (retryAfter != null) {
      try {
        final delay = HttpDate.parse(retryAfter).difference(DateTime.now().toUtc());
        return delay.isNegative ? Duration.zero : delay;
      } on FormatException {
        // Use a short backoff when the server's retry instruction is invalid.
      }
    }
    return Duration(seconds: 2 * (retryAttempt + 1));
  }
}
