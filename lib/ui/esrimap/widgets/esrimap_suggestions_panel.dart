/// ============================================================================
/// File: esrimap_suggestions_panel.dart
/// Description: Dropdown card panel presenting suggested category quick-search
///              chips and recent search history items.
/// ============================================================================

import 'package:campus_mobile_experimental/ui/esrimap/models/esrimap_search_category.dart';
import 'package:campus_mobile_experimental/ui/esrimap/models/map_search_result.dart';
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.white;
    final isFromRouteFieldActive = showRouteFields && activeRouteField == 'from';
    final topPadding = isFromRouteFieldActive ? 0.0 : 12.0;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Current Location" shortcut option when 'From' field is active
            if (isFromRouteFieldActive) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelectCurrentLocation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 20,
                        color: isDark ? Colors.grey[500] : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),
            ],

            // Suggested categories section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Suggested',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category circular icon chips row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: categories.map((cat) => _buildCategoryChip(context, cat)).toList(),
              ),
            ),

            // Recent searches history list
            if (recentSearches.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recently viewed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(recentSearches.length, (index) {
                final recent = recentSearches[index];
                return ListTile(
                  splashColor: Colors.transparent,
                  dense: true,
                  leading: Icon(Icons.history, size: 20, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  title: Text(recent.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: GestureDetector(
                    onTap: () => onRemoveRecent(index),
                    child: Icon(Icons.close, size: 16, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  ),
                  onTap: () => onSelectRecent(recent),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a single circular category quick-search chip.
  Widget _buildCategoryChip(BuildContext context, EsriSearchCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onSelectCategory(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
            child: Icon(category.icon, size: 24, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(category.label, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }
}
