import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a minimal OneBusAway `arrivals-and-departures-for-stop` envelope
/// around [arrivals] and [routes].
Map<String, dynamic> envelopeWith({
  List<dynamic> arrivals = const [],
  List<Map<String, dynamic>> routes = const [],
  int currentTime = 1000000,
}) => <String, dynamic>{
  'code': 200,
  'currentTime': currentTime,
  'data': {
    'entry': {'stopId': 'UCSD_10772', 'arrivalsAndDepartures': arrivals, 'nearbyStopIds': [], 'situationIds': []},
    'references': {'routes': routes, 'stops': [], 'trips': []},
  },
};

Map<String, dynamic> ucsdRoute({
  String id = 'UCSD_1040',
  String shortName = 'IL',
  String longName = 'Inside Loop',
  String color = 'ffcd00',
}) => <String, dynamic>{
  'agencyId': 'UCSD',
  'id': id,
  'shortName': shortName,
  'longName': longName,
  'color': color,
  'type': 3,
};

Map<String, dynamic> arrival({
  String routeId = 'UCSD_1040',
  String? routeShortName,
  bool predicted = false,
  int? predictedArrivalTime,
  int? scheduledArrivalTime,
  int? predictedDepartureTime,
  int? scheduledDepartureTime,
  bool arrivalEnabled = true,
  bool departureEnabled = true,
  String stopId = 'UCSD_10772',
  String? tripHeadsign,
}) => <String, dynamic>{
  'routeId': routeId,
  'routeShortName': routeShortName,
  'tripHeadsign': tripHeadsign,
  'predicted': predicted,
  'predictedArrivalTime': predictedArrivalTime,
  'scheduledArrivalTime': scheduledArrivalTime,
  'predictedDepartureTime': predictedDepartureTime,
  'scheduledDepartureTime': scheduledDepartureTime,
  'arrivalEnabled': arrivalEnabled,
  'departureEnabled': departureEnabled,
  'stopId': stopId,
};

