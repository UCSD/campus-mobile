import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/services/one_bus_away_client.dart';
import 'package:campus_mobile_experimental/core/services/shuttle.dart';
import 'package:campus_mobile_experimental/core/services/shuttle_request_trace.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake OneBusAway client: stands in for the HTTP layer so the service is
/// tested without touching the live API.
class _FakeOneBusAwayClient extends OneBusAwayClient {
  _FakeOneBusAwayClient({this.stopsEnvelope, this.arrivalsEnvelope, this.error})
    : super(
        config: OneBusAwayConfig(apiEndpoint: '', apiKey: ''),
      );

  final Map<String, dynamic>? stopsEnvelope;
  final Map<String, dynamic>? arrivalsEnvelope;

  /// Mutable so a single fake can script a failure followed by a success.
  Object? error;

  final List<String> requestedStopIds = [];

  @override
  Future<Map<String, dynamic>> fetchStopsForAgency({
    String agencyId = OneBusAwayClient.defaultAgencyId,
    ShuttleRequestContext? requestContext,
  }) async {
    if (error != null) throw error!;
    return stopsEnvelope!;
  }

  @override
  Future<Map<String, dynamic>> fetchArrivalsAndDeparturesForStop(
    String stopId, {
    ShuttleRequestContext? requestContext,
  }) async {
    if (error != null) throw error!;
    requestedStopIds.add(stopId);
    return arrivalsEnvelope!;
  }
}

class _PerStopOneBusAwayClient extends _FakeOneBusAwayClient {
  _PerStopOneBusAwayClient({required super.arrivalsEnvelope});

  @override
  Future<Map<String, dynamic>> fetchArrivalsAndDeparturesForStop(
    String stopId, {
    ShuttleRequestContext? requestContext,
  }) async {
    requestedStopIds.add(stopId);
    if (stopId == '5000') {
      throw const OneBusAwayException('Failed to reach the OneBusAway API (HTTP 503).');
    }
    return arrivalsEnvelope!;
  }
}

Map<String, dynamic> _stopsEnvelope() => <String, dynamic>{
  'code': 200,
  'currentTime': 1793245671045,
  'data': {
    'list': [
      {'id': 'UCSD_10772', 'name': 'Gilman Transit Center (North)', 'lat': 32.87719, 'lon': -117.235708},
      {'id': 'UCSD_10378', 'name': 'UCSD Extended Studies Building (South)', 'lat': 32.871524, 'lon': -117.233241},
    ],
  },
};

const int _now = 1000000;

Map<String, dynamic> _arrivalsEnvelope() => <String, dynamic>{
  'code': 200,
  'currentTime': _now,
  'data': {
    'entry': {
      'stopId': 'UCSD_10772',
      'arrivalsAndDepartures': [
        {
          'routeId': 'UCSD_1040',
          'routeShortName': 'IL',
          'predicted': true,
          'predictedArrivalTime': _now + 60000,
          'scheduledArrivalTime': _now + 90000,
          'arrivalEnabled': true,
          'departureEnabled': true,
          'stopId': 'UCSD_10772',
        },
        {
          'routeId': 'MTS_201',
          'routeShortName': '201',
          'predicted': true,
          'predictedArrivalTime': _now + 30000,
          'arrivalEnabled': true,
          'departureEnabled': true,
          'stopId': 'UCSD_10772',
        },
      ],
    },
    'references': {
      'routes': [
        {'id': 'UCSD_1040', 'shortName': 'IL', 'longName': 'Inside Loop', 'color': 'ffcd00'},
      ],
    },
  },
};

