/// ============================================================================
/// File: esrimap_suggestions_panel.dart
/// Description: Dropdown card panel presenting suggested category quick-search
///              chips and recent search history items.
/// ============================================================================

import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_search_category.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:flutter/material.dart';

/// Suggestions panel widget rendered below the search bar when focused.
class EsriMapSuggestionsPanel extends StatelessWidget {
  /// List of category items to display as icon chips.
  final List<EsriSearchCategory> categories;

  /// List of recently viewed search results.
  final List<MapSearchResult> recentSearches;

  /// Whether route directions fields are currently active.
  final bool showRouteFields;

  /// Which route field is active ('from' or 'to').
  final String? activeRouteField;

  /// Callback when "Current Location" option is tapped in routing mode.
  final VoidCallback onSelectCurrentLocation;

  /// Callback when a category chip is selected.
  final void Function(EsriSearchCategory category) onSelectCategory;

  /// Callback when a recent search item is tapped.
  final void Function(MapSearchResult result) onSelectRecent;

  /// Callback when the clear 'X' button on a recent search item is tapped.
  final void Function(int index) onRemoveRecent;

  /// Callback when all recent searches are cleared.
  final VoidCallback onClearRecent;

  /// Constructs an [EsriMapSuggestionsPanel] instance.
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.white;
    final isFromRouteFieldActive = showRouteFields && activeRouteField == 'from';
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
                  onTap: onSelectCurrentLocation,
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
              if (categories.isNotEmpty) ...[
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
                      for (final category in categories) Expanded(child: _buildCategoryChip(context, category)),
                    ],
                  ),
                ),
              ],
              if (recentSearches.isNotEmpty) ...[
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
                      TextButton(onPressed: onClearRecent, child: const Text('Clear')),
                    ],
                  ),
                ),
                ...List.generate(recentSearches.length, (index) {
                  final recent = recentSearches[index];
                  final subtitle = recent.address.isNotEmpty ? recent.address : recent.subtitle;
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 4),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      child: Icon(Icons.history, size: 19, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    title: Text(recent.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      tooltip: 'Remove ${recent.name} from recents',
                      onPressed: () => onRemoveRecent(index),
                      icon: Icon(Icons.close, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    onTap: () => onSelectRecent(recent),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single quick-search category icon.
  Widget _buildCategoryChip(BuildContext context, EsriSearchCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Search ${category.label}',
      child: GestureDetector(
        onTap: () => onSelectCategory(category),
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
