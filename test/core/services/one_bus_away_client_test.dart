import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_mobile_experimental/core/services/one_bus_away_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const String testEndpoint = 'https://onebusaway.example.test';
const String testApiKey = 'unit-test-api-key';

/// Fake HTTP layer: replaces dio's [HttpClientAdapter] so no real requests
/// are made. Captures request URIs so URL construction (including the API
/// key parameter) can be asserted.
class _RecordingAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? handler;
  final List<Uri> requestedUris = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    requestedUris.add(options.uri);
    final Future<ResponseBody> Function(RequestOptions options)? configuredHandler = handler;
    if (configuredHandler == null) throw StateError('no response handler configured');
    return configuredHandler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Object body, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

/// Wires a real [OneBusAwayClient] to the fake HTTP adapter.
class _Harness {
  _Harness({this.endpoint = testEndpoint, this.apiKey = testApiKey}) {
    dio = Dio();
    dio.httpClientAdapter = adapter;
    client = OneBusAwayClient(
      config: OneBusAwayConfig(apiEndpoint: endpoint, apiKey: apiKey),
      dio: dio,
    );
  }

  final String endpoint;
  final String apiKey;
  final _RecordingAdapter adapter = _RecordingAdapter();
  late final Dio dio;
  late final OneBusAwayClient client;

  void respond(Object body, {int status = 200}) {
    adapter.handler = (_) async => _jsonResponse(body, status: status);
  }

  void failWith(Object error) {
    adapter.handler = (_) async => throw error;
  }
}

void main() {
  final Map<String, dynamic> stopsEnvelope = {
    'code': 200,
    'currentTime': 1793245671045,
    'data': {
      'limitExceeded': false,
      'list': [
        {'id': 'UCSD_10378', 'lat': 32.871524, 'lon': -117.233241, 'name': 'UCSD Extended Studies Building (South)'},
        {'id': 'UCSD_10772', 'lat': 32.87719, 'lon': -117.235708, 'name': 'Gilman Transit Center (North)'},
      ],
    },
  };

  final Map<String, dynamic> arrivalsEnvelope = {
    'code': 200,
    'currentTime': 1793245671045,
    'data': {
      'entry': {'stopId': 'UCSD_10772', 'arrivalsAndDepartures': [], 'nearbyStopIds': [], 'situationIds': []},
      'references': {'routes': [], 'stops': [], 'trips': []},
    },
  };

  group('OneBusAwayConfig', () {
    test('injected values take precedence over machine environment', () {
      final OneBusAwayConfig config = OneBusAwayConfig(apiEndpoint: testEndpoint, apiKey: testApiKey);
      expect(config.apiEndpoint, testEndpoint);
      expect(config.apiKey, testApiKey);
      expect(config.isConfigured, isTrue);
    });

    test('injected empty values leave the config unconfigured', () {
      final OneBusAwayConfig config = OneBusAwayConfig(apiEndpoint: '', apiKey: '');
      expect(config.isConfigured, isFalse);
    });

    test('toString never leaks the endpoint or the key', () {
      final OneBusAwayConfig config = OneBusAwayConfig(apiEndpoint: testEndpoint, apiKey: testApiKey);
      final String description = config.toString();
      expect(description.contains(testEndpoint), isFalse);
      expect(description.contains(testApiKey), isFalse);
    });
  });

  group('OneBusAwayClient.fetchStopsForAgency', () {
    test('requests the stops-for-agency endpoint with the key as a query parameter', () async {
      final _Harness harness = _Harness()..respond(stopsEnvelope);

      final Map<String, dynamic> envelope = await harness.client.fetchStopsForAgency();

      expect(envelope['code'], 200);
      expect(envelope['data']['list'], hasLength(2));
      expect(harness.adapter.requestedUris, hasLength(1));
      final Uri uri = harness.adapter.requestedUris.first;
      expect(uri.host, 'onebusaway.example.test');
      expect(uri.path, '/api/where/stops-for-agency/UCSD.json');
      expect(uri.queryParameters['key'], testApiKey);
    });

    test('tolerates a trailing slash on the configured endpoint', () async {
      final _Harness harness = _Harness(endpoint: '$testEndpoint/')..respond(stopsEnvelope);

      final Map<String, dynamic> envelope = await harness.client.fetchStopsForAgency();

      expect(envelope['code'], 200);
      final Uri uri = harness.adapter.requestedUris.first;
      expect(uri.path, '/api/where/stops-for-agency/UCSD.json');
      expect('//'.allMatches(uri.path), isEmpty);
    });

    test('requests stops for a custom agency when provided', () async {
      final _Harness harness = _Harness()..respond(stopsEnvelope);

      await harness.client.fetchStopsForAgency(agencyId: 'MTS');

      expect(harness.adapter.requestedUris.first.path, '/api/where/stops-for-agency/MTS.json');
    });
  });

  group('OneBusAwayClient.fetchArrivalsAndDeparturesForStop', () {
    test('requests arrivals for the given raw OneBusAway stop id', () async {
      final _Harness harness = _Harness()..respond(arrivalsEnvelope);

      final Map<String, dynamic> envelope = await harness.client.fetchArrivalsAndDeparturesForStop('UCSD_10772');

      expect(envelope['code'], 200);
      expect(harness.adapter.requestedUris, hasLength(1));
      final Uri uri = harness.adapter.requestedUris.first;
      expect(uri.path, '/api/where/arrivals-and-departures-for-stop/UCSD_10772.json');
      expect(uri.queryParameters['key'], testApiKey);
    });
  });

  group('OneBusAwayClient error handling', () {
    test('throws a sanitized error on HTTP failure', () async {
      final _Harness harness = _Harness()..respond({'error': 'boom'}, status: 500);

      await expectLater(
        harness.client.fetchStopsForAgency(),
        throwsA(
          isA<OneBusAwayException>()
              .having((e) => e.message, 'message', contains('HTTP 500'))
              .having((e) => e.message, 'message', isNot(contains(testEndpoint)))
              .having((e) => e.message, 'message', isNot(contains(testApiKey))),
        ),
      );
    });

    test('throws a sanitized error on connection failure', () async {
      final _Harness harness = _Harness()..failWith(Exception('connection refused to $testEndpoint?key=$testApiKey'));

      await expectLater(
        harness.client.fetchStopsForAgency(),
        throwsA(
          isA<OneBusAwayException>()
              .having((e) => e.message, 'message', isNot(contains(testEndpoint)))
              .having((e) => e.message, 'message', isNot(contains(testApiKey))),
        ),
      );
    });

    test('throws a sanitized error when the response is not valid JSON', () async {
      final _Harness harness = _Harness()
        ..adapter.handler = (_) async => ResponseBody.fromString(
          'not json at all',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );

      await expectLater(harness.client.fetchStopsForAgency(), throwsA(isA<OneBusAwayException>()));
    });

    test('throws when the OneBusAway envelope reports a non-200 code', () async {
      final _Harness harness = _Harness()..respond({'code': 404, 'data': null});

      await expectLater(
        harness.client.fetchStopsForAgency(),
        throwsA(isA<OneBusAwayException>().having((e) => e.message, 'message', contains('404'))),
      );
    });

    test('throws without making a request when the API is not configured', () async {
      final _Harness harness = _Harness(endpoint: '', apiKey: '');

      await expectLater(
        harness.client.fetchStopsForAgency(),
        throwsA(isA<OneBusAwayException>().having((e) => e.message, 'message', contains('not configured'))),
      );
      expect(harness.adapter.requestedUris, isEmpty);
    });
  });
}
