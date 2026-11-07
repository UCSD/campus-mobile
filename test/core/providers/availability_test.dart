import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final silent in [false, true]) {
    test('${silent ? 'silent' : 'manual'} refresh recovers from an earlier fetch error', () async {
      await _withAvailability((fixture) async {
        fixture.statusCode = 503;
        await fixture.fetch();
        expect(fixture.provider.error, isNotNull);
        expect(fixture.provider.lastUpdated, isNull);

        fixture.statusCode = 200;
        await fixture.fetch(silent: silent);
        expect(fixture.provider.error, isNull);
        expect(fixture.provider.availabilityModels.single!.name, 'Geisel');
        expect(fixture.provider.locationViewState['Geisel'], isTrue);
        expect(fixture.provider.lastUpdated, isNotNull);
        expect(fixture.provider.isLoading, isFalse);
      });
    });
  }

  test('failed silent refresh preserves the last successful data and existing error state', () async {
    await _withAvailability((fixture) async {
      await fixture.fetch();
      final lastUpdated = fixture.provider.lastUpdated;
      final location = fixture.provider.availabilityModels.single;

      fixture.statusCode = 503;
      await fixture.fetch(silent: true);
      expect(fixture.provider.error, isNull);
      expect(fixture.provider.availabilityModels.single, same(location));
      expect(fixture.provider.lastUpdated, lastUpdated);

      await fixture.fetch();
      final error = fixture.provider.error;
      expect(error, isNotNull);
      await fixture.fetch(silent: true);
      expect(fixture.provider.error, error);
      expect(fixture.provider.availabilityModels.single, same(location));
      expect(fixture.provider.lastUpdated, lastUpdated);
      expect(fixture.provider.isLoading, isFalse);
    });
  });

  test('repeated background failures keep cached data until a successful refresh clears the failure state', () async {
    await _withAvailability((fixture) async {
      expect(fixture.provider.refreshFailed, isFalse);
      await fixture.fetch();
      final lastUpdated = fixture.provider.lastUpdated;
      final location = fixture.provider.availabilityModels.single;

      fixture.statusCode = 503;
      for (var attempt = 0; attempt < 3; attempt++) {
        await fixture.fetch(silent: true);
        expect(fixture.provider.refreshFailed, isTrue);
        expect(fixture.provider.error, isNull);
        expect(fixture.provider.isLoading, isFalse);
        expect(fixture.provider.lastUpdated, lastUpdated);
        expect(fixture.provider.availabilityModels.single, same(location));
      }

      fixture.statusCode = 200;
      fixture.locationName = 'Updated Geisel';
      await fixture.fetch(silent: true);
      expect(fixture.provider.refreshFailed, isFalse);
      expect(fixture.provider.availabilityModels.single!.name, 'Updated Geisel');
      expect(fixture.provider.lastUpdated!.isAfter(lastUpdated!), isTrue);
    });
  });

  for (final firstSilent in [false, true]) {
    for (final secondSilent in [false, true]) {
      test(
        'overlapping ${firstSilent ? 'silent' : 'manual'} and ${secondSilent ? 'silent' : 'manual'} refreshes use one request',
        () async {
          await _withAvailability((fixture) async {
            fixture.requestStarted = Completer<void>();
            fixture.responseGate = Completer<void>();
            final first = fixture.fetch(silent: firstSilent);
            await fixture.requestStarted!.future.timeout(const Duration(seconds: 5));

            final second = fixture.fetch(silent: secondSilent);
            final loadingBeforeResponse = fixture.provider.isLoading;
            fixture.responseGate!.complete();
            await Future.wait([first, second]);

            expect(fixture.requestCount, 1);
            expect(loadingBeforeResponse, !firstSilent);
            expect(fixture.provider.isLoading, isFalse);
            expect(fixture.provider.availabilityModels.single!.name, 'Geisel');

            // Once the active request finishes, a new refresh must be accepted.
            fixture.locationName = 'Updated Geisel';
            await fixture.fetch(silent: secondSilent);
            expect(fixture.requestCount, 2);
            expect(fixture.provider.availabilityModels.single!.name, 'Updated Geisel');
          });
        },
      );
    }
  }
}

// Use loopback HTTP to exercise the real service without production endpoints.
// Flutter otherwise blocks test HTTP.
class _LocalHttpOverrides extends HttpOverrides {}

Future<void> _withAvailability(Future<void> Function(_AvailabilityFixture) verify) => HttpOverrides.runZoned(() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  dotenv.testLoad(
    fileInput: 'DEFAULT_TIMEOUT=5000\nAVAILABILITY_API_ENDPOINT=http://127.0.0.1:${server.port}/availability',
  );
  final user = UserDataProvider();
  final fixture = _AvailabilityFixture(AvailabilityDataProvider()..userDataProvider = user);
  server.listen((request) async {
    fixture.requestCount++;
    final statusCode = fixture.statusCode;
    final locationName = fixture.locationName;
    final started = fixture.requestStarted;
    if (started != null && !started.isCompleted) started.complete();
    await fixture.responseGate?.future;
    request.response.statusCode = statusCode;
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      statusCode == 200
          ? jsonEncode({
              'status': 'success',
              'timestamp': '2026-10-30T12:00:00Z',
              'data': [
                {'id': 1, 'name': locationName, 'childCounts': []},
              ],
            })
          : jsonEncode({'error': 'unavailable'}),
    );
    await request.response.close();
  });
  try {
    await verify(fixture);
  } finally {
    fixture.provider.dispose();
    user.dispose();
    await server.close(force: true);
    dotenv.clean();
  }
}, createHttpClient: (context) => _LocalHttpOverrides().createHttpClient(context));

class _AvailabilityFixture {
  _AvailabilityFixture(this.provider);

  final AvailabilityDataProvider provider;
  int statusCode = 200;
  int requestCount = 0;
  String locationName = 'Geisel';
  Completer<void>? requestStarted;
  Completer<void>? responseGate;

  Future<void> fetch({bool silent = false}) =>
      provider.fetchAvailability(silent: silent).timeout(const Duration(seconds: 5));
}
