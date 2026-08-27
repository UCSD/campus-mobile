/// ============================================================================
/// File: esrimap_layers_panel.dart
/// Description: Floating panel widget allowing users to select basemaps (Default,
///              Light, Dark, Satellite), toggle operational layers, and switch 3D scenes.
/// ============================================================================

import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';
import 'package:campus_mobile_experimental/core/utils/esri_map_feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Bottom sheet widget rendering basemap choices, layer toggles, and 3D scene mode chips.
class EsriMapLayersPanel extends StatelessWidget {
  /// Map configuration containing basemap specs and layer definitions.
  final EsriMapConfig config;

  /// Currently selected basemap type.
  final BasemapType currentBasemapType;

  /// Currently selected scene mode key ('default', 'building3d', 'droneView').
  final String currentSceneKey;

  /// Visibility status map keyed by operational layer key.
  final Map<String, bool> layerVisible;

  /// Loading status map keyed by operational layer key.
  final Map<String, bool> layerLoading;

  /// Callback when a basemap option is selected.
  final void Function(BasemapType type) onSwitchBasemap;

  /// Callback when a 3D scene mode chip is selected.
  final void Function(String key) onSetSceneMode;

  /// Callback when an operational layer toggle is pressed.
  final void Function(String key) onToggleLayer;

  /// Callback when panel close button is pressed.
  final VoidCallback onClose;

  /// Whether to hide the 3D scene switcher section.
  final bool hideSceneSwitcher;

  /// Constructs an [EsriMapLayersPanel] instance.
  const EsriMapLayersPanel({
    Key? key,
    required this.config,
    required this.currentBasemapType,
    required this.currentSceneKey,
    required this.layerVisible,
    required this.layerLoading,
    required this.onSwitchBasemap,
    required this.onSetSceneMode,
    required this.onToggleLayer,
    required this.onClose,
    this.hideSceneSwitcher = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final accent = isDark ? Colors.lightBlue[300]! : Theme.of(context).colorScheme.primary;

    Widget sectionLabel(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
      ),
    );

    Widget imageTile({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      Widget? imageWidget,
      bool loading = false,
    }) {
      return Semantics(
        button: true,
        selected: selected,
        label: loading ? '$label, loading' : label,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: 86,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? Border.all(color: accent, width: 2.5)
                          : Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.5),
                      child: loading
                          ? const Center(
                              child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : (imageWidget ?? Container(color: isDark ? Colors.grey[700] : Colors.grey[300])),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? accent : textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget networkImage(String url) => Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: isDark ? Colors.grey[700] : Colors.grey[300]),
    );

    Widget sceneChip(String key, String label, bool selected) => Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: () => onSetSceneMode(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: selected
                  ? Border.all(color: accent, width: 2)
                  : Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1),
              color: selected ? accent.withValues(alpha: 0.12) : (isDark ? Colors.grey[850] : Colors.grey[100]),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? accent : textColor,
              ),
            ),
          ),
        ),
      ),
    );

    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDefault = currentSceneKey == 'default';
    // Hide SCENES entirely from the UI. SET to TRUE when ready to show drone view and 3D view to the user.
    final showSceneSwitcher = FeatureFlags.MAP_SCENES_ENABLED && config.features.scenes && !hideSceneSwitcher;

    return Positioned(
      left: 12,
      right: 12,
      bottom: bottomPad + 12,
      child: Semantics(
        sortKey: const OrdinalSortKey(1.8),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            final isSwipeDown = details.velocity.pixelsPerSecond.dy > 200;
            if (isSwipeDown) onClose();
          },
          child: Material(
            elevation: 10,
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basemap + Layers — grayed out when not in default 2D scene
                Opacity(
                  opacity: isDefault ? 1.0 : 0.35,
                  child: IgnorePointer(
                    ignoring: !isDefault,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map Type Header (with Close Button)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Map Type',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: onClose,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close, size: 18, color: subtitleColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final entry in config.basemaps.entries.where((e) {
                                  final t = basemapTypeFromKey(e.key);
                                  var tIsNull = t == null;
                                  if (tIsNull) return false;
                                  var isAlt = FeatureFlags.MAP_ALTERNATE_BASEMAPS_ENABLED;
                                  if (isAlt) return true;
                                  var notLight = t != BasemapType.light;
                                  var notDark = t != BasemapType.dark;
                                  return notLight && notDark;
                                })) ...[
                                  imageTile(
                                    label: entry.value.label,
                                    selected: currentBasemapType == basemapTypeFromKey(entry.key),
                                    onTap: () {
                                      final t = basemapTypeFromKey(entry.key);
                                      final isTypeNotNull = t != null;
                                      if (isTypeNotNull) onSwitchBasemap(t);
                                    },
                                    imageWidget: networkImage(entry.value.thumbnailAsset),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                        ),

                        if (FeatureFlags.MAP_OPERATIONAL_LAYERS_ENABLED) ...[
                          const Divider(height: 24, indent: 16, endIndent: 16),

                          sectionLabel('Map Details'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final entry in config.layers.entries.where((e) {
                                    var key = e.key;
                                    var isTransit = key == 'tritonTransit';
                                    if (isTransit) return FeatureFlags.TRANSIT_OPERATIONAL_LAYER_ENABLED;
                                    var isDist = key == 'campusDistricts';
                                    if (isDist) return FeatureFlags.DISTRICTS_OPERATIONAL_LAYER_ENABLED;
                                    var isConst = key == 'construction';
                                    if (isConst) return FeatureFlags.CONSTRUCTION_OPERATIONAL_LAYER_ENABLED;
                                    return true;
                                  })) ...[
                                    imageTile(
                                      label: entry.value.label,
                                      selected: layerVisible[entry.key] ?? false,
                                      loading: layerLoading[entry.key] ?? false,
                                      onTap: () => onToggleLayer(entry.key),
                                      imageWidget: networkImage(entry.value.thumbnailAsset),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Scene chips — gated by features flag, hidden when slide-over is active
                if (showSceneSwitcher) ...[
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  sectionLabel('Scene'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final entry in config.scenes.entries.where((e) {
                          var key = e.key;
                          var isDef = key == 'default';
                          if (isDef) return FeatureFlags.DEFAULT_SCENE_ENABLED;
                          var is3d = key == 'building3d';
                          if (is3d) return FeatureFlags.THREE_DIMENSIONAL_SCENE_ENABLED;
                          var isDrone = key == 'droneView';
                          if (isDrone) return FeatureFlags.DRONE_VIEW_SCENE_ENABLED;
                          return true;
                        }))
                          sceneChip(entry.key, entry.value.label, currentSceneKey == entry.key),
                      ],
                    ),
                  ),
                ] else
                  const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
