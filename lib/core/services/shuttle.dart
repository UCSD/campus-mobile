import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/services/one_bus_away_client.dart';

/// Fetches campus transit data from the OneBusAway API (MA-685).
///
/// The service keeps the same public contract as the previous
/// shuttle-feed-backed implementation, so the provider and UI are unchanged:
/// - [fetchData] populates [data] with the available shuttle stops.
/// - [getArrivingInformation] returns upcoming arrivals for a stop id.
class ShuttleService {
  ShuttleService({OneBusAwayClient? client}) : _client = client ?? OneBusAwayClient();

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  List<ShuttleStopModel> _data = [];

  /// Maps the integer stop ids used by the UI to the raw OneBusAway stop ids
  /// (e.g. `10772` -> `UCSD_10772`) needed by the arrivals endpoint.
  final Map<int, String> _oneBusAwayStopIds = {};

  final OneBusAwayClient _client;

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data: all stops served by the campus shuttle agency
      final Map<String, dynamic> envelope = await _client.fetchStopsForAgency();

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
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<List<ArrivingShuttle>> getArrivingInformation(stopId) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data: arrivals for the raw OneBusAway stop id when known
      final String oneBusAwayStopId = _oneBusAwayStopIds[stopId] ?? stopId.toString();
      final Map<String, dynamic> envelope = await _client.fetchArrivalsAndDeparturesForStop(oneBusAwayStopId);

      /// parse data: keep only the campus shuttle agency's routes, matching
      /// the scope of the previous shuttle feed
      return arrivingShuttlesFromOneBusAwayEnvelope(envelope, agencyId: OneBusAwayClient.defaultAgencyId);
    } catch (e) {
      /// OneBusAway failures are wrapped in [OneBusAwayException] with
      /// sanitized messages, so this is safe to expose to the UI.
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<ShuttleStopModel> get data => _data;
}
