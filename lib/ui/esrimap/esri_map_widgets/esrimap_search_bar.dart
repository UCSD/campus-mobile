/// ============================================================================
/// File: esrimap_search_bar.dart
/// Description: Floating search input bar and route field selector widget,
///              including AI search trigger and dropdown results list.
/// ============================================================================

import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:flutter/material.dart';

/// Search input bar and route directions header widget.
class EsriMapSearchBar extends StatelessWidget {
  /// Map configuration object gating AI search features.
  final EsriMapConfig? config;

  /// Whether route input fields ('From' and 'To') are active.
  final bool showRouteFields;

  /// Main search input controller.
  final TextEditingController searchController;

  /// Main search focus node.
  final FocusNode focusNode;

  /// 'From' origin input controller.
  final TextEditingController fromController;

  /// 'From' origin focus node.
  final FocusNode fromFocusNode;

  /// 'To' destination input controller.
  final TextEditingController toController;

  /// 'To' destination focus node.
  final FocusNode toFocusNode;

  /// Whether search suggestions are currently visible.
  final bool showSuggestions;

  /// Whether search results are currently visible.
  final bool showResults;

  /// Whether a search operation is currently in progress.
  final bool isSearching;

  /// Search results returned from backend query.
  final List<MapSearchResult> searchResults;

  /// Live matching POI class values.
  final List<String> matchingPoiClasses;

  /// Callback when main search text is submitted or changed.
  final void Function(String query) onPerformSearch;

  /// Callback when a matching class category item is selected.
  final void Function(String classValue) onPerformClassSearch;

  /// Callback when a search result is selected.
  final void Function(MapSearchResult result) onSelectResult;

  /// Callback when search bar clear button is tapped.
  final VoidCallback onClearSearch;

  /// Callback when route calculation fields are cleared.
  final VoidCallback onClearRoute;

  /// Callback when 'From' and 'To' locations are swapped.
  final VoidCallback onSwapRouteFields;

  /// Callback when search input field is tapped.
  final VoidCallback onTapSearchField;

  /// Callback when 'From' input field focus/tap occurs.
  final VoidCallback onTapFromField;

  /// Callback when 'To' input field focus/tap occurs.
  final VoidCallback onTapToField;

  /// Callback when 'From' field text changes.
  final void Function(String text) onChangedFromField;

  /// Callback when 'To' field text changes.
  final void Function(String text) onChangedToField;

  /// Callback when 'From' field clear button is pressed.
  final VoidCallback onClearFromField;

  /// Callback when 'To' field clear button is pressed.
  final VoidCallback onClearToField;

  /// Callback when AI Search sheet trigger is pressed.
  final VoidCallback onOpenAiSearch;

  /// Helper function getting icon for POI class.
  final IconData Function(String classValue) iconForClass;

  /// Helper function getting label for POI class.
  final String Function(String classValue) labelForClass;

  /// Helper function getting icon for MapSearchResult.
  final IconData Function(MapSearchResult result) iconForResult;