void main() {
  group('arrivingShuttlesFromOneBusAwayEnvelope', () {
    test('maps OneBusAway arrivals onto the existing ArrivingShuttle shape', () {
      final int now = 1000000;
      final Map<String, dynamic> envelope = envelopeWith(
        currentTime: now,
        routes: [ucsdRoute()],
        arrivals: [arrival(predicted: true, predictedArrivalTime: now + 60000, scheduledArrivalTime: now + 120000)],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles, hasLength(1));
      final ArrivingShuttle shuttle = shuttles.single;
      expect(shuttle.routeId, 1040);
      expect(shuttle.routeName, 'Inside Loop');
      expect(shuttle.routeColor, '#ffcd00');
      expect(shuttle.routeStopId, 10772);
      expect(shuttle.secondsToArrival, 60);
    });

    test('drops arrivals from other agencies when an agency filter is given', () {
      final Map<String, dynamic> envelope = envelopeWith(
        routes: [
          ucsdRoute(),
          ucsdRoute(id: 'MTS_201', shortName: '201', longName: 'Super Loop - Counterclockwise', color: 'CC0000'),
        ],
        arrivals: [
          arrival(routeId: 'UCSD_1040', scheduledArrivalTime: 1060000),
          arrival(routeId: 'MTS_201', scheduledArrivalTime: 1030000),
          arrival(routeId: 'NCTD_301', scheduledArrivalTime: 1040000),
        ],
      );

      final List<ArrivingShuttle> filtered = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');
      expect(filtered.map((s) => s.routeId), [1040]);

      final List<ArrivingShuttle> unfiltered = arrivingShuttlesFromOneBusAwayEnvelope(envelope);
      expect(unfiltered, hasLength(3));
    });

    test('prefers real-time predictions over scheduled arrival times', () {
      final int now = 1000000;
      final Map<String, dynamic> envelope = envelopeWith(
        currentTime: now,
        arrivals: [arrival(predicted: true, predictedArrivalTime: now + 30000, scheduledArrivalTime: now + 300000)],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles.single.secondsToArrival, 30);
    });

    test('falls back to scheduled arrival time when not predicted', () {
      final int now = 1000000;
      final Map<String, dynamic> envelope = envelopeWith(
        currentTime: now,
        arrivals: [arrival(predicted: false, predictedArrivalTime: now + 30000, scheduledArrivalTime: now + 300000)],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles.single.secondsToArrival, 300);
    });

    test('uses departure time when arrival is disabled or missing', () {
      final int now = 1000000;
      final Map<String, dynamic> envelope = envelopeWith(
        currentTime: now,
        arrivals: [
          arrival(arrivalEnabled: false, scheduledDepartureTime: now + 120000),
          arrival(scheduledArrivalTime: 0, scheduledDepartureTime: now + 180000),
        ],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles, hasLength(2));
      expect(shuttles[0].secondsToArrival, 120);
      expect(shuttles[1].secondsToArrival, 180);
    });

    test('clamps arrivals that are already at the stop to zero seconds', () {
      final int now = 1000000;
      final Map<String, dynamic> envelope = envelopeWith(
        currentTime: now,
        arrivals: [arrival(predicted: true, predictedArrivalTime: now - 30000)],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles.single.secondsToArrival, 0);
    });

    test('skips arrivals without any usable arrival or departure time', () {
      final Map<String, dynamic> envelope = envelopeWith(
        arrivals: [
          arrival(),
          arrival(scheduledArrivalTime: 0, scheduledDepartureTime: 0),
          arrival(arrivalEnabled: false, departureEnabled: false, scheduledArrivalTime: 1500000),
          'not-even-a-map',
          null,
        ],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles, isEmpty);
    });

    test('resolves the route name with a graceful fallback chain', () {
      final Map<String, dynamic> envelope = envelopeWith(
        routes: [ucsdRoute(longName: '', shortName: 'OL')],
        arrivals: [
          // referenced route: prefer its short name when long name is empty
          arrival(routeId: 'UCSD_1040', routeShortName: 'ignored', scheduledArrivalTime: 1060000),
          // unreferenced route: fall back to the fields on the arrival
          arrival(routeId: 'UCSD_9999', routeShortName: 'X9', scheduledArrivalTime: 1060000),
          // no reference and no short name: fall back to the trip headsign
          arrival(routeId: 'UCSD_8888', tripHeadsign: 'UTC', scheduledArrivalTime: 1060000),
        ],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles[0].routeName, 'OL');
      expect(shuttles[1].routeName, 'X9');
      expect(shuttles[2].routeName, 'UTC');
    });

    test('defaults the route name when nothing usable is available', () {
      final Map<String, dynamic> envelope = envelopeWith(
        arrivals: [arrival(routeId: 'UCSD_7777', scheduledArrivalTime: 1060000)],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles.single.routeName, 'Route');
    });

    test('normalizes OneBusAway colors and defaults when unusable', () {
      final Map<String, dynamic> envelope = envelopeWith(
        routes: [
          ucsdRoute(id: 'UCSD_1040', color: '182b49'),
          ucsdRoute(id: 'UCSD_1030', color: ''),
          ucsdRoute(id: 'UCSD_1020', color: 'not-a-color'),
        ],
        arrivals: [
          arrival(routeId: 'UCSD_1040', scheduledArrivalTime: 1060000),
          arrival(routeId: 'UCSD_1030', scheduledArrivalTime: 1060000),
          arrival(routeId: 'UCSD_1020', scheduledArrivalTime: 1060000),
          // no referenced route at all
          arrival(routeId: 'UCSD_1010', scheduledArrivalTime: 1060000),
        ],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: 'UCSD');

      expect(shuttles[0].routeColor, '#182b49');
      expect(shuttles[1].routeColor, oneBusAwayDefaultRouteColor);
      expect(shuttles[2].routeColor, oneBusAwayDefaultRouteColor);
      expect(shuttles[3].routeColor, oneBusAwayDefaultRouteColor);
    });

    test('supports an injected reference time for deterministic mapping', () {
      final Map<String, dynamic> envelope = envelopeWith(
        currentTime: 500,
        arrivals: [arrival(scheduledArrivalTime: 1000000)],
      );

      final List<ArrivingShuttle> shuttles = arrivingShuttlesFromOneBusAwayEnvelope(
        envelope,
        agencyId: 'UCSD',
        nowMs: 400000,
      );

      expect(shuttles.single.secondsToArrival, 600);
    });

    test('degrades gracefully when data or entry is missing', () {
      expect(arrivingShuttlesFromOneBusAwayEnvelope(<String, dynamic>{}), isEmpty);
      expect(arrivingShuttlesFromOneBusAwayEnvelope(<String, dynamic>{'data': null}), isEmpty);
      expect(arrivingShuttlesFromOneBusAwayEnvelope(<String, dynamic>{'data': <String, dynamic>{}}), isEmpty);
      expect(
        arrivingShuttlesFromOneBusAwayEnvelope(<String, dynamic>{
          'data': <String, dynamic>{'entry': <String, dynamic>{}},
        }),
        isEmpty,
      );
    });

    test('keeps the legacy JSON parsing behavior intact', () {
      const String legacyJson = '''
        [
          {
            "routeId": 1040,
            "routeName": "Inside Loop",
            "routeStopId": 10772,
            "routeColor": "#FFCD00",
            "secondsToArrival": 120
          }
        ]
      ''';

      final List<ArrivingShuttle> shuttles = getArrivingShuttles(legacyJson);

      expect(shuttles, hasLength(1));
      expect(shuttles.single.routeName, 'Inside Loop');
      expect(shuttles.single.routeColor, '#FFCD00');
      expect(shuttles.single.secondsToArrival, 120);
    });
  });
}
