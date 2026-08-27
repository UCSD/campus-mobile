import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:campus_mobile_experimental/core/utils/esri_map_feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildSlideOverContent({
  required BuildContext context,
  required ScrollController scrollController,
  required String headerTitle,
  IconData? headerIcon,
  required VoidCallback onClose,
  VoidCallback? onHeaderTap,
  Widget? trailing,
  required List<Widget> sliverBody,
  double headerHeight = 80.0,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = Theme.of(context).scaffoldBackgroundColor;
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
            child: InkWell(
              onTap: onHeaderTap,
              child: Column(
                children: [
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
                        Semantics(
                          button: true,
                          label: 'Close panel',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onClose,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                ),
                                child: ExcludeSemantics(
                                  child: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: Divider(height: 1)),
        ...sliverBody,
      ],
    ),
  );
}

/// ============================================================================
/// File: esrimap_detail_slide_over.dart
/// Description: Draggable slide-over sheet displaying building/POI details,
///              travel time, navigation buttons, and turn-by-turn directions.
/// ============================================================================

/// Persistent header delegate for pinned slide-over bottom sheet headers.
class SlideOverHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Header widget content.
  final Widget child;

  /// Fixed height of the persistent header.
  final double height;

  /// Background color matching dark/light mode.
  final Color backgroundColor;

  /// Constructs a [SlideOverHeaderDelegate] instance.
  SlideOverHeaderDelegate({required this.child, required this.height, required this.backgroundColor});

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
Widget buildDetailSlideOverContent({
  required BuildContext context,
  required String headerTitle,
  IconData? headerIcon,
  required VoidCallback onClose,
  required VoidCallback onToggle,
  VoidCallback? onShare,
  required bool isMinimized,
  Widget? trailing,
  required List<Widget> sliverBody,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = Theme.of(context).scaffoldBackgroundColor;
  final hasHeaderIcon = headerIcon != null;
  final hasTrailing = trailing != null;

  return Material(
    color: bgColor,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    elevation: 16,
    clipBehavior: Clip.antiAlias,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        GestureDetector(
          onVerticalDragEnd: (details) {
            var isSwipingDown = details.primaryVelocity != null && details.primaryVelocity! > 0;
            var isSwipingUp = details.primaryVelocity != null && details.primaryVelocity! < 0;
            if (isSwipingDown) {
              if (!isMinimized) onToggle();
            } else if (isSwipingUp) {
              if (isMinimized) onToggle();
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          if (hasHeaderIcon) ...[
                            ExcludeSemantics(
                              child: Icon(headerIcon, size: 18, color: isDark ? Colors.white70 : Colors.grey[700]),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              headerTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasTrailing && !isMinimized) trailing,
                if (onShare != null) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onShare,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.share, size: 16, color: isDark ? Colors.white70 : Colors.grey[800]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onToggle,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMinimized ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.grey[800],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onClose,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isMinimized) const Divider(height: 1),
        if (!isMinimized) Flexible(child: CustomScrollView(shrinkWrap: true, slivers: sliverBody)),
      ],
    ),
  );
}

class EsriMapDetailSlideOver extends StatelessWidget {
  final ValueNotifier<bool> minimizedNotifier;
  final double availableHeight;
  final MapSearchResult result;
  final IconData resultIcon;
  final bool isRoutingMode;
  final bool hasRoute;
  final bool routeFailed;
  final String travelMode;
  final double routeTravelTimeMinutes;
  final List<DirectionManeuver> routeManeuvers;
  final (double, double)? fromLatLng;
  final void Function(MapSearchResult result) onGetDirections;
  final void Function(String mode) onTravelModeChanged;
  final void Function(String url) onLaunchWebsite;
  final VoidCallback onClose;
  final VoidCallback onClearRoute;

  const EsriMapDetailSlideOver({
    Key? key,
    required this.minimizedNotifier,
    required this.availableHeight,
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

    String detailText = isBuilding ? result.address : result.description;

    if (!isBuilding) {
      detailText = detailText.replaceAll(RegExp(r'https?://[^\s]+'), '');
      detailText = detailText.replaceAllMapped(RegExp(r'\.([A-Za-z])'), (m) => '. ${m.group(1)}');
      detailText = detailText.trim();
    }

    final categoryLabel = isBuilding ? 'Building' : result.subtitle;

    // Constrain height to a maximum of 50% of screen height
    final maxHeight = availableHeight * 0.50;

    void handleShare() {
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${result.latitude},${result.longitude}';
      Clipboard.setData(ClipboardData(text: googleMapsUrl));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Link copied to clipboard!'), duration: Duration(seconds: 2)));
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: ValueListenableBuilder<bool>(
        valueListenable: minimizedNotifier,
        builder: (context, isMinimized, child) {
          final shouldShowDetailText = !isRouting && detailText.isNotEmpty;
          final websiteUrl = result.websiteUrl?.trim();
          final hasWebsiteUrl = websiteUrl?.isNotEmpty == true;
          final websiteHost = hasWebsiteUrl ? Uri.tryParse(websiteUrl!)?.host.replaceFirst('www.', '') : null;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: buildDetailSlideOverContent(
              context: context,
              headerTitle: isRouting ? 'Directions to ${result.name}' : result.name,
              headerIcon: resultIcon,
              onClose: isRouting ? onClearRoute : onClose,
              onToggle: () => minimizedNotifier.value = !isMinimized,
              onShare: handleShare,
              isMinimized: isMinimized,
              trailing: isRouting && !routeFailed
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          final originParam = fromLatLng != null ? '&origin=${fromLatLng!.$1},${fromLatLng!.$2}' : '';
                          onLaunchWebsite(
                            'https://www.google.com/maps/dir/?api=1'
                            '&destination=${result.latitude},${result.longitude}'
                            '&travelmode=walking&dirflg=w'
                            '$originParam',
                          );
                        },
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: const Text('Open Google Maps', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: isDark ? const Color(0xFFFFCD00) : Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
              sliverBody: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isRouting)
                          Text(
                            categoryLabel,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        if (shouldShowDetailText) ...[
                          const SizedBox(height: 10),
                          Semantics(
                            label: isBuilding ? 'Building Address: $detailText' : null,
                            child: Text(
                              detailText,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                        if (!isRouting) const SizedBox(height: 20),

                        if (routeFailed) ...[
                          Text(
                            'You are too far from campus for walking navigation.',
                            style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final originParam = fromLatLng != null
                                    ? '&origin=${fromLatLng!.$1},${fromLatLng!.$2}'
                                    : '';
                                onLaunchWebsite(
                                  'https://www.google.com/maps/dir/?api=1'
                                  '&destination=${result.latitude},${result.longitude}'
                                  '&travelmode=driving&dirflg=d'
                                  '$originParam',
                                );
                              },
                              icon: const Icon(Icons.directions_car, size: 18),
                              label: const Text('Drive With Google Maps'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? const Color(0xFFFFCD00) : Theme.of(context).primaryColor,
                                side: BorderSide(
                                  color: isDark ? const Color(0xFFFFCD00) : Theme.of(context).primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ] else if (hasRoute) ...[
                          Row(
                            children: [
                              ExcludeSemantics(
                                child: Icon(
                                  Icons.schedule,
                                  size: 18,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                routeTravelTimeMinutes < 1 ? '< 1 min' : '${routeTravelTimeMinutes.ceil()} min',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.grey[900],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white : Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ExcludeSemantics(
                                      child: Icon(
                                        Icons.directions_walk,
                                        size: 16,
                                        color: isDark ? Colors.grey[900] : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Walking',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.grey[900] : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else
                          Row(
                            children: [
                              if (hasWebsiteUrl) ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => onLaunchWebsite(websiteUrl!),
                                    icon: const Icon(Icons.language, size: 18),
                                    label: websiteHost?.isNotEmpty == true
                                        ? Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(text: 'Visit Website\n'),
                                                TextSpan(text: websiteHost, style: const TextStyle(fontSize: 11)),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : const Text('View website'),
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
                              if (FeatureFlags.MAP_ROUTING_ENABLED)
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: isRoutingMode ? null : () => onGetDirections(result),
                                    icon: isRoutingMode
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                              semanticsLabel: 'Calculating route',
                                            ),
                                          )
                                        : const Icon(Icons.directions, size: 18),
                                    label: Text(isRoutingMode ? 'Calculating...' : 'Get Directions'),
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
                if (routeManeuvers.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final step = routeManeuvers[index];
                      final distMeters = step.length;
                      final distLabel = distMeters < 1000
                          ? '${distMeters.round()} m'
                          : '${(distMeters / 1000).toStringAsFixed(1)} km';
                      final isNotLastManeuver = index < routeManeuvers.length - 1;
                      final isFirstIndex = index == 0;

                      String directionText = step.directionText;
                      directionText = directionText.replaceAll('Location 1', 'My Location');
                      directionText = directionText.replaceAll('Location 2', result.name);

                      return Column(
                        children: [
                          if (isFirstIndex) const Divider(height: 1),
                          ListTile(
                            leading: ExcludeSemantics(
                              child: Icon(
                                Icons.subdirectory_arrow_right,
                                size: 20,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            title: Text(directionText, style: const TextStyle(fontSize: 14)),
                            trailing: distMeters > 0
                                ? Text(
                                    distLabel,
                                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                                  )
                                : null,
                            dense: true,
                          ),
                          if (isNotLastManeuver) const Divider(height: 1, indent: 56),
                        ],
                      );
                    }, childCount: routeManeuvers.length),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
