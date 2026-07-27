/// ============================================================================
/// File: esrimap_detail_slide_over.dart
/// Description: Draggable slide-over sheet displaying building/POI details,
///              travel time, navigation buttons, and turn-by-turn directions.
/// ============================================================================

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/ui/esrimap/models/map_search_result.dart';
import 'package:flutter/material.dart';

/// Persistent header delegate for pinned slide-over bottom sheet headers.
class SlideOverHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Header widget content.
  final Widget child;

  /// Fixed height of the persistent header.
  final double height;

  /// Background color matching dark/light mode.
  final Color backgroundColor;

  /// Constructs a [SlideOverHeaderDelegate] instance.
  SlideOverHeaderDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isTopPositioned = shrinkOffset == 0;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: isTopPositioned ? const BorderRadius.vertical(top: Radius.circular(16)) : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SlideOverHeaderDelegate oldDelegate) =>
      child != oldDelegate.child || height != oldDelegate.height || backgroundColor != oldDelegate.backgroundColor;
}

/// Helper function building a consistent DraggableScrollableSheet template with a pinned header.
Widget buildSlideOverContent({
  required BuildContext context,
  required ScrollController scrollController,
  required String headerTitle,
  IconData? headerIcon,
  required VoidCallback onClose,
  Widget? trailing,
  required List<Widget> sliverBody,
  double headerHeight = 80.0,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? Colors.grey[900]! : Colors.white;
  final hasHeaderIcon = headerIcon != null;
  final hasTrailing = trailing != null;

  return Material(
    elevation: 8,
    color: bgColor,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    clipBehavior: Clip.antiAlias,
    child: CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SlideOverHeaderDelegate(
            height: headerHeight,
            backgroundColor: bgColor,
            child: Column(
              children: [
                // Drag handle bar
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header title row with icon & close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Row(
                    children: [
                      if (hasHeaderIcon) ...[
                        Icon(headerIcon, size: 18, color: isDark ? Colors.white70 : Colors.grey[700]),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          headerTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                        ),
                      ),
                      if (hasTrailing) trailing,
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                          child: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider below header
        const SliverToBoxAdapter(child: Divider(height: 1)),
        ...sliverBody,
      ],
    ),
  );
}

/// Slide-over drawer widget presenting location details, route options, and maneuvers.
class EsriMapDetailSlideOver extends StatelessWidget {
  /// Controller for managing sheet drag height.
  final DraggableScrollableController controller;

  /// Selected location search result.
  final MapSearchResult result;

  /// Icon visual representation for the location.
  final IconData resultIcon;

  /// Whether routing or direction mode is active.
  final bool isRoutingMode;

  /// Whether a calculated route is currently active.
  final bool hasRoute;

  /// Whether route calculation failed.
  final bool routeFailed;

  /// Selected travel mode (e.g. 'Walking', 'Accessible').
  final String travelMode;

  /// Estimated route travel duration in minutes.
  final double routeTravelTimeMinutes;

  /// Turn-by-turn direction maneuvers.
  final List<DirectionManeuver> routeManeuvers;

  /// Origin coordinates for route navigation, if custom.
  final (double, double)? fromLatLng;

  /// Callback when "Get Directions" is tapped.
  final void Function(MapSearchResult result) onGetDirections;

  /// Callback when travel mode toggle chip is tapped.
  final void Function(String mode) onTravelModeChanged;

  /// Callback when external website button is tapped.
  final void Function(String url) onLaunchWebsite;

  /// Callback when clear/close button is tapped.
  final VoidCallback onClose;

  /// Callback when route is cleared.
  final VoidCallback onClearRoute;

  /// Constructs an [EsriMapDetailSlideOver] instance.
  const EsriMapDetailSlideOver({
    Key? key,
    required this.controller,
    required this.result,
    required this.resultIcon,
    required this.isRoutingMode,
    required this.hasRoute,
    required this.routeFailed,
    required this.travelMode,
    required this.routeTravelTimeMinutes,
    required this.routeManeuvers,
    required this.fromLatLng,
    required this.onGetDirections,
    required this.onTravelModeChanged,
    required this.onLaunchWebsite,
    required this.onClose,
    required this.onClearRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRouting = isRoutingMode || hasRoute || routeFailed;
    final isBuilding = result.source == MapSearchSource.building;

    final detailText = isBuilding ? result.address : result.description;
    final categoryLabel = isBuilding ? 'Building' : result.subtitle;

    // Content-aware sheet sizing
    final screenHeight = MediaQuery.of(context).size.height;
    double contentEst = 80.0 + 30 + 48 + 40;
    if (detailText.isNotEmpty) contentEst += 60;
    final hasRouteManeuvers = hasRoute && routeManeuvers.isNotEmpty;
    if (hasRouteManeuvers) contentEst += routeManeuvers.length * 52.0;

    final contentFraction = (contentEst / screenHeight).clamp(0.15, 0.80);
    final initialSize = hasRoute ? 0.35 : (contentFraction < 0.30 ? contentFraction : 0.30);
    final maxSize = hasRoute ? 0.80 : (contentFraction < 0.80 ? contentFraction.clamp(0.30, 0.80) : 0.80);
    final snaps = <double>[0.15];
    final isInitialLarger = initialSize > 0.15 + 0.01;
    if (isInitialLarger) snaps.add(initialSize);

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initialSize,
      minChildSize: 0.15,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: snaps,
      builder: (context, scrollController) {
        final shouldShowDetailText = !isRouting && detailText.isNotEmpty;
        final hasWebsiteUrl = result.websiteUrl != null;

        return buildSlideOverContent(
          context: context,
          scrollController: scrollController,
          headerTitle: isRouting ? 'Directions to ${result.name}' : result.name,
          headerIcon: resultIcon,
          onClose: isRouting ? onClearRoute : onClose,
          sliverBody: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category label (hidden in routing mode)
                    if (!isRouting)
                      Text(
                        categoryLabel,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),

                    // Detail description text (hidden in routing mode)
                    if (shouldShowDetailText) ...[
                      const SizedBox(height: 8),
                      Text(
                        detailText,
                        style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (!isRouting) const SizedBox(height: 16),

                    // Routing or Action Buttons
                    if (routeFailed) ...[
                      Text(
                        'No route available from your current location.',
                        style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            final originParam = fromLatLng != null ? '&origin=${fromLatLng!.$1},${fromLatLng!.$2}' : '';
                            onLaunchWebsite(
                              'https://www.google.com/maps/dir/?api=1'
                              '&destination=${result.latitude},${result.longitude}'
                              '&travelmode=walking'
                              '$originParam',
                            );
                          },
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Navigate in Google Maps'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ] else if (hasRoute) ...[
                      // Travel time estimate
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            routeTravelTimeMinutes < 1 ? '< 1 min' : '${routeTravelTimeMinutes.ceil()} min',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Travel mode toggle chips
                      Row(
                        children: [
                          for (final mode in ['Walking', 'Accessible']) ...[
                            if (mode != 'Walking') const SizedBox(width: 8),
                            GestureDetector(
                              onTap: mode == travelMode ? null : () => onTravelModeChanged(mode),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: mode == travelMode
                                      ? (isDark ? Colors.white : Colors.grey[900])
                                      : (isDark ? Colors.grey[800] : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      mode == 'Walking' ? Icons.directions_walk : Icons.accessible,
                                      size: 16,
                                      color: mode == travelMode
                                          ? (isDark ? Colors.grey[900] : Colors.white)
                                          : (isDark ? Colors.white70 : Colors.grey[700]),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      mode,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: mode == travelMode
                                            ? (isDark ? Colors.grey[900] : Colors.white)
                                            : (isDark ? Colors.white70 : Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Google Maps fallback button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final originParam = fromLatLng != null ? '&origin=${fromLatLng!.$1},${fromLatLng!.$2}' : '';
                            onLaunchWebsite(
                              'https://www.google.com/maps/dir/?api=1'
                              '&destination=${result.latitude},${result.longitude}'
                              '&travelmode=walking'
                              '$originParam',
                            );
                          },
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Navigate in Google Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? const Color(0xFFFFCD00) : null,
                            side: isDark ? const BorderSide(color: Color(0xFFFFCD00)) : null,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ] else
                      // Directions + Website buttons
                      Row(
                        children: [
                          if (hasWebsiteUrl) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => onLaunchWebsite(result.websiteUrl!),
                                icon: const Icon(Icons.language, size: 18),
                                label: const Text('View website'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? const Color(0xFFFFCD00) : null,
                                  side: isDark ? const BorderSide(color: Color(0xFFFFCD00)) : null,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: isRoutingMode ? null : () => onGetDirections(result),
                              icon: isRoutingMode
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.directions, size: 18),
                              label: Text(isRoutingMode ? 'Routing...' : 'Get Directions'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Turn-by-turn maneuver list
            if (hasRouteManeuvers)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final step = routeManeuvers[index];
                  final distMeters = step.length;
                  final distLabel = distMeters < 1000
                      ? '${distMeters.round()} m'
                      : '${(distMeters / 1000).toStringAsFixed(1)} km';
                  final isNotLastManeuver = index < routeManeuvers.length - 1;
                  final isFirstIndex = index == 0;

                  return Column(
                    children: [
                      if (isFirstIndex) const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.subdirectory_arrow_right,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        title: Text(step.directionText, style: const TextStyle(fontSize: 14)),
                        trailing: distMeters > 0
                            ? Text(
                                distLabel,
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                              )
                            : null,
                        dense: true,
                      ),
                      if (isNotLastManeuver) const Divider(height: 1),
                    ],
                  );
                }, childCount: routeManeuvers.length),
              ),
          ],
        );
      },
    );
  }
}
