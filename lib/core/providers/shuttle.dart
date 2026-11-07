import 'dart:async';
import 'dart:math' as Math;
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/shuttle.dart';
import 'package:campus_mobile_experimental/core/services/shuttle_request_trace.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

class ShuttleDataProvider extends ChangeNotifier {
  ShuttleDataProvider({ShuttleService? shuttleService, ShuttleRequestTraceObserver? requestTraceObserver})
    : _requestTraceObserver = requestTraceObserver,
      _shuttleService = shuttleService ?? ShuttleService(requestTraceObserver: requestTraceObserver);

  static const int maxSelectedStops = 5;

  /// STATES
  bool _isLoading = false;
  String? _error;
  double closestDistance = 10000000;
  Map<int, List<ArrivingShuttle>> arrivalsToRender = {};
  final Map<int, String> arrivalErrors = {};
  Coordinates? _userCoords;

  /// MODELS
  ShuttleStopModel? _closestStop;
  Map<int, ShuttleStopModel>? fetchedStops;

  /// PROVIDERS
  UserDataProvider? userDataProvider;

  /// SERVICES
  final ShuttleService _shuttleService;
  final ShuttleRequestTraceObserver? _requestTraceObserver;
  Completer<void>? _fetchStopsCompleter;
  Future<bool>? _catalogRequest;
  final Map<int, Future<ShuttleArrivalResult>> _arrivalRequests = {};
  bool _refreshRequested = false;
  bool _refreshCatalogRequested = false;
  bool _refreshArrivalsRequested = false;
  List<int>? _lastSelectedStopIds;
  int _operationSequence = 0;
  ShuttleRequestContext? _activeRequestContext;

  Future<void> fetchStops(bool reloading, {bool refreshCatalog = true}) {
    final selectedStopIds = _normalizedSelectedStopIds(requireKnownStop: fetchedStops != null);
    if (!refreshCatalog &&
        fetchedStops != null &&
        _error == null &&
        listEquals(_lastSelectedStopIds, selectedStopIds)) {
      final activeContext = _activeRequestContext;
      _emit(
        ShuttleRequestTraceEvent(
          kind: activeContext == null
              ? ShuttleRequestTraceKind.providerRequestSkipped
              : ShuttleRequestTraceKind.providerRequestJoined,
          context: activeContext ?? _newRequestContext(refreshCatalog: false),
        ),
      );
      return _fetchStopsCompleter?.future ?? Future<void>.value();
    }
    _refreshRequested = true;
    _refreshCatalogRequested |= refreshCatalog;
    _refreshArrivalsRequested |= refreshCatalog;
    if (_fetchStopsCompleter != null) {
      _emit(
        ShuttleRequestTraceEvent(
          kind: ShuttleRequestTraceKind.providerRequestJoined,
          context: _activeRequestContext ?? _newRequestContext(refreshCatalog: refreshCatalog),
        ),
      );
      return _fetchStopsCompleter!.future;
    }

    final completer = Completer<void>();
    _fetchStopsCompleter = completer;
    _runFetchStops(reloading).then(completer.complete, onError: completer.completeError);
    return completer.future;
  }

