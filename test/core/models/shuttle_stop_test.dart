import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('oneBusAwayIdToInt', () {
    test('parses the numeric part of an agency-prefixed id', () {
      expect(oneBusAwayIdToInt('UCSD_1040'), 1040);
      expect(oneBusAwayIdToInt('MTS_201'), 201);
    });

    test('parses an unprefixed numeric id', () {
      expect(oneBusAwayIdToInt('1040'), 1040);
    });

    test('uses the segment after the last separator', () {
      expect(oneBusAwayIdToInt('A_B_42'), 42);
    });

    test('falls back to a stable non-negative hash for non-numeric ids', () {
      final int id = oneBusAwayIdToInt('UCSD_not-a-number');
      expect(id, isNonNegative);
      expect(id, oneBusAwayIdToInt('UCSD_not-a-number'));
      expect(id, isNot(oneBusAwayIdToInt('UCSD_another-one')));
    });
  });

  group('shuttleStopsFromOneBusAwayEnvelope', () {
    test('maps OneBusAway stops onto the existing ShuttleStopModel shape', () {
      final Map<String, dynamic> envelope = {
        'code': 200,
        'currentTime': 1793245671045,
        'data': {
          'limitExceeded': false,
          'list': [
            {
              'id': 'UCSD_10378',
              'code': '10378',
              'name': 'UCSD Extended Studies Building (South)',
              'lat': 32.871524,
              'lon': -117.233241,
              'routeIds': ['UCSD_1050'],
            },
            {
              'id': 'UCSD_10772',
              'code': '10772',
              'name': 'Gilman Transit Center (North)',
              'lat': 32.87719056969953,
              'lon': -117.23570826703958,
              'routeIds': ['UCSD_1040', 'UCSD_1050'],
            },
          ],
        },
      };

      final List<ShuttleStopModel> stops = shuttleStopsFromOneBusAwayEnvelope(envelope);

      expect(stops, hasLength(2));
      final ShuttleStopModel first = stops.first;
      expect(first.id, 10378);
      expect(first.name, 'UCSD Extended Studies Building (South)');
      expect(first.lat, 32.871524);
      expect(first.lon, -117.233241);
      expect(first.oneBusAwayId, 'UCSD_10378');
      // the raw id is kept so the arrivals endpoint can be queried with it
      expect(stops[1].id, 10772);
      expect(stops[1].oneBusAwayId, 'UCSD_10772');
    });

    test('skips malformed entries instead of crashing', () {
      final Map<String, dynamic> envelope = {
        'code': 200,
        'currentTime': 1793245671045,
        'data': {
          'list': [
            {'id': 'UCSD_10378', 'name': 'Good Stop', 'lat': 32.87, 'lon': -117.23},
            {'id': 'UCSD_BAD', 'name': 'Missing coordinates'},
            {'name': 'Missing id', 'lat': 32.87, 'lon': -117.23},
            'not-even-a-map',
            null,
            {'id': '', 'name': 'Empty id', 'lat': 32.87, 'lon': -117.23},
          ],
        },
      };

      final List<ShuttleStopModel> stops = shuttleStopsFromOneBusAwayEnvelope(envelope);

      expect(stops, hasLength(1));
      expect(stops.single.id, 10378);
    });

    test('degrades gracefully when data or list is missing', () {
      expect(shuttleStopsFromOneBusAwayEnvelope(<String, dynamic>{}), isEmpty);
      expect(shuttleStopsFromOneBusAwayEnvelope(<String, dynamic>{'data': null}), isEmpty);
      expect(shuttleStopsFromOneBusAwayEnvelope(<String, dynamic>{'data': <String, dynamic>{}}), isEmpty);
      expect(
        shuttleStopsFromOneBusAwayEnvelope(<String, dynamic>{
          'data': <String, dynamic>{'list': null},
        }),
        isEmpty,
      );
    });

    test('keeps the legacy JSON parsing behavior intact', () {
      const String legacyJson = '''
        {
          "789": {"lat": 1.5, "lon": -2.5, "id": 789, "name": "Legacy Stop"}
        }
      ''';

      final List<ShuttleStopModel> stops = shuttleStopModelFromJson(legacyJson);

      expect(stops, hasLength(1));
      expect(stops.single.id, 789);
      expect(stops.single.name, 'Legacy Stop');
      expect(stops.single.oneBusAwayId, isNull);
    });
  });
}
