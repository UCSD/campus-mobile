import 'dart:async';

import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/shuttle.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedShuttleService extends ShuttleService {
  final Map<int, String> failures = {5000: 'OneBusAway returned invalid JSON.'};
  final List<int> requestedStopIds = [];
  String? catalogError;
  String? _scriptedError;

  @override
  String? get error => _scriptedError;

  @override
  List<ShuttleStopModel> get data => List.unmodifiable([
    ShuttleStopModel(id: 5000, name: 'Failing Stop', lat: 32.0, lon: -117.0),
    ShuttleStopModel(id: 4006, name: 'Healthy Empty Stop', lat: 32.1, lon: -117.0),
    ShuttleStopModel(id: 10772, name: 'Gilman Transit Center', lat: 32.2, lon: -117.0),
  ]);

  @override
  Future<bool> fetchData() async {
    _scriptedError = catalogError;
    return catalogError == null;
  }

  @override
  Future<List<ArrivingShuttle>> getArrivingInformation(stopId) async {
    requestedStopIds.add(stopId as int);
    _scriptedError = failures[stopId];
    if (_scriptedError != null || stopId != 10772) return const [];
    return List.unmodifiable([
      ArrivingShuttle(routeId: 1040, routeName: 'Inside Loop', routeColor: '#ffcd00', secondsToArrival: 60),
    ]);
  }
}

class _ControlledShuttleService extends _ScriptedShuttleService {
  final List<Completer<bool>> catalogRequests = [];

  @override
  Future<bool> fetchData() async {
    final request = Completer<bool>();
    catalogRequests.add(request);
    final success = await request.future;
    _scriptedError = success ? null : 'Failed to reach the OneBusAway API.';
    return success;
  }
}

ShuttleDataProvider _provider(_ScriptedShuttleService service, List<int> selectedStops) {
  final user = UserDataProvider();
  user.userProfileModel.selectedStops = selectedStops;
  final provider = ShuttleDataProvider(shuttleService: service)..userDataProvider = user;
  addTearDown(provider.dispose);
  addTearDown(user.dispose);
  return provider;
}

void main() {
  test('startup updates queue one refresh and clear an earlier failure', () async {
    final service = _ControlledShuttleService();
    final provider = _provider(service, []);

    final first = provider.fetchStops(true);
    provider.userDataProvider!.userProfileModel.selectedStops = [4006];
    final second = provider.fetchStops(true);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772];
    final third = provider.fetchStops(true);

    expect(service.catalogRequests, hasLength(1));
    expect(provider.isLoading, isTrue);

    service.catalogRequests.first.complete(false);
    await Future<void>.delayed(Duration.zero);

    expect(service.catalogRequests, hasLength(2));
    expect(provider.isLoading, isTrue);
    expect(provider.error, isNull);

    service.catalogRequests.last.complete(true);
    await Future.wait([first, second, third]);

    expect(service.catalogRequests, hasLength(2));
    expect(provider.error, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.stopsToRender.map((stop) => stop.id), [10772]);
    expect(provider.arrivalsToRender[10772], hasLength(1));
  });

  test('one failed stop leaves successful arrivals and empty stops visible', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [5000, 4006, 10772]);

    await provider.fetchStops(true);

    expect(provider.error, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.stopsToRender.map((stop) => stop.id), [5000, 4006, 10772]);
    expect(provider.arrivalErrors, {5000: 'OneBusAway returned invalid JSON.'});
    expect(provider.arrivalsToRender[4006], isEmpty);
    expect(provider.arrivalsToRender[10772]!.single.routeName, 'Inside Loop');
  });

  test('dependency updates reuse the catalog while manual reload refreshes it', () async {
    final service = _ControlledShuttleService();
    final provider = _provider(service, [4006]);
    final initial = provider.fetchStops(true, refreshCatalog: false);
    service.catalogRequests.single.complete(true);
    await initial;

    await provider.fetchStops(true, refreshCatalog: false);
    expect(service.catalogRequests, hasLength(1));
    expect(service.requestedStopIds, [4006]);

    provider.userDataProvider!.userProfileModel.selectedStops = [10772];
    await provider.fetchStops(true, refreshCatalog: false);
    expect(service.catalogRequests, hasLength(1));
    expect(provider.arrivalsToRender[10772], hasLength(1));

    final manualReload = provider.fetchStops(true);
    expect(service.catalogRequests, hasLength(2));
    service.catalogRequests.last.complete(true);
    await manualReload;
    expect(provider.error, isNull);
  });

  test('a successful retry clears the affected stop error', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [5000, 4006]);
    await provider.fetchStops(true);
    expect(provider.arrivalErrors.containsKey(5000), isTrue);

    service.failures.clear();
    await provider.fetchStops(true);

    expect(provider.error, isNull);
    expect(provider.arrivalErrors, isEmpty);
    expect(provider.arrivalsToRender[5000], isEmpty);
  });

  test('failure at an unselected closest stop does not hide selected stops', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [10772])..userCoords = Coordinates(lat: 32.0, lon: -117.0);

    await provider.fetchStops(true);

    expect(provider.closestStop!.id, 5000);
    expect(provider.error, isNull);
    expect(provider.arrivalsToRender[10772], hasLength(1));
  });

  test('a selected closest stop is requested only once', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [5000, 4006])..userCoords = Coordinates(lat: 32.0, lon: -117.0);

    await provider.fetchStops(true);

    expect(service.requestedStopIds, [5000, 4006]);
  });

  test('a stop catalog failure still reports a card error', () async {
    final service = _ScriptedShuttleService()..catalogError = 'Failed to reach the OneBusAway API.';
    final provider = _provider(service, [4006]);

    await provider.fetchStops(true);

    expect(provider.error, 'Failed to reach the OneBusAway API.');
    expect(provider.isLoading, isFalse);
    expect(service.requestedStopIds, isEmpty);
  });
}