void main() {
  group('ShuttleService.fetchData', () {
    test('populates the stop list from the OneBusAway stops feed', () async {
      final ShuttleService service = ShuttleService(client: _FakeOneBusAwayClient(stopsEnvelope: _stopsEnvelope()));

      final bool success = await service.fetchData();

      expect(success, isTrue);
      expect(service.error, isNull);
      expect(service.data, hasLength(2));
      expect(service.data.first.id, 10772);
      expect(service.data.first.name, 'Gilman Transit Center (North)');
      expect(service.data.first.oneBusAwayId, 'UCSD_10772');
    });

    test('reports a sanitized error when the client fails', () async {
      const String endpoint = 'https://onebusaway.example.test';
      const String apiKey = 'unit-test-api-key';
      final ShuttleService service = ShuttleService(
        client: _FakeOneBusAwayClient(error: OneBusAwayException('Failed to reach the OneBusAway API (HTTP 500).')),
      );

      final bool success = await service.fetchData();

      expect(success, isFalse);
      expect(service.error, contains('HTTP 500'));
      // errors surfaced to the UI must never contain credentials
      expect(service.error?.contains(endpoint), isFalse);
      expect(service.error?.contains(apiKey), isFalse);
    });

    test('clears a previous error after a successful fetch', () async {
      final _FakeOneBusAwayClient failingClient = _FakeOneBusAwayClient(
        stopsEnvelope: _stopsEnvelope(),
        error: const OneBusAwayException('Failed to reach the OneBusAway API.'),
      );
      final ShuttleService service = ShuttleService(client: failingClient);

      expect(await service.fetchData(), isFalse);
      expect(service.error, isNotNull);

      failingClient.error = null;
      expect(await service.fetchData(), isTrue);
      expect(service.error, isNull);
    });
  });

  group('ShuttleService.getArrivingInformation', () {
    test('an empty arrivals response with MTS references succeeds', () async {
      final ShuttleService service = ShuttleService(
        client: _FakeOneBusAwayClient(
          arrivalsEnvelope: {
            'code': 200,
            'currentTime': 1793993241998,
            'data': {
              'entry': {
                'arrivalsAndDepartures': [],
                'nearbyStopIds': ['MTS_99385'],
                'situationIds': [],
                'stopId': 'UCSD_4006',
              },
              'references': {
                'routes': [
                  {'agencyId': 'MTS', 'id': 'MTS_43', 'longName': 'Balboa Av TC - Kearny Mesa', 'color': '000099'},
                ],
              },
            },
          },
        ),
      );

      final result = await service.getArrivingInformation(4006);

      expect(result.arrivals, isEmpty);
      expect(result.error, isNull);
      expect(service.error, isNull);
      expect(service.isLoading, isFalse);
    });

    test('queries arrivals with the raw OneBusAway stop id', () async {
      final _FakeOneBusAwayClient client = _FakeOneBusAwayClient(
        stopsEnvelope: _stopsEnvelope(),
        arrivalsEnvelope: _arrivalsEnvelope(),
      );
      final ShuttleService service = ShuttleService(client: client);
      await service.fetchData();

      final ShuttleArrivalResult result = await service.getArrivingInformation(10772);

      // the integer id used by the UI is translated back to UCSD_10772
      expect(client.requestedStopIds, ['UCSD_10772']);
      expect(result.error, isNull);
      expect(result.arrivals, hasLength(1));
      expect(result.arrivals.single.routeName, 'Inside Loop');
      expect(result.arrivals.single.routeColor, '#ffcd00');
      expect(result.arrivals.single.secondsToArrival, 60);
    });

    test('falls back to the stop id as-is when the stop was never fetched', () async {
      final _FakeOneBusAwayClient client = _FakeOneBusAwayClient(arrivalsEnvelope: _arrivalsEnvelope());
      final ShuttleService service = ShuttleService(client: client);

      await service.getArrivingInformation(10772);

      expect(client.requestedStopIds, ['10772']);
    });

    test('returns an empty result with a stop-specific sanitized error when the client fails', () async {
      final ShuttleService service = ShuttleService(
        client: _FakeOneBusAwayClient(error: OneBusAwayException('Failed to reach the OneBusAway API (HTTP 404).')),
      );

      final ShuttleArrivalResult result = await service.getArrivingInformation(10772);

      expect(result.arrivals, isEmpty);
      expect(result.error, contains('HTTP 404'));
      expect(service.error, isNull);
    });

    test('concurrent stops keep success and failure results independent', () async {
      final service = ShuttleService(client: _PerStopOneBusAwayClient(arrivalsEnvelope: _arrivalsEnvelope()));

      final results = await Future.wait([service.getArrivingInformation(5000), service.getArrivingInformation(10772)]);

      expect(results[0].arrivals, isEmpty);
      expect(results[0].error, contains('HTTP 503'));
      expect(results[1].arrivals, hasLength(1));
      expect(results[1].error, isNull);
      expect(service.error, isNull);
    });

    test('keeps isLoading accurate around requests', () async {
      final _FakeOneBusAwayClient client = _FakeOneBusAwayClient(
        stopsEnvelope: _stopsEnvelope(),
        arrivalsEnvelope: _arrivalsEnvelope(),
      );
      final ShuttleService service = ShuttleService(client: client);

      expect(service.isLoading, isFalse);
      final Future<bool> pending = service.fetchData();
      expect(service.isLoading, isTrue);
      await pending;
      expect(service.isLoading, isFalse);
    });
  });

  group('ShuttleService contract with the provider', () {
    test('model getters used by the Transit UI remain available', () async {
      final ShuttleService service = ShuttleService(client: _FakeOneBusAwayClient(stopsEnvelope: _stopsEnvelope()));
      await service.fetchData();

      // the provider relies on these members
      expect(service.data, isA<List<ShuttleStopModel>>());
      expect(service.error, isNull);
      expect(service.lastUpdated, isNull);
      expect(service.isLoading, isFalse);
    });
  });
}
