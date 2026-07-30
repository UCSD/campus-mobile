/// ============================================================================
/// File: esrimap_suggestions_panel.dart
/// Description: Dropdown card panel presenting suggested category quick-search
///              chips and recent search history items.
/// ============================================================================

import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_search_category.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:flutter/material.dart';

class EsriMapSuggestionsPanel extends StatefulWidget {
  final List<EsriSearchCategory> categories;
  final List<MapSearchResult> recentSearches;
  final bool showRouteFields;
  final String? activeRouteField;
  final VoidCallback onSelectCurrentLocation;
  final void Function(EsriSearchCategory category) onSelectCategory;
  final void Function(MapSearchResult result) onSelectRecent;
  final void Function(int index) onRemoveRecent;
  final VoidCallback onClearRecent;

  const EsriMapSuggestionsPanel({
    Key? key,
    required this.categories,
    required this.recentSearches,
    required this.showRouteFields,
    required this.activeRouteField,
    required this.onSelectCurrentLocation,
    required this.onSelectCategory,
    required this.onSelectRecent,
    required this.onRemoveRecent,
    required this.onClearRecent,
  }) : super(key: key);

  @override
  State<EsriMapSuggestionsPanel> createState() => _EsriMapSuggestionsPanelState();
}

class _EsriMapSuggestionsPanelState extends State<EsriMapSuggestionsPanel> {
  bool _isHistoryExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.white;
    final isFromRouteFieldActive = widget.showRouteFields && widget.activeRouteField == 'from';
    final topPadding = isFromRouteFieldActive ? 0.0 : 12.0;
    final availableHeight = MediaQuery.sizeOf(context).height - MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: bgColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight * 0.55),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding, bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFromRouteFieldActive) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(
                    Icons.my_location,
                    size: 20,
                    color: isDark ? Colors.grey[400] : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: widget.onSelectCurrentLocation,
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
              if (widget.categories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Quick search',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final category in widget.categories) Expanded(child: _buildCategoryChip(context, category)),
                    ],
                  ),
                ),
              ],
              if (widget.recentSearches.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recently viewed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onClearRecent,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
                _buildRecentSearchesList(isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchesList(bool isDark) {
    final maxTotal = widget.recentSearches.length > 10 ? 10 : widget.recentSearches.length;
    final displayCount = _isHistoryExpanded ? maxTotal : (maxTotal > 2 ? 2 : maxTotal);
    
    // ListTile height is approximately 64. 5 items = 320.
    final double listHeight = _isHistoryExpanded && maxTotal > 5 ? (5 * 64.0) : (displayCount * 64.0);

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: listHeight),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: _isHistoryExpanded ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final recent = widget.recentSearches[index];
              final subtitle = recent.address.isNotEmpty ? recent.address : recent.subtitle;
              return SizedBox(
                height: 64,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 4),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    child: Icon(Icons.history, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  title: Text(
                    recent.name, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                  ),
                  subtitle: subtitle.isEmpty ? null : Text(
                    subtitle, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove ${recent.name} from recents',
                    onPressed: () => widget.onRemoveRecent(index),
                    icon: Icon(Icons.close, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  onTap: () => widget.onSelectRecent(recent),
                ),
              );
            },
          ),
        ),
        if (maxTotal > 2)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _isHistoryExpanded = !_isHistoryExpanded;
              });
            },
            child: Text(_isHistoryExpanded ? 'Show Less' : 'Show More'),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, EsriSearchCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Search ${category.label}',
      child: GestureDetector(
        onTap: () => widget.onSelectCategory(category),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
              child: Icon(category.icon, size: 22, color: Colors.black),
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

