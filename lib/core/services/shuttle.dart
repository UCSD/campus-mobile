import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/services/one_bus_away_client.dart';
import 'package:campus_mobile_experimental/core/services/shuttle_request_trace.dart';

/// Fetches campus transit data from the OneBusAway API (MA-685).
///
/// Catalog failures remain available through [error]. Arrival failures are
/// returned with their stop's [ShuttleArrivalResult] instead of shared state:
/// - [fetchData] populates [data] with the available shuttle stops.
/// - [getArrivingInformation] returns arrivals and any stop-specific error
///   together.
class ShuttleArrivalResult {
  const ShuttleArrivalResult({required this.arrivals, this.error});

  final List<ArrivingShuttle> arrivals;
  final String? error;
}

class ShuttleService {
  ShuttleService({OneBusAwayClient? client, ShuttleRequestTraceObserver? requestTraceObserver})
    : _client = client ?? OneBusAwayClient(requestTraceObserver: requestTraceObserver);

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _catalogError;

  /// MODELS
  List<ShuttleStopModel> _data = [];

  /// Maps the integer stop ids used by the UI to the raw OneBusAway stop ids
  /// (e.g. `10772` -> `UCSD_10772`) needed by the arrivals endpoint.
  final Map<int, String> _oneBusAwayStopIds = {};

  final OneBusAwayClient _client;

  Future<bool> fetchData({ShuttleRequestContext? requestContext}) async {
    _catalogError = null;
    _isLoading = true;
    try {
      /// fetch data: all stops served by the campus shuttle agency
      final Map<String, dynamic> envelope = await _client.fetchStopsForAgency(requestContext: requestContext);
      // print('\x1B[32mstops-for-agency response:\n${const JsonEncoder.withIndent('  ').convert(envelope)}\x1B[0m');

      /// parse data
      _data = shuttleStopsFromOneBusAwayEnvelope(envelope);
      _oneBusAwayStopIds.clear();
      for (final ShuttleStopModel stop in _data) {
        final String? oneBusAwayId = stop.oneBusAwayId;
        if (oneBusAwayId != null) _oneBusAwayStopIds[stop.id] = oneBusAwayId;
      }
      return true;
    } catch (e) {
      /// OneBusAway failures are wrapped in [OneBusAwayException] with
      /// sanitized messages, so this is safe to expose to the UI.
      _catalogError = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<ShuttleArrivalResult> getArrivingInformation(stopId, {ShuttleRequestContext? requestContext}) async {
    _isLoading = true;
    final String oneBusAwayStopId = _oneBusAwayStopIds[stopId] ?? stopId.toString();
    try {
      /// fetch data: arrivals for the raw OneBusAway stop id when known
      final Map<String, dynamic> envelope = await _client.fetchArrivalsAndDeparturesForStop(
        oneBusAwayStopId,
        requestContext: requestContext,
      );
      // print('\x1B[32marrivals-and-departures-for-stop ($oneBusAwayStopId) response:\n${const JsonEncoder.withIndent('  ').convert(envelope)}\x1B[0m',);

      /// parse data: keep only the campus shuttle agency's routes, matching
      /// the scope of the previous shuttle feed
      return ShuttleArrivalResult(
        arrivals: arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: OneBusAwayClient.defaultAgencyId),
      );
    } catch (e) {
      /// OneBusAway failures are wrapped in [OneBusAwayException] with
      /// sanitized messages, so this is safe to expose to the UI.
      return ShuttleArrivalResult(arrivals: const [], error: e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _catalogError;
  get lastUpdated => _lastUpdated;
  List<ShuttleStopModel> get data => _data;
}
