import 'package:flutter/material.dart';

class EsriMapFabCluster extends StatelessWidget {
  final bool isDark;
  final int allCategoryResultsCount;
  final bool showCategoryList;
  final bool hasLastSelectedResult;
  final bool showRouteFields;
  final bool hasRoute;
  final VoidCallback onShowLayersPanel;
  final VoidCallback onToggleCategoryList;
  final VoidCallback onReopenDetail;
  final VoidCallback onClearRoute;
  final VoidCallback onRecenterOnView;
  final VoidCallback onRecenterOnUser;

  const EsriMapFabCluster({
    Key? key,
    required this.isDark,
    required this.allCategoryResultsCount,
    required this.showCategoryList,
    required this.hasLastSelectedResult,
    required this.showRouteFields,
    required this.hasRoute,
    required this.onShowLayersPanel,
    required this.onToggleCategoryList,
    required this.onReopenDetail,
    required this.onClearRoute,
    required this.onRecenterOnView,
    required this.onRecenterOnUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Layers/display panel toggle
        FloatingActionButton.small(
          heroTag: 'layersBtn',
          backgroundColor: isDark ? Colors.grey[800] : null,
          foregroundColor: isDark ? Colors.white : null,
          onPressed: onShowLayersPanel,
          child: const Icon(Icons.layers_outlined),
        ),
        const SizedBox(height: 10),
        // List view button — only when a category search is active
        if (allCategoryResultsCount > 0) ...[
          FloatingActionButton.small(
            heroTag: 'listBtn',
            onPressed: onToggleCategoryList,
            backgroundColor: isDark ? Colors.grey[800] : null,
            foregroundColor: isDark ? Colors.white : null,
            child: const Icon(Icons.list),
          ),
          const SizedBox(height: 10),
        ],
        if (hasLastSelectedResult)
          FloatingActionButton.small(
            heroTag: 'infoBtn',
            backgroundColor: isDark ? Colors.grey[800] : null,
            foregroundColor: isDark ? Colors.white : null,
            onPressed: onReopenDetail,
            child: const Icon(Icons.info_outline),
          ),
        if (showRouteFields || hasRoute) ...[
          FloatingActionButton.small(
            heroTag: 'clearRouteBtn',
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            onPressed: onClearRoute,
            child: const Icon(Icons.close),
          ),
          const SizedBox(height: 10),
        ],
        if (allCategoryResultsCount > 0 || hasLastSelectedResult)
          const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'recenterBtn',
          backgroundColor: isDark ? Colors.grey[800] : null,
          foregroundColor: isDark ? Colors.white : null,
          onPressed: onRecenterOnView,
          child: const Icon(Icons.center_focus_strong),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'locateBtn',
          backgroundColor: isDark ? Colors.grey[800] : null,
          foregroundColor: isDark ? Colors.white : null,
          onPressed: onRecenterOnUser,
          child: const Icon(Icons.my_location),
        ),
      ],
    );
  }
}
