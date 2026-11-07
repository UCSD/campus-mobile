import 'dart:async';

import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/shuttle.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedShuttleService extends ShuttleService {
  final Map<int, String> failures = {5000: 'OneBusAway returned invalid JSON.'};
  final List<int> requestedStopIds = [];
  int catalogRequestCount = 0;
  String? catalogError;
  String? _scriptedError;

  @override
  String? get error => _scriptedError;

  @override
  List<ShuttleStopModel> get data => List.unmodifiable([
    ShuttleStopModel(id: 5000, name: 'Failing Stop', lat: 32.0, lon: -117.0),
    ShuttleStopModel(id: 4006, name: 'Healthy Empty Stop', lat: 32.1, lon: -117.0),
    ShuttleStopModel(id: 10772, name: 'Gilman Transit Center', lat: 32.2, lon: -117.0),
    ShuttleStopModel(id: 6000, name: 'Sixth College', lat: 32.3, lon: -117.0),
    ShuttleStopModel(id: 7000, name: 'Seventh College', lat: 32.4, lon: -117.0),
    ShuttleStopModel(id: 8000, name: 'Eighth College', lat: 32.5, lon: -117.0),
  ]);

  @override
  Future<bool> fetchData() async {
    catalogRequestCount++;
    _scriptedError = catalogError;
    return catalogError == null;
  }

  @override
  Future<ShuttleArrivalResult> getArrivingInformation(stopId) async {
    requestedStopIds.add(stopId as int);
    final error = failures[stopId];
    if (error != null) return ShuttleArrivalResult(arrivals: const [], error: error);
    if (stopId != 10772) return const ShuttleArrivalResult(arrivals: []);
    return ShuttleArrivalResult(
      arrivals: List.unmodifiable([
        ArrivingShuttle(routeId: 1040, routeName: 'Inside Loop', routeColor: '#ffcd00', secondsToArrival: 60),
      ]),
    );
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

class _ControlledArrivalShuttleService extends _ScriptedShuttleService {
  final Map<int, Completer<ShuttleArrivalResult>> arrivalRequests = {};

  @override
  Future<ShuttleArrivalResult> getArrivingInformation(stopId) {
    final id = stopId as int;
    requestedStopIds.add(id);
    _scriptedError = null;
    final request = Completer<ShuttleArrivalResult>();
    arrivalRequests[id] = request;
    return request.future;
  }

  void completeArrival(int stopId, [List<ArrivingShuttle> arrivals = const []]) {
    arrivalRequests.remove(stopId)!.complete(ShuttleArrivalResult(arrivals: arrivals));
  }
}

class _TestUserDataProvider extends UserDataProvider {
  int profilePosts = 0;

  @override
  Future postUserProfile(UserProfileModel profile) async {
    profilePosts++;
  }
}

ShuttleDataProvider _provider(_ScriptedShuttleService service, List<int> selectedStops) {
  final user = _TestUserDataProvider();
  user.userProfileModel.selectedStops = selectedStops;
  final provider = ShuttleDataProvider(shuttleService: service)..userDataProvider = user;
  addTearDown(provider.dispose);
  addTearDown(user.dispose);
  return provider;
}

void main() {
  test('startup updates share one catalog request and use the latest selection', () async {
    final service = _ControlledShuttleService();
    final provider = _provider(service, []);

    final first = provider.fetchStops(true, refreshCatalog: false);
    provider.userDataProvider!.userProfileModel.selectedStops = [4006];
    final second = provider.fetchStops(true, refreshCatalog: false);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772];
    final third = provider.fetchStops(true, refreshCatalog: false);

    expect(service.catalogRequests, hasLength(1));
    expect(provider.isLoading, isTrue);

    service.catalogRequests.first.complete(true);
    await Future.wait([first, second, third]);

    expect(service.catalogRequests, hasLength(1));
    expect(provider.error, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.stopsToRender.map((stop) => stop.id), [10772]);
    expect(service.requestedStopIds, [10772]);
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
    expect(service.error, isNull);
  });

  test('selected stops ignore nulls and duplicates while preserving first-seen order', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [10772, 4006]);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772, null, 10772, 4006, 4006];

    await provider.fetchStops(true);

    expect(provider.stopsToRender.map((stop) => stop.id), [10772, 4006]);
    expect(service.requestedStopIds, [10772, 4006]);
    expect(provider.userDataProvider!.userProfileModel.selectedStops, [10772, null, 10772, 4006, 4006]);
  });

  test('selected stops ignore unknown ids and stop after five valid unique ids', () async {
    final service = _ScriptedShuttleService()..failures.clear();
    final provider = _provider(service, [9999, 5000, 4006, 10772, 6000, 7000, 8000]);

    await provider.fetchStops(true);

    expect(provider.stopsToRender.map((stop) => stop.id), [5000, 4006, 10772, 6000, 7000]);
    expect(service.requestedStopIds, [5000, 4006, 10772, 6000, 7000]);
    expect(provider.userDataProvider!.userProfileModel.selectedStops, [9999, 5000, 4006, 10772, 6000, 7000, 8000]);
  });

  test('reordering normalizes nullable, duplicate, unknown, and over-limit ids', () async {
    final service = _ScriptedShuttleService()..failures.clear();
    final provider = _provider(service, [10772, 4006, 6000, 7000, 8000]);
    await provider.fetchStops(true);
    service.requestedStopIds.clear();

    provider.reorderStops([8000, null, 7000, 8000, 6000, 9999, 4006, 10772, 5000]);
    await provider.fetchStops(true, refreshCatalog: false);

    expect(provider.userDataProvider!.userProfileModel.selectedStops, [8000, 7000, 6000, 4006, 10772]);
    expect(provider.stopsToRender.map((stop) => stop.id), [8000, 7000, 6000, 4006, 10772]);
    expect(service.requestedStopIds, isEmpty);
  });

  test('adding rejects duplicate, unknown, and sixth stops without mutation or requests', () async {
    final service = _ScriptedShuttleService()..failures.clear();
    final provider = _provider(service, [5000, 4006, 10772, 6000, 7000]);
    await provider.fetchStops(true);
    service.requestedStopIds.clear();

    await provider.addStop(5000);
    await provider.addStop(9999);
    await provider.addStop(8000);

    expect(provider.userDataProvider!.userProfileModel.selectedStops, [5000, 4006, 10772, 6000, 7000]);
    expect(service.requestedStopIds, isEmpty);
  });

  test('adding a valid stop persists the normalized selection and requests only that stop', () async {
    final service = _ScriptedShuttleService()..failures.clear();
    final provider = _provider(service, [10772]);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772, null, 10772, 9999];
    await provider.fetchStops(true);
    service.requestedStopIds.clear();

    await provider.addStop(4006);

    expect(provider.userDataProvider!.userProfileModel.selectedStops, [10772, 4006]);
    expect(service.requestedStopIds, [4006]);
    expect((provider.userDataProvider! as _TestUserDataProvider).profilePosts, 1);
  });

  test('removing a stop persists the remaining normalized selection', () async {
    final service = _ScriptedShuttleService()..failures.clear();
    final provider = _provider(service, [5000, 4006]);
    provider.userDataProvider!.userProfileModel.selectedStops = [5000, null, 5000, 9999, 4006];
    await provider.fetchStops(true);
    service.requestedStopIds.clear();

    await provider.removeStop(5000);

    expect(provider.userDataProvider!.userProfileModel.selectedStops, [4006]);
    expect(provider.stopsToRender.map((stop) => stop.id), [4006]);
    expect((provider.userDataProvider! as _TestUserDataProvider).profilePosts, 1);
    expect(service.requestedStopIds, isEmpty);
  });

  test('overlapping notifications share one in-flight arrival request per stop', () async {
    final service = _ControlledArrivalShuttleService();
    final provider = _provider(service, []);
    await provider.fetchStops(true, refreshCatalog: false);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772];

    final first = provider.fetchStops(true, refreshCatalog: false);
    await Future<void>.delayed(Duration.zero);
    final second = provider.fetchStops(true, refreshCatalog: false);

    expect(service.requestedStopIds, [10772]);
    service.completeArrival(10772);
    await Future.wait([first, second]);
    expect(service.requestedStopIds, [10772]);
  });

  test('add and profile notification join the same arrival request', () async {
    final service = _ControlledArrivalShuttleService();
    final provider = _provider(service, []);
    await provider.fetchStops(true, refreshCatalog: false);

    final add = provider.addStop(10772);
    await Future<void>.delayed(Duration.zero);
    final notification = provider.fetchStops(true, refreshCatalog: false);

    expect(service.requestedStopIds, [10772]);
    service.completeArrival(10772);
    await Future.wait([add, notification]);
    expect(service.requestedStopIds, [10772]);
  });

  test('an in-flight result cannot restore a stop removed during its request', () async {
    final service = _ControlledArrivalShuttleService();
    final provider = _provider(service, []);
    await provider.fetchStops(true, refreshCatalog: false);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772];

    final fetch = provider.fetchStops(true, refreshCatalog: false);
    await Future<void>.delayed(Duration.zero);
    final remove = provider.removeStop(10772);

    service.completeArrival(10772, [
      ArrivingShuttle(routeId: 1040, routeName: 'Inside Loop', routeColor: '#ffcd00', secondsToArrival: 60),
    ]);
    await Future.wait([fetch, remove]);

    expect(provider.stopsToRender, isEmpty);
    expect(provider.arrivalsToRender.containsKey(10772), isFalse);
    expect(service.requestedStopIds, [10772]);
  });

  test('selection changes during arrivals request only newly needed stops', () async {
    final service = _ControlledArrivalShuttleService();
    final provider = _provider(service, []);
    await provider.fetchStops(true, refreshCatalog: false);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772];

    final first = provider.fetchStops(true, refreshCatalog: false);
    await Future<void>.delayed(Duration.zero);
    provider.userDataProvider!.userProfileModel.selectedStops = [10772, 4006];
    final second = provider.fetchStops(true, refreshCatalog: false);

    service.completeArrival(10772);
    await Future<void>.delayed(Duration.zero);
    expect(service.requestedStopIds, [10772, 4006]);

    service.completeArrival(4006);
    await Future.wait([first, second]);
    expect(service.requestedStopIds, [10772, 4006]);
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
    expect(service.requestedStopIds, [4006, 10772]);

    final manualReload = provider.fetchStops(true);
    expect(service.catalogRequests, hasLength(2));
    service.catalogRequests.last.complete(true);
    await manualReload;
    expect(provider.error, isNull);
    expect(service.requestedStopIds, [4006, 10772, 10772]);
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

  test('an unselected closest stop is calculated but not requested', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [10772])..userCoords = Coordinates(lat: 32.0, lon: -117.0);

    await provider.fetchStops(true);

    expect(provider.closestStop!.id, 5000);
    expect(provider.error, isNull);
    expect(provider.arrivalsToRender[10772], hasLength(1));
    expect(service.requestedStopIds, [10772]);
  });

  test('no selected stops makes no arrival requests even when a closest stop exists', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [])..userCoords = Coordinates(lat: 32.0, lon: -117.0);

    await provider.fetchStops(true);

    expect(provider.closestStop!.id, 5000);
    expect(service.requestedStopIds, isEmpty);
  });

  test('coordinate-only changes make no catalog or arrival requests', () async {
    final service = _ScriptedShuttleService();
    final provider = _provider(service, [10772])..userCoords = Coordinates(lat: 32.0, lon: -117.0);
    await provider.fetchStops(true, refreshCatalog: false);
    service.requestedStopIds.clear();

    provider.userCoords = Coordinates(lat: 33.0, lon: -118.0);
    await provider.fetchStops(true, refreshCatalog: false);

    expect(service.catalogRequestCount, 1);
    expect(service.requestedStopIds, isEmpty);
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
