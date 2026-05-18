import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'esrimap_config.dart';

class AiSearchResult {
  final String name;
  final String subtitle;
  final String address;
  final double latitude;
  final double longitude;
  final int? distanceFeet;
  final String? distanceFormatted;

  const AiSearchResult({
    required this.name,
    required this.subtitle,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceFeet,
    this.distanceFormatted,
  });

  factory AiSearchResult.fromJson(Map<String, dynamic> j) => AiSearchResult(
        name: j['name'] as String,
        subtitle: j['subtitle'] as String? ?? '',
        address: j['address'] as String? ?? '',
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        distanceFeet: j['distanceFeet'] as int?,
        distanceFormatted: j['distanceFormatted'] as String?,
      );
}

class AiSearchRouteStop {
  final double lat;
  final double lon;
  const AiSearchRouteStop({required this.lat, required this.lon});
  factory AiSearchRouteStop.fromJson(Map<String, dynamic> j) =>
      AiSearchRouteStop(lat: (j['lat'] as num).toDouble(), lon: (j['lon'] as num).toDouble());
}

class AiSearchResponse {
  final String message;
  final List<AiSearchResult> results;
  final List<String>? routeStopNames;
  final List<AiSearchRouteStop>? routeStopCoords;

  const AiSearchResponse({
    required this.message,
    required this.results,
    this.routeStopNames,
    this.routeStopCoords,
  });

  factory AiSearchResponse.fromJson(Map<String, dynamic> j) {
    List<String>? stopNames;
    List<AiSearchRouteStop>? stopCoords;
    final route = j['suggestedRoute'];
    if (route != null) {
      stopNames = (route['stops'] as List).cast<String>();
      stopCoords = (route['stopCoords'] as List)
          .map((s) => AiSearchRouteStop.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    return AiSearchResponse(
      message: j['message'] as String,
      results: (j['results'] as List)
          .map((r) => AiSearchResult.fromJson(r as Map<String, dynamic>))
          .toList(),
      routeStopNames: stopNames,
      routeStopCoords: stopCoords,
    );
  }
}

enum _AiSearchState { idle, loading, results, error }

class EsriAiSearchSheet extends StatefulWidget {
  final double? userLat;
  final double? userLon;
  final void Function(AiSearchResult result) onLocationSelected;
  final void Function(List<AiSearchResult> stops) onRouteRequested;

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
  String? _errorMessage;

  static const _baseUrl =
      'https://appzxi70zi.execute-api.us-west-2.amazonaws.com/test/ArcGIS-Map';

  Future<void> _submit() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _state = _AiSearchState.loading;
      _response = null;
      _errorMessage = null;
    });
    try {
      final body = <String, dynamic>{'query': query};
      if (widget.userLat != null) body['lat'] = widget.userLat;
      if (widget.userLon != null) body['lon'] = widget.userLon;

      final res = await http.post(
        Uri.parse('$_baseUrl/ai-search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode != 200) throw Exception('Request failed: ${res.statusCode}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      setState(() {
        _response = AiSearchResponse.fromJson(data);
        _state = _AiSearchState.results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _state = _AiSearchState.error;
      });
    }
  }

  IconData _iconForSubtitle(String subtitle) {
    final s = subtitle.toLowerCase();
    if (s.contains('dining') || s.contains('food') || s.contains('coffee') || s.contains('cafe')) {
      return Icons.restaurant;
    }
    if (s.contains('library') || s.contains('academic')) return Icons.menu_book;
    if (s.contains('parking')) return Icons.local_parking;
    if (s.contains('recreation') || s.contains('gym') || s.contains('fitness')) return Icons.fitness_center;
    if (s.contains('transit') || s.contains('shuttle')) return Icons.directions_bus;
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
          // Handle
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
                Text('Ask the Map',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _state == _AiSearchState.loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _state == _AiSearchState.loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Results
          if (_state == _AiSearchState.results && _response != null) ...[
            if (_response!.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(_response!.message,
                    style: TextStyle(fontSize: 13, color: subtitleColor)),
              ),

            if (_response!.results.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('No results found. Try a different query.',
                    style: TextStyle(fontSize: 13, color: subtitleColor)),
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
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accent.withOpacity(0.12),
                      child: Icon(_iconForSubtitle(r.subtitle), color: accent, size: 18),
                    ),
                    title: Text(r.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                    subtitle: Text(r.distanceFormatted != null ? '${r.subtitle} · ${r.distanceFormatted}' : r.subtitle,
                        style: TextStyle(fontSize: 12, color: subtitleColor)),
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

          if (_state == _AiSearchState.error)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Something went wrong. Please try again.',
                  style: TextStyle(fontSize: 13, color: Colors.redAccent)),
            ),
        ],
      ),
    );
  }
}