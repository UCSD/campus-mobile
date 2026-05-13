import 'package:flutter/material.dart';

import 'esrimap_basemaps.dart';

class EsriMapLayersPanel extends StatelessWidget {
  final BasemapType currentBasemapType;
  final String sceneMode;
  final bool showTransitLayer;
  final bool loadingTransitLayer;
  final bool showCampusDistricts;
  final bool showConstruction;
  final bool loadingConstruction;
  final bool showAssemblyAreas;
  final bool loadingAssemblyAreas;
  final void Function(BasemapType) onSwitchBasemap;
  final void Function(String) onSetSceneMode;
  final VoidCallback onToggleTransitLayer;
  final VoidCallback onToggleCampusDistricts;
  final VoidCallback onToggleConstruction;
  final VoidCallback onToggleAssemblyAreas;
  final VoidCallback onClose;

  const EsriMapLayersPanel({
    Key? key,
    required this.currentBasemapType,
    required this.sceneMode,
    required this.showTransitLayer,
    required this.loadingTransitLayer,
    required this.showCampusDistricts,
    required this.showConstruction,
    required this.loadingConstruction,
    required this.showAssemblyAreas,
    required this.loadingAssemblyAreas,
    required this.onSwitchBasemap,
    required this.onSetSceneMode,
    required this.onToggleTransitLayer,
    required this.onToggleCampusDistricts,
    required this.onToggleConstruction,
    required this.onToggleAssemblyAreas,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final accent = isDark
        ? Colors.lightBlue[300]!
        : Theme.of(context).colorScheme.primary;

    Widget sectionLabel(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: subtitleColor,
            ),
          ),
        );

    Widget imageTile({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      Widget? imageWidget,
      bool loading = false,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: selected
                      ? Border.all(color: accent, width: 2.5)
                      : Border.all(
                          color: isDark
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.5),
                  child: loading
                      ? Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (imageWidget ??
                          Container(
                            color: isDark
                                ? Colors.grey[700]
                                : Colors.grey[300],
                          )),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? accent : textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget sceneChip(String label, bool selected) => GestureDetector(
          onTap: () {
            onSetSceneMode(label);
            // Keep panel open so the user sees the active chip update
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: selected
                  ? Border.all(color: accent, width: 2)
                  : Border.all(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
              color: selected
                  ? accent.withOpacity(0.12)
                  : (isDark ? Colors.grey[850] : Colors.grey[100]),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? accent : textColor,
              ),
            ),
          ),
        );

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 12,
      right: 12,
      bottom: bottomPad + 12,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy > 200) onClose();
        },
        child: Material(
        elevation: 10,
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Map Display',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: subtitleColor),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // Basemap + Layers sections — grayed out when not in Default scene mode
            Opacity(
              opacity: sceneMode == 'Default' ? 1.0 : 0.35,
              child: IgnorePointer(
                ignoring: sceneMode != 'Default',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Basemaps
                    sectionLabel('BASEMAP'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final type in BasemapType.values) ...[
                              imageTile(
                                label: basemapLabels[type]!,
                                selected: currentBasemapType == type,
                                onTap: () => onSwitchBasemap(type),
                                imageWidget: Image.asset(
                                  {
                                    BasemapType.defaultMap: 'lib/ui/esrimap/temp_assets/default-thumbnail.png',
                                    BasemapType.light:     'lib/ui/esrimap/temp_assets/light-thumbnail.png',
                                    BasemapType.dark:      'lib/ui/esrimap/temp_assets/dark-thumbnail.png',
                                    BasemapType.satellite: 'lib/ui/esrimap/temp_assets/satellite-thumbnail.png',
                                  }[type]!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24, indent: 16, endIndent: 16),

                    // Row 2: Operational layers
                    sectionLabel('LAYERS'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            imageTile(
                              label: 'Triton Transit',
                              selected: showTransitLayer,
                              loading: loadingTransitLayer,
                              onTap: onToggleTransitLayer,
                              imageWidget: Image.asset(
                                'lib/ui/esrimap/temp_assets/shuttles-thumbnail.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            imageTile(
                              label: 'Districts',
                              selected: showCampusDistricts,
                              onTap: onToggleCampusDistricts,
                              imageWidget: Image.asset(
                                'lib/ui/esrimap/temp_assets/districts-thumbnail.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            imageTile(
                              label: 'Construction',
                              selected: showConstruction,
                              loading: loadingConstruction,
                              onTap: onToggleConstruction,
                              imageWidget: Image.asset(
                                'lib/ui/esrimap/temp_assets/construction-thumbnail.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            imageTile(
                              label: 'Assembly Areas',
                              selected: showAssemblyAreas,
                              loading: loadingAssemblyAreas,
                              onTap: onToggleAssemblyAreas,
                              imageWidget:
                                  Container(color: const Color(0xFFD4EDDA)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24, indent: 16, endIndent: 16),
                  ],
                ),
              ),
            ),

            // Row 3: Scene mode chips
            sectionLabel('SCENE'),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Wrap(
                spacing: 8,
                children: [
                  sceneChip('Default', sceneMode == 'Default'),
                  sceneChip('3D Building', sceneMode == '3D Building'),
                  sceneChip('Drone View', sceneMode == 'Drone View'),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
