import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';

List<ArrivingShuttle> getArrivingShuttles(String str) {
  var shuttles = json.decode(str);
  List<ArrivingShuttle> arrivingShuttles = [];
  shuttles.forEach((shuttle) {
    arrivingShuttles.add(ArrivingShuttle.fromJson(shuttle));
  });
  return arrivingShuttles;
}

/// Default route color used when a OneBusAway route has no usable color.
/// Mirrors the "no arrivals found" color used by the Transit card UI.
const String oneBusAwayDefaultRouteColor = '#747678';

final RegExp _hexColorPattern = RegExp(r'^([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

/// Parses the envelope of a OneBusAway
/// `arrivals-and-departures-for-stop` response
/// (`{"code":200,"currentTime":...,"data":{"entry":{...},"references":{...}}}`)
/// into the existing [ArrivingShuttle] shape used by the Transit UI.
///
/// - [agencyId]: when provided, arrivals for routes outside that agency are
///   dropped. The campus feed serves multiple agencies (MTS, NCTD, UCSD) at
///   the same stops; the Transit feature only tracks the campus shuttle
///   agency, matching the legacy feed's behavior.
/// - [nowMs]: overrides the reference "now" used to compute arrival times
///   (the envelope's `currentTime` by default, device clock as fallback).
///
/// Arrivals without any usable arrival/departure time are skipped rather
/// than crashing (graceful degradation).
List<ArrivingShuttle> arrivingShuttlesFromOneBusAwayEnvelope(
  Map<String, dynamic> envelope, {
  String? agencyId,
  int? nowMs,
}) {
  final dynamic data = envelope['data'];
  if (data is! Map<String, dynamic>) return const <ArrivingShuttle>[];
  final dynamic entry = data['entry'];
  if (entry is! Map<String, dynamic>) return const <ArrivingShuttle>[];
  final int now = nowMs ?? (envelope['currentTime'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
  final Map<String, Map<String, dynamic>> routeReferences = _routeReferences(data);
  final List<ArrivingShuttle> shuttles = [];
  final dynamic arrivals = entry['arrivalsAndDepartures'];
  if (arrivals is! List) return const <ArrivingShuttle>[];
  for (final dynamic arrival in arrivals) {
    if (arrival is! Map<String, dynamic>) continue;
    final ArrivingShuttle? shuttle = ArrivingShuttle.fromOneBusAwayJson(
      arrival,
      routeReferences,
      now,
      agencyId: agencyId,
    );
    if (shuttle != null) shuttles.add(shuttle);
  }
  return shuttles;
}

Map<String, Map<String, dynamic>> _routeReferences(Map<String, dynamic> data) {
  final dynamic references = data['references'];
  final dynamic routes = references is Map<String, dynamic> ? references['routes'] : null;
  final Map<String, Map<String, dynamic>> routeById = <String, Map<String, dynamic>>{};
  if (routes is! List) return routeById;
  for (final dynamic route in routes) {
    if (route is! Map<String, dynamic>) continue;
    final String? id = _asString(route['id']);
    if (id != null && id.isNotEmpty) routeById[id] = route;
  }
  return routeById;
}

String? _asString(dynamic value) => value == null ? null : value.toString();

String? _firstNonEmpty(List<String?> candidates) {
  for (final String? candidate in candidates) {
    if (candidate != null && candidate.trim().isNotEmpty) return candidate;
  }
  return null;
}

/// Validates and canonicalizes a OneBusAway route color (e.g. `182b49`)
/// into the `#RRGGBB` hex string the Transit UI expects. Returns null when
/// the value is missing or not a valid hex color.
String? _normalizeHexColor(String? raw) {
  if (raw == null) return null;
  final String trimmed = raw.trim().replaceFirst('#', '');
  if (!_hexColorPattern.hasMatch(trimmed)) return null;
  return '#$trimmed';
}

class ArrivingShuttle {
  ArrivingShuttle({
    required this.routeId,
    required this.routeName,
    this.routeStopId,
    required this.routeColor,
    required this.secondsToArrival,
  });

  int routeId;
  String routeName;
  int? routeStopId; // unused, not sure if this is nullable or not
  String routeColor;
  int secondsToArrival;

  factory ArrivingShuttle.fromJson(Map<String, dynamic> json) => ArrivingShuttle(
    routeId: json["routeId"],
    routeName: json["routeName"],
    routeStopId: json["routeStopId"],
    routeColor: json["routeColor"],
    secondsToArrival: json["secondsToArrival"],
  );

  /// Maps a OneBusAway `arrivalsAndDepartures` entry onto the existing model
  /// shape. [routeReferences] holds the referenced routes keyed by their
  /// OneBusAway route id; [nowMs] is the reference time used to compute the
  /// seconds until arrival. Returns null when the entry cannot be mapped
  /// (missing route id, no usable time, or outside [agencyId]).
  static ArrivingShuttle? fromOneBusAwayJson(
    Map<String, dynamic> arrival,
    Map<String, Map<String, dynamic>> routeReferences,
    int nowMs, {
    String? agencyId,
  }) {
    final String routeId = _asString(arrival['routeId']) ?? '';
    if (routeId.isEmpty) return null;
    if (agencyId != null && agencyId.isNotEmpty && !routeId.startsWith('${agencyId}_')) return null;
    if (arrival['arrivalEnabled'] == false && arrival['departureEnabled'] == false) return null;

    final int? etaMs = _etaMilliseconds(arrival, nowMs);
    if (etaMs == null) return null;

    final Map<String, dynamic>? route = routeReferences[routeId];
    final String? stopId = _asString(arrival['stopId']);
    return ArrivingShuttle(
      routeId: oneBusAwayIdToInt(routeId),
      routeName: _routeName(arrival, route),
      routeStopId: stopId == null || stopId.isEmpty ? null : oneBusAwayIdToInt(stopId),
      routeColor: _normalizeHexColor(_asString(route?['color'])) ?? oneBusAwayDefaultRouteColor,
      secondsToArrival: etaMs < 0 ? 0 : etaMs ~/ 1000,
    );
  }

  /// The legacy feed exposed a single human-readable route name. OneBusAway
  /// splits this across several fields, so prefer the referenced route's
  /// long name (e.g. "Outside Loop"), then its short name, then the fields
  /// carried on the arrival itself, then the trip headsign.
  static String _routeName(Map<String, dynamic> arrival, Map<String, dynamic>? route) =>
      _firstNonEmpty([
        _asString(route?['longName']),
        _asString(route?['shortName']),
        _asString(arrival['routeShortName']),
        _asString(arrival['routeLongName']),
        _asString(arrival['tripHeadsign']),
      ]) ??
      'Route';

  /// Resolves the target epoch-milliseconds for the arrival, preferring
  /// real-time predictions over scheduled times and arrival times over
  /// departure times. Returns null when no usable time exists (the legacy
  /// equivalent of an arrival with no ETA).
  static int? _etaMilliseconds(Map<String, dynamic> arrival, int nowMs) {
    final bool predicted = arrival['predicted'] == true;
    final int predictedArrival = _asMillis(arrival['predictedArrivalTime']);
    final int scheduledArrival = _asMillis(arrival['scheduledArrivalTime']);
    final int predictedDeparture = _asMillis(arrival['predictedDepartureTime']);
    final int scheduledDeparture = _asMillis(arrival['scheduledDepartureTime']);

    int? targetMs;
    if (predicted && predictedArrival > 0) {
      targetMs = predictedArrival;
    } else if (scheduledArrival > 0) {
      targetMs = scheduledArrival;
    } else if (predicted && predictedDeparture > 0) {
      targetMs = predictedDeparture;
    } else if (scheduledDeparture > 0) {
      targetMs = scheduledDeparture;
    }
    if (targetMs == null) return null;
    return targetMs - nowMs;
  }

  static int _asMillis(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    "routeId": routeId,
    "routeName": routeName,
    "routeStopId": routeStopId,
    "routeColor": routeColor,
    "secondsToArrival": secondsToArrival,
  };
}
