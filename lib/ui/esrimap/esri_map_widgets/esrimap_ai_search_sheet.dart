/// ============================================================================
/// File: esrimap_ai_search_sheet.dart
/// Description: Modal bottom sheet widget enabling AI natural language map queries
///              (e.g., "coffee spots near Geisel Library").
/// ============================================================================

import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_ai_search_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum _AiSearchState { idle, loading, results, error }

/// Modal bottom sheet widget for AI map search.
class EsriAiSearchSheet extends StatefulWidget {
  /// Optional current user latitude coordinate.
  final double? userLat;

  /// Optional current user longitude coordinate.
  final double? userLon;

  /// Callback when a location result is selected.
  final void Function(AiSearchResult result) onLocationSelected;

  /// Callback when a multi-stop route is requested.
  final void Function(List<AiSearchResult> stops) onRouteRequested;

  /// Constructs an [EsriAiSearchSheet] instance.
  const EsriAiSearchSheet({
    Key? key,
    this.userLat,
    this.userLon,
    required this.onLocationSelected,
    required this.onRouteRequested,
  }) : super(key: key);

  @override
  State<EsriAiSearchSheet> createState() => _EsriAiSearchSheetState();
}

class _EsriAiSearchSheetState extends State<EsriAiSearchSheet> {
  final _controller = TextEditingController();
  _AiSearchState _state = _AiSearchState.idle;
  AiSearchResponse? _response;

  /// Base API URL endpoint.
  static const String BASE_URL = 'https://appzxi70zi.execute-api.us-west-2.amazonaws.com/test/ArcGIS-Map';

  Future<void> _submit() async {
    final query = _controller.text.trim();
    final isQueryEmpty = query.isEmpty;
    if (isQueryEmpty) return;

    setState(() {
      _state = _AiSearchState.loading;
      _response = null;
    });

    try {
      final body = <String, dynamic>{'query': query};
      final hasUserLat = widget.userLat != null;
      final hasUserLon = widget.userLon != null;
      if (hasUserLat) body['lat'] = widget.userLat;
      if (hasUserLon) body['lon'] = widget.userLon;

      final res = await http.post(
        Uri.parse('$BASE_URL/ai-search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final isResNotOk = res.statusCode != 200;
      if (isResNotOk) throw Exception('Request failed: ${res.statusCode}');

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      setState(() {
        _response = AiSearchResponse.fromJson(data);
        _state = _AiSearchState.results;
      });
    } catch (e) {
      debugPrint('AI search error: $e');
      setState(() {
        _state = _AiSearchState.error;
      });
    }
  }

  IconData _iconForSubtitle(String subtitle) {
    final s = subtitle.toLowerCase();
    final isDining = s.contains('dining') || s.contains('food') || s.contains('coffee') || s.contains('cafe');
    if (isDining) return Icons.restaurant;
    final isLibrary = s.contains('library') || s.contains('academic');
    if (isLibrary) return Icons.menu_book;
    final isParking = s.contains('parking');
    if (isParking) return Icons.local_parking;
    final isRec = s.contains('recreation') || s.contains('gym') || s.contains('fitness');
    if (isRec) return Icons.fitness_center;
    final isTransit = s.contains('transit') || s.contains('shuttle');
    if (isTransit) return Icons.directions_bus;
    return Icons.place;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final accent = Theme.of(context).colorScheme.primary;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    final isResultsState = _state == _AiSearchState.results;
    final hasResponse = _response != null;
    final hasResults = isResultsState && hasResponse;
    final isLoading = _state == _AiSearchState.loading;
    final isError = _state == _AiSearchState.error;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  'Ask the Map',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                ),
              ],
            ),
          ),

          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'e.g. "good lunch spots near Price Center"',
                      hintStyle: TextStyle(color: subtitleColor, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Results section
          if (hasResults) ...[
            if (_response!.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(_response!.message, style: TextStyle(fontSize: 13, color: subtitleColor)),
              ),

            if (_response!.results.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'No results found. Try a different query.',
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
              ),

            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _response!.results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, indent: 56, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                itemBuilder: (context, i) {
                  final r = _response!.results[i];
                  final hasDistance = r.distanceFormatted != null;
                  final subtitleStr = hasDistance ? '${r.subtitle} · ${r.distanceFormatted}' : r.subtitle;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accent.withValues(alpha: 0.12),
                      child: Icon(_iconForSubtitle(r.subtitle), color: accent, size: 18),
                    ),
                    title: Text(
                      r.name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
                    ),
                    subtitle: Text(subtitleStr, style: TextStyle(fontSize: 12, color: subtitleColor)),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onLocationSelected(r);
                    },
                  );
                },
              ),
            ),

            // Multi-stop route button
            if (_response!.routeStopNames != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.directions),
                    label: Text('Route through ${_response!.routeStopNames!.length} stops'),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onRouteRequested(_response!.results);
                    },
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 16),
          ],

          if (isError)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Something went wrong. Please try again.',
                style: TextStyle(fontSize: 13, color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}
