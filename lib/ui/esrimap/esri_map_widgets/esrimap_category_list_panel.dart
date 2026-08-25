/// ============================================================================
/// File: esrimap_category_list_panel.dart
/// Description: Draggable scrollable bottom sheet displaying all plotted POI
///              results for an active category search, sorted by distance.
/// ============================================================================

import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_search_category.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:campus_mobile_experimental/core/services/esri_map_services/esrimap_search_service.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_detail_slide_over.dart';
import 'package:flutter/material.dart';

/// Bottom sheet widget rendering plotted category search results in a list.
class EsriMapCategoryListPanel extends StatelessWidget {
  /// Controller managing draggable sheet height.
  final DraggableScrollableController controller;

  /// Active search category being displayed.
  final EsriSearchCategory? activeCategory;

  /// Unfiltered list of all results for this category.
  final List<MapSearchResult> allCategoryResults;

  /// Results currently within the visible map viewport.
  final List<MapSearchResult> viewportResults;

  /// User's current location coordinates for distance sorting, if available.
  final (double lat, double lng)? userLocation;

  /// Callback to clear search and close panel.
  final VoidCallback onClearSearch;

  /// Callback when "See all results" button is tapped.
  final VoidCallback onSeeAllResults;

  /// Callback when a item in the list is tapped.
  final void Function(MapSearchResult result) onSelectResult;

  /// Helper function mapping results to appropriate icon.
  final IconData Function(MapSearchResult result) iconForResult;

  /// Constructs an [EsriMapCategoryListPanel] instance.
  const EsriMapCategoryListPanel({
    Key? key,
    required this.controller,
    required this.activeCategory,
    required this.allCategoryResults,
    required this.viewportResults,
    required this.userLocation,
    required this.onClearSearch,
    required this.onSeeAllResults,
    required this.onSelectResult,
    required this.iconForResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = activeCategory?.label ?? 'Results';

    // Sort results by distance from user if position is available
    final results = List<MapSearchResult>.from(viewportResults);
    final hasUserLocation = userLocation != null;
    if (hasUserLocation) {
      results.sort(
        (a, b) => EsriMapSearchService.distanceMeters(
          userLocation!.$1,
          userLocation!.$2,
          a.latitude,
          a.longitude,
        ).compareTo(EsriMapSearchService.distanceMeters(userLocation!.$1, userLocation!.$2, b.latitude, b.longitude)),
      );
    }

    // Content-aware sizing calculation
    final initialSize = 0.45;
    final minSize = 0.15;
    final maxSize = 0.90;
    final snaps = <double>[minSize, initialSize, maxSize];

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: snaps,
      builder: (context, scrollController) {
        final isResultsEmpty = results.isEmpty;
        final headerTitle = isResultsEmpty ? '$label - None in view' : '$label - ${results.length} in view';
        final hasMoreTotalResults = allCategoryResults.length > results.length;

        return buildSlideOverContent(
          context: context,
          scrollController: scrollController,
          headerTitle: headerTitle,
          headerIcon: activeCategory?.icon ?? Icons.place,
          onClose: onClearSearch,
          onHeaderTap: () {
            if (controller.isAttached) {
              if (controller.size < 0.85) {
                controller.animateTo(maxSize, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
              } else {
                controller.animateTo(
                  initialSize,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            }
          },
          trailing: hasMoreTotalResults
              ? TextButton.icon(
                  icon: ExcludeSemantics(child: Icon(Icons.layers_outlined, size: 16, color: isDark ? Colors.white54 : Colors.grey[600])),
                  label: Text(
                    'See all ${allCategoryResults.length} results',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600]),
                  ),
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: onSeeAllResults,
                )
              : null,
          sliverBody: isResultsEmpty
              ? [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off, size: 32, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No $label in current view.\nPan the map to see results.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              : [
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final r = results[index];
                      final dist = hasUserLocation
                          ? EsriMapSearchService.distanceMeters(
                              userLocation!.$1,
                              userLocation!.$2,
                              r.latitude,
                              r.longitude,
                            )
                          : null;
                      final distFeet = dist != null ? dist * 3.28084 : null;
                      final distLabel = distFeet == null
                          ? null
                          : distFeet < 1000
                          ? '${distFeet.round()} ft away'
                          : '${(distFeet / 5280).toStringAsFixed(1)} mi away';
                      final isNotLastResult = index < results.length - 1;
                      return Column(
                        children: [
                          ListTile(
                            splashColor: Colors.transparent,
                            leading: ExcludeSemantics(
                              child: Icon(
                                iconForResult(r),
                                size: 20,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              r.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: distLabel != null
                                ? Text(distLabel, style: TextStyle(fontSize: 13, color: Colors.grey[500]))
                                : (r.subtitle.isNotEmpty
                                      ? Text(
                                          r.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                        )
                                      : null),
                            dense: true,
                            onTap: () => onSelectResult(r),
                          ),
                          if (isNotLastResult) const Divider(height: 1),
                        ],
                      );
                    }, childCount: results.length),
                  ),
                ],
        );
      },
    );
  }
}
