import 'dart:async';
import 'dart:math' as Math;
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/shuttle.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

class ShuttleDataProvider extends ChangeNotifier {
  ShuttleDataProvider({ShuttleService? shuttleService}) : _shuttleService = shuttleService ?? ShuttleService();

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
  Completer<void>? _fetchStopsCompleter;
  bool _refreshRequested = false;
  bool _refreshCatalogRequested = false;
  List<int>? _lastSelectedStopIds;
  double? _lastLatitude;
  double? _lastLongitude;

  Future<void> fetchStops(bool reloading, {bool refreshCatalog = true}) {
    final selectedStopIds = _normalizedSelectedStopIds(requireKnownStop: fetchedStops != null);
    if (!refreshCatalog &&
        fetchedStops != null &&
        _error == null &&
        listEquals(_lastSelectedStopIds, selectedStopIds) &&
        _lastLatitude == _userCoords?.lat &&
        _lastLongitude == _userCoords?.lon) {
      return _fetchStopsCompleter?.future ?? Future<void>.value();
    }
    _refreshRequested = true;
    _refreshCatalogRequested |= refreshCatalog;
    if (_fetchStopsCompleter != null) return _fetchStopsCompleter!.future;

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
        final shouldFetchCatalog = _refreshCatalogRequested || fetchedStops == null;
        _refreshCatalogRequested = false;
        _error = null;
        arrivalErrors.clear();
        _lastSelectedStopIds = _normalizedSelectedStopIds(requireKnownStop: fetchedStops != null);
        _lastLatitude = _userCoords?.lat;
        _lastLongitude = _userCoords?.lon;
        notifyListeners();

        if (!shouldFetchCatalog || await _shuttleService.fetchData()) {
          final sortedStops = _shuttleService.data.toList()..sort((a, b) => a.name.compareTo(b.name));
          fetchedStops = {for (final stop in sortedStops) stop.id: stop};
          _lastSelectedStopIds = _normalizedSelectedStopIds(requireKnownStop: true);

          if (userDataProvider != null && !reloading) reorderStops(userDataProvider!.userProfileModel.selectedStops);

          await calculateClosestStop();
          await getArrivalInformation();
        } else {
          _error = _shuttleService.error;
        }
      } while (_refreshRequested);
    } finally {
      _fetchStopsCompleter = null;
      _isLoading = false;
      notifyListeners();
    }
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
  }

  Future<void> addStop(int stopID) async {
    final selectedStopIds = _normalizedSelectedStopIds(requireKnownStop: fetchedStops != null);
    final isKnownStop = fetchedStops?.containsKey(stopID) ?? false;
    if (!isKnownStop || selectedStopIds.contains(stopID) || selectedStopIds.length >= maxSelectedStops) return;

    userDataProvider!.userProfileModel.selectedStops = [...selectedStopIds, stopID];
    // update userprofilemodel locally and in database after a stop is added
    userDataProvider!.postUserProfile(userDataProvider!.userProfileModel);
    arrivalsToRender[stopID] = await fetchArrivalInformation(stopID);
    notifyListeners();
  }

  Future<void> removeStop(int? stopID) async {
    final selectedStopIds = _normalizedSelectedStopIds(requireKnownStop: fetchedStops != null);
    if (selectedStopIds.remove(stopID)) {
      userDataProvider!.userProfileModel.selectedStops = selectedStopIds;
      // update userprofilemodel locally and in database after a stop is removed
      userDataProvider!.postUserProfile(userDataProvider!.userProfileModel);
    }
    notifyListeners();
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
    final Set<int> stopIds = {if (_closestStop != null) _closestStop!.id, ...stopsToRender.map((stop) => stop.id)};
    for (final int stopId in stopIds) {
      arrivalsToRender[stopId] = await fetchArrivalInformation(stopId);
    }
    notifyListeners();
  }

  Future<List<ArrivingShuttle>> fetchArrivalInformation(int stopID) async {
    final List<ArrivingShuttle> output = (await _shuttleService.getArrivingInformation(stopID)).toList();
    final String? arrivalError = _shuttleService.error;
    if (arrivalError == null) {
      arrivalErrors.remove(stopID);
    } else {
      arrivalErrors[stopID] = arrivalError;
    }
    output.sort((a, b) => a.secondsToArrival.compareTo(b.secondsToArrival));
    return output;
  }

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