  /// Constructs an [EsriMapSearchBar] instance.
  const EsriMapSearchBar({
    Key? key,
    required this.config,
    required this.showRouteFields,
    required this.searchController,
    required this.focusNode,
    required this.fromController,
    required this.fromFocusNode,
    required this.toController,
    required this.toFocusNode,
    required this.showSuggestions,
    required this.showResults,
    required this.isSearching,
    required this.searchResults,
    required this.matchingPoiClasses,
    required this.onPerformSearch,
    required this.onPerformClassSearch,
    required this.onSelectResult,
    required this.onClearSearch,
    required this.onClearRoute,
    required this.onSwapRouteFields,
    required this.onTapSearchField,
    required this.onTapFromField,
    required this.onTapToField,
    required this.onChangedFromField,
    required this.onChangedToField,
    required this.onClearFromField,
    required this.onClearToField,
    required this.onOpenAiSearch,
    required this.iconForClass,
    required this.labelForClass,
    required this.iconForResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSearchResults = isSearching || searchResults.isNotEmpty;
    final shouldShowResultsDivider = showResults && hasSearchResults;

    final isSearchNotEmpty = searchController.text.isNotEmpty;
    final hasClassMatches = matchingPoiClasses.isNotEmpty && isSearchNotEmpty && !showSuggestions;
    final shouldShowDropdown = showResults || hasClassMatches;

    return Column(
      children: [
        // Direction Route Fields ('From' + 'To')
        if (showRouteFields)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left route connection indicator dots
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle_outlined, size: 12, color: Colors.blue),
                        Container(width: 1.5, height: 24, color: isDark ? Colors.grey[600] : Colors.grey[300]),
                        const Icon(Icons.circle, size: 12, color: Colors.red),
                      ],
                    ),
                  ),
                  // Text input fields column
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 'From' field
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: fromController,
                                focusNode: fromFocusNode,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                  hintText: 'From',
                                  isDense: true,
                                ),
                                onTap: onTapFromField,
                                onChanged: onChangedFromField,
                              ),
                            ),
                            if (fromController.text.isNotEmpty)
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.close, size: 16, color: isDark ? Colors.white70 : Colors.grey[600]),
                                  onPressed: onClearFromField,
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 1, indent: 10, endIndent: 10),
                        // 'To' field
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: toController,
                                focusNode: toFocusNode,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                  hintText: 'To',
                                  isDense: true,
                                ),
                                onTap: onTapToField,
                                onChanged: onChangedToField,
                              ),
                            ),
                            if (toController.text.isNotEmpty)
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.close, size: 16, color: isDark ? Colors.white70 : Colors.grey[600]),
                                  onPressed: onClearToField,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Close route + Swap locations action buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                          onPressed: onClearRoute,
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.swap_vert, size: 20, color: isDark ? Colors.white70 : Colors.grey[600]),
                          onPressed: onSwapRouteFields,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          )
        else
          // Single Search Bar
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.grey[600]),
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onPerformSearch,
                    onChanged: (text) {
                      final isTextEmpty = text.isEmpty;
                      if (isTextEmpty) {
                        onClearSearch();
                      } else {
                        onPerformSearch(text);
                      }
                    },
                    onTap: onTapSearchField,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      hintText: 'Search buildings, places...',
                    ),
                  ),
                ),
                if (isSearchNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: onClearSearch),
                if (config?.features.aiSearch ?? false)
                  IconButton(
                    icon: Icon(
                      Icons.auto_awesome,
                      color: isDark ? Colors.amber[300] : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: onOpenAiSearch,
                  ),
              ],
            ),
          ),

        // Search Results Dropdown List
        if (shouldShowDropdown)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey[850] : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category matches
                  if (matchingPoiClasses.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Row(
                        children: [
                          Icon(Icons.category_outlined, size: 13, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            'CATEGORIES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...matchingPoiClasses.map(
                      (classValue) => ListTile(
                        splashColor: Colors.transparent,
                        leading: Icon(
                          iconForClass(classValue),
                          size: 20,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                        title: Text(labelForClass(classValue)),
                        subtitle: Text(
                          classValue,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                        ),
                        dense: true,
                        onTap: () => onPerformClassSearch(classValue),
                      ),
                    ),
                    if (shouldShowResultsDivider) const Divider(height: 1),
                  ],

                  // Building & POI results list
                  if (showResults)
                    isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : searchResults.isEmpty
                        ? (matchingPoiClasses.isEmpty
                              ? const Padding(padding: EdgeInsets.all(16), child: Text('No results found'))
                              : const SizedBox.shrink())
                        : ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: searchResults.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final result = searchResults[index];
                                return ListTile(
                                  splashColor: Colors.transparent,
                                  leading: Icon(iconForResult(result)),
                                  title: Text(result.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: result.subtitle.isNotEmpty
                                      ? Text(result.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)
                                      : null,
                                  dense: true,
                                  onTap: () => onSelectResult(result),
                                );
                              },
                            ),
                          ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
