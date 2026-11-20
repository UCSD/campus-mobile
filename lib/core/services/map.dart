import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapSearchService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<MapSearchModel> _results = [];

  Future<bool> fetchLocations(String location) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String? _response = await NetworkHelper.fetchData(
        dotenv.get('MAP_BASE_ENDPOINT') + '?query=' + location + '&region=0',
      );
      if (_response != 'null') {
        /// parse data
        final data = mapSearchModelFromJson(_response!);
        _results = data;
      } else {
        _results = [];
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Runs several keyword searches in parallel and merges the results,
  /// dropping POIs that appear under more than one keyword. Individual
  /// keyword failures are ignored so one empty category cannot blank
  /// the whole search.
  Future<bool> fetchLocationsByKeywords(List<String> keywords) async {
    _error = null;
    _isLoading = true;
    try {
      final batches = await Future.wait(keywords.map(_fetchKeywordResults));
      final valid = batches.whereType<List<MapSearchModel>>().expand((batch) => batch).toList();
      if (valid.isEmpty) {
        _results = [];
        return false;
      }
      _results = _mergeResults(valid);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Returns the parsed results for one keyword, or null when the query
  /// fails or the API answers with its non-list empty response ("{}").
  Future<List<MapSearchModel>?> _fetchKeywordResults(String keyword) async {
    try {
      final response = await NetworkHelper.fetchData(
        dotenv.get('MAP_BASE_ENDPOINT') + '?query=' + keyword + '&region=0',
      );
      if (response == null || response == 'null') {
        return null;
      }
      return mapSearchModelFromJson(response);
    } catch (e) {
      return null;
    }
  }

  List<MapSearchModel> _mergeResults(List<MapSearchModel> models) {
    final merged = <MapSearchModel>[];
    final seen = <String>{};
    for (final model in models) {
      /// Some food keywords match non-food POIs whose title merely contains
      /// a venue name, e.g. hydration stations and bathrooms; keep them out
      /// of the merged Food results.
      final bool isNonFood =
          model.title != null &&
          (model.title!.startsWith('Hydration Location -') || model.title!.startsWith('Single Occupancy Bathroom -'));
      if (isNonFood) {
        continue;
      }
      final key = model.mkrMarkerid?.toString() ?? '${model.title}|${model.mkrLat}|${model.mkrLong}';
      if (seen.add(key)) {
        merged.add(model);
      }
    }
    return merged;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  List<MapSearchModel> get results => _results;
}