  Future<void> _runFetchStops(bool reloading) async {
    _isLoading = true;
    try {
      do {
        _refreshRequested = false;
        final refreshCatalog = _refreshCatalogRequested;
        final refreshArrivals = _refreshArrivalsRequested;
        _refreshCatalogRequested = false;
        _refreshArrivalsRequested = false;
        _error = null;
        final requestContext = _newRequestContext(refreshCatalog: refreshCatalog);
        _activeRequestContext = requestContext;
        _emit(
          ShuttleRequestTraceEvent(kind: ShuttleRequestTraceKind.providerOperationStarted, context: requestContext),
        );
        notifyListeners();

        if (!await _ensureCatalog(refresh: refreshCatalog, requestContext: requestContext)) continue;

        _lastSelectedStopIds = _normalizedSelectedStopIds(requireKnownStop: true);
        await calculateClosestStop();
        await _reconcileArrivalInformation(refresh: refreshArrivals, requestContext: requestContext);
      } while (_refreshRequested || _refreshCatalogRequested || _refreshArrivalsRequested);
    } finally {
      _fetchStopsCompleter = null;
      _activeRequestContext = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _ensureCatalog({required bool refresh, required ShuttleRequestContext requestContext}) {
    if (!refresh && fetchedStops != null) {
      _emit(
        ShuttleRequestTraceEvent(
          kind: ShuttleRequestTraceKind.providerRequestSkipped,
          context: requestContext,
          endpoint: ShuttleRequestEndpoint.catalog,
        ),
      );
      return Future<bool>.value(true);
    }
    final activeRequest = _catalogRequest;
    if (activeRequest != null) {
      _emit(
        ShuttleRequestTraceEvent(
          kind: ShuttleRequestTraceKind.providerRequestJoined,
          context: requestContext,
          endpoint: ShuttleRequestEndpoint.catalog,
        ),
      );
      return activeRequest;
    }

    late final Future<bool> request;
    _emit(
      ShuttleRequestTraceEvent(
        kind: ShuttleRequestTraceKind.providerRequestStarted,
        context: requestContext,
        endpoint: ShuttleRequestEndpoint.catalog,
      ),
    );
    request = _fetchCatalog(requestContext).whenComplete(() {
      if (identical(_catalogRequest, request)) _catalogRequest = null;
    });
    _catalogRequest = request;
    return request;
  }

  Future<bool> _fetchCatalog(ShuttleRequestContext requestContext) async {
    if (!await _shuttleService.fetchData(requestContext: requestContext)) {
      _error = _shuttleService.error;
      return false;
    }

    final sortedStops = _shuttleService.data.toList()..sort((a, b) => a.name.compareTo(b.name));
    fetchedStops = {for (final stop in sortedStops) stop.id: stop};
    return true;
  }

  // TODO: unused function. If needed, rewrite w/ proper nullability - December 2025
  // List<ShuttleStopModel?> makeOrderedList(List<int?>? order) {
  //   if (order == null) {
  //     return [];
  //   }
  //
  //   ///create an empty list that will be returned
  //   List<ShuttleStopModel?> orderedListOfStops = [];
  //
  //   /// remove lots as we add them to the ordered list
  //   for (int? stopID in order) {
  //     orderedListOfStops.add(fetchedStops![stopID]);
  //   }
  //   return orderedListOfStops;
  // }

  void reorderStops(List<int?>? order) {
    /// update userProfileModel with selectedStops
    userDataProvider!.userProfileModel.selectedStops = _normalizeStopIds(
      order ?? const <int?>[],
      requireKnownStop: fetchedStops != null,
    );
    if (userDataProvider!.isLoggedIn) {
      /// post updated userProfileModel for logged-in users
      userDataProvider!.postUserProfile(userDataProvider!.userProfileModel);
    }
    notifyListeners();
    fetchStops(true, refreshCatalog: false);
  }

  Future<void> addStop(int stopID) async {
    final selectedStopIds = _normalizedSelectedStopIds(requireKnownStop: fetchedStops != null);
    final isKnownStop = fetchedStops?.containsKey(stopID) ?? false;
    if (!isKnownStop || selectedStopIds.contains(stopID) || selectedStopIds.length >= maxSelectedStops) return;

    userDataProvider!.userProfileModel.selectedStops = [...selectedStopIds, stopID];
    // update userprofilemodel locally and in database after a stop is added
    userDataProvider!.postUserProfile(userDataProvider!.userProfileModel);
    await fetchStops(true, refreshCatalog: false);
  }

  Future<void> removeStop(int? stopID) async {
    final selectedStopIds = _normalizedSelectedStopIds(requireKnownStop: fetchedStops != null);
    if (selectedStopIds.remove(stopID)) {
      userDataProvider!.userProfileModel.selectedStops = selectedStopIds;
      // update userprofilemodel locally and in database after a stop is removed
      userDataProvider!.postUserProfile(userDataProvider!.userProfileModel);
    }
    notifyListeners();
    await fetchStops(true, refreshCatalog: false);
  }

  Future<void> calculateClosestStop() async {
    // make sure we have users location before we do any calculations
    final bool hasCoordsObject = _userCoords != null;
    final bool hasLongitude = _userCoords?.lon != null;
    final bool hasLatitude = _userCoords?.lat != null;
    if (!hasCoordsObject || !hasLongitude || !hasLatitude) return;

    for (ShuttleStopModel shuttleStop in _shuttleService.data) {
      double stopLat = shuttleStop.lat, stopLong = shuttleStop.lon;
      final double distanceToStop = getHaversineDistance(_userCoords!.lat, _userCoords!.lon, stopLat, stopLong);
      final bool isCloser = distanceToStop < closestDistance;
      if (isCloser) {
        closestDistance = getHaversineDistance(_userCoords!.lat, _userCoords!.lon, stopLat, stopLong);
        _closestStop = shuttleStop;
      }
    }
    notifyListeners();
  }

  double getHaversineDistance(lat1, lon1, double lat2, double lon2) {
    var r = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1)!; // deg2rad below
    var dLon = deg2rad(lon2 - lon1)!;
    var a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)!) * Math.cos(deg2rad(lat2)!) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = r * c; // Distance in km
    return d;
  }

  Future<void> getArrivalInformation() async {
    final requestContext = _newRequestContext(refreshCatalog: false);
    _emit(ShuttleRequestTraceEvent(kind: ShuttleRequestTraceKind.providerOperationStarted, context: requestContext));
    await _reconcileArrivalInformation(refresh: true, requestContext: requestContext);
  }

  Future<void> _reconcileArrivalInformation({
    required bool refresh,
    required ShuttleRequestContext requestContext,
  }) async {
    final desiredStopIds = stopsToRender.map((stop) => stop.id).toSet();
    arrivalsToRender.removeWhere((stopId, _) => !desiredStopIds.contains(stopId));
    arrivalErrors.removeWhere((stopId, _) => !desiredStopIds.contains(stopId));

    for (final stopId in desiredStopIds) {
      if (!refresh && (arrivalsToRender.containsKey(stopId) || arrivalErrors.containsKey(stopId))) {
        _emit(
          ShuttleRequestTraceEvent(
            kind: ShuttleRequestTraceKind.providerRequestSkipped,
            context: requestContext,
            endpoint: ShuttleRequestEndpoint.arrivals,
            stopId: stopId.toString(),
          ),
        );
        continue;
      }
      if (!stopsToRender.any((stop) => stop.id == stopId)) {
        _emit(
          ShuttleRequestTraceEvent(
            kind: ShuttleRequestTraceKind.providerRequestSkipped,
            context: requestContext,
            endpoint: ShuttleRequestEndpoint.arrivals,
            stopId: stopId.toString(),
          ),
        );
        continue;
      }

      final result = await _sharedArrivalInformation(stopId, requestContext);
      if (stopsToRender.any((stop) => stop.id == stopId)) {
        arrivalsToRender[stopId] = result.arrivals;
        if (result.error == null) {
          arrivalErrors.remove(stopId);
        } else {
          arrivalErrors[stopId] = result.error!;
        }
      } else {
        arrivalErrors.remove(stopId);
        _emit(
          ShuttleRequestTraceEvent(
            kind: ShuttleRequestTraceKind.providerResultDiscarded,
            context: requestContext,
            endpoint: ShuttleRequestEndpoint.arrivals,
            stopId: stopId.toString(),
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<ShuttleArrivalResult> _sharedArrivalInformation(int stopId, ShuttleRequestContext requestContext) {
    final activeRequest = _arrivalRequests[stopId];
    if (activeRequest != null) {
      _emit(
        ShuttleRequestTraceEvent(
          kind: ShuttleRequestTraceKind.providerRequestJoined,
          context: requestContext,
          endpoint: ShuttleRequestEndpoint.arrivals,
          stopId: stopId.toString(),
        ),
      );
      return activeRequest;
    }

    late final Future<ShuttleArrivalResult> request;
    _emit(
      ShuttleRequestTraceEvent(
        kind: ShuttleRequestTraceKind.providerRequestStarted,
        context: requestContext,
        endpoint: ShuttleRequestEndpoint.arrivals,
        stopId: stopId.toString(),
      ),
    );
    request = fetchArrivalInformation(stopId, requestContext: requestContext).whenComplete(() {
      if (identical(_arrivalRequests[stopId], request)) _arrivalRequests.remove(stopId);
    });
    _arrivalRequests[stopId] = request;
    return request;
  }

  Future<ShuttleArrivalResult> fetchArrivalInformation(int stopID, {ShuttleRequestContext? requestContext}) async {
    final result = await _shuttleService.getArrivingInformation(stopID, requestContext: requestContext);
    final output = result.arrivals.toList();
    output.sort((a, b) => a.secondsToArrival.compareTo(b.secondsToArrival));
    return ShuttleArrivalResult(arrivals: output, error: result.error);
  }

  ShuttleRequestContext _newRequestContext({required bool refreshCatalog}) => ShuttleRequestContext(
    operationId: ++_operationSequence,
    trigger: refreshCatalog
        ? ShuttleRequestTrigger.manualReload
        : fetchedStops == null
        ? ShuttleRequestTrigger.startup
        : ShuttleRequestTrigger.selectionChange,
  );

  void _emit(ShuttleRequestTraceEvent event) => _requestTraceObserver?.call(event);

  /// SIMPLE SETTERS
  set userCoords(Coordinates value) {
    _userCoords = value;
  }

  double? deg2rad(deg) => deg * (Math.pi / 180);

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  ShuttleStopModel? get closestStop => _closestStop;
  List<ShuttleStopModel> get stopsToRender {
    if (fetchedStops == null) return <ShuttleStopModel>[];
    return _normalizedSelectedStopIds(
      requireKnownStop: true,
    ).map((stopId) => fetchedStops![stopId]!).toList(growable: false);
  }

  Map<int, ShuttleStopModel> get stopsNotSelected {
    if (fetchedStops == null) return <int, ShuttleStopModel>{};
    var output = new Map<int, ShuttleStopModel>.from(fetchedStops!);
    for (ShuttleStopModel? stop in stopsToRender) {
      output.remove(stop!.id);
    }
    return output;
  }

  List<int> _normalizedSelectedStopIds({required bool requireKnownStop}) {
    final selectedStopIds = userDataProvider?.userProfileModel.selectedStops ?? const <int?>[];
    return _normalizeStopIds(selectedStopIds, requireKnownStop: requireKnownStop);
  }

  List<int> _normalizeStopIds(Iterable<int?> selectedStopIds, {required bool requireKnownStop}) {
    final normalized = <int>[];
    final seen = <int>{};
    for (final stopId in selectedStopIds) {
      if (stopId == null || !seen.add(stopId)) continue;
      if (requireKnownStop && !(fetchedStops?.containsKey(stopId) ?? false)) continue;
      if (normalized.length == maxSelectedStops) break;
      normalized.add(stopId);
    }
    return normalized;
  }
}
