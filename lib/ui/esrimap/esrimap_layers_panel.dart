import 'package:flutter/material.dart';
import 'esrimap_basemaps.dart';
import 'esrimap_config.dart';

class EsriMapLayersPanel extends StatelessWidget {
  final EsriMapConfig config;
  final BasemapType currentBasemapType;
  final String currentSceneKey;
  final Map<String, bool> layerVisible;
  final Map<String, bool> layerLoading;
  final void Function(BasemapType) onSwitchBasemap;
  final void Function(String) onSetSceneMode;
  final void Function(String) onToggleLayer;
  final VoidCallback onClose;
  final bool hideSceneSwitcher;

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
    final bgColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final accent = isDark ? Colors.lightBlue[300]! : Theme.of(context).colorScheme.primary;

    Widget sectionLabel(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: subtitleColor),
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
                      : Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.5),
                  child: loading
                      ? const Center(
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : (imageWidget ?? Container(color: isDark ? Colors.grey[700] : Colors.grey[300])),
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
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? accent : textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget networkImage(String url) => Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: isDark ? Colors.grey[700] : Colors.grey[300]),
    );

    Widget sceneChip(String key, String label, bool selected) => GestureDetector(
      onTap: () => onSetSceneMode(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: accent, width: 2)
              : Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1),
          color: selected ? accent.withOpacity(0.12) : (isDark ? Colors.grey[850] : Colors.grey[100]),
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
    );

    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDefault = currentSceneKey == 'default';
    final showSceneSwitcher = config.features.scenes && !hideSceneSwitcher;

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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Map Display',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: subtitleColor),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),

              // Basemap + Layers — grayed out when not in default scene
              Opacity(
                opacity: isDefault ? 1.0 : 0.35,
                child: IgnorePointer(
                  ignoring: !isDefault,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionLabel('BASEMAP'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final entry in config.basemaps.entries) ...[
                                if (basemapTypeFromKey(entry.key) != null) ...[
                                  imageTile(
                                    label: entry.value.label,
                                    selected: currentBasemapType == basemapTypeFromKey(entry.key),
                                    onTap: () {
                                      final t = basemapTypeFromKey(entry.key);
                                      if (t != null) onSwitchBasemap(t);
                                    },
                                    imageWidget: networkImage(entry.value.thumbnailAsset),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 24, indent: 16, endIndent: 16),

                      sectionLabel('LAYERS'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final entry in config.layers.entries) ...[
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
                  ),
                ),
              ),

              // Scene chips — gated by features flag, hidden when slide-over is active
              if (showSceneSwitcher) ...[
                const Divider(height: 24, indent: 16, endIndent: 16),
                sectionLabel('SCENE'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final entry in config.scenes.entries)
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
    );
  }
}
