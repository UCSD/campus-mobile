/// ============================================================================
/// File: search_prefetch_cache.dart
/// Description: Single-slot background prefetch record for the Esri map search
///              field. Keeps submitted queries warm without touching UI state.
/// ============================================================================

import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:flutter/foundation.dart';

/// Holds at most one background fetch for the map search field.
///
/// The record is created synchronously when a prefetch starts, so the commit
/// path can tell whether a query is pending, ready, or failed without racing a
/// completing future.
class SearchPrefetchCache {
  PrefetchedSearch? _current;

  /// Starts a background fetch for [query], replacing the current record.
  void start(String query, Future<List<MapSearchResult>> pending) {
    final record = PrefetchedSearch(query, pending);
    _current = record;
    pending.then<void>(
      (results) => record.result = results,
      onError: (Object error, StackTrace stack) {
        record.failed = true;
        debugPrint('Search prefetch error: $error');
      },
    );
  }

  /// Returns the record for [query], or null when the query differs.
  PrefetchedSearch? lookup(String query) => _current?.query == query ? _current : null;

  /// Drops the record. An in-flight request still completes into an orphan.
  void clear() => _current = null;
}

/// One prefetch attempt. [result] is set when [pending] succeeds.
class PrefetchedSearch {
  PrefetchedSearch(this.query, this.pending);

  /// Trimmed query text this record belongs to.
  final String query;

  /// In-flight fetch shared with the commit path.
  final Future<List<MapSearchResult>> pending;

  /// Completed results, or null while pending or after a failure.
  List<MapSearchResult>? result;

  /// Whether [pending] completed with an error.
  bool failed = false;
}
