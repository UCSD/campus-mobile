import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/services/events.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EventsDataProvider extends ChangeNotifier {
  /// STATES
  bool _isLoading = false;
  String? _refreshingCardId;
  bool _modelInitialized = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  List<EventModel> _eventsModels = [];

  /// SERVICES
  var _eventsService = EventsService();

  /// The single apply step for both the cache path and the network path.
  /// An empty list is a valid applied model.
  void _applyModels(List<EventModel> models) {
    _eventsModels = models;
    _modelInitialized = true;

    /// Re-derive the empty-state text on every apply; this also clears
    /// whatever error an earlier state left behind.
    _error = _eventsModels.isEmpty ? 'No events found.' : null;
  }

  Future<void> loadFromCache() async {
    print('======loadFromCache======');
    if (_modelInitialized) return;

    try {
      final box = await Hive.openBox('EventsModel');
      final cachedJson = box.get('EventsModel') as String?;

      print("cachedJson: $cachedJson");

      if (cachedJson == null || cachedJson.isEmpty) return;

      final cachedModels = eventModelFromJson(cachedJson);
      /// A fetch may have applied newer data while the box was opening;
      /// never let stale cache overwrite it.
      if (_modelInitialized) return;

      print("====applying cache====");
      _applyModels(cachedModels);
      notifyListeners();
    } catch (e) {
      /// A cache miss or unreadable cache is not an error;
      /// the network fetch remains the source of truth.
      print('Failed to load events from cache: $e');
    }
  }

  Future<void> fetchEvents() async {
    if (_isLoading) return;

    _isLoading = true;

    /// Only clear a visible error when nothing is displayed behind it.
    if (!_modelInitialized) _error = null;
    notifyListeners();

    String? cacheJson;
    try {
      if (await _eventsService.fetchData()) {
        final fetchedModels = _eventsService.eventsModels!;
        final newJson = eventModelToJson(fetchedModels);

        /// Skip the redundant apply and cache write if the fresh data
        /// matches what is already displayed.
        if (_modelInitialized && newJson == eventModelToJson(_eventsModels)) {
          return;
        }

        /// Show fresh data immediately; persist to cache afterwards.
        /// An empty fetch must not clobber cached events or block the
        /// cache from applying afterwards.
        if (fetchedModels.isNotEmpty) {
          _applyModels(fetchedModels);
          _lastUpdated = DateTime.now();
          cacheJson = newJson;
        } else if (!_modelInitialized) {
          _error = 'No events found.';
        }
      } else {
        /// Keep whatever is displayed; only surface an error when the card
        /// has nothing to show.
        if (!_modelInitialized) _error = _eventsService.error;
      }
    } catch (e) {
      /// Never let an unexpected failure wedge the card in a loading state.
      if (!_modelInitialized) _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    /// A failed cache write must not discard the fresh UI update.
    if (cacheJson != null) {
      try {
        final box = await Hive.openBox('EventsModel');
        await box.put('EventsModel', cacheJson);
        print('========wrote to cache=========');
      } catch (_) {}
    }
  }

  Future<void> reload(String cardId) async {
    if (_isLoading || _refreshingCardId != null) return;

    _refreshingCardId = cardId;
    try {
      await fetchEvents();
    } finally {
      _refreshingCardId = null;
      notifyListeners();
    }
  }

  ///SIMPLE GETTERS
  get isLoading => _isLoading;
  bool isRefreshing(String cardId) => _refreshingCardId == cardId;
  bool get hasData => _modelInitialized;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<EventModel> get eventsModels => _eventsModels;
}
