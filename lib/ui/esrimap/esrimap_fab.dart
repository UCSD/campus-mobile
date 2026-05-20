import 'dart:math' as math;
import 'package:flutter/material.dart';

class EsriMapFabCluster extends StatelessWidget {
  final bool isDark;
  final bool is3D;
  final bool showAiSearch;
  final int allCategoryResultsCount;
  final bool showCategoryList;
  final bool hasLastSelectedResult;
  final bool showRouteFields;
  final bool hasRoute;
  final double mapRotation;
  final VoidCallback onShowLayersPanel;
  final VoidCallback onShowAiSearch;
  final VoidCallback onToggleCategoryList;
  final VoidCallback onReopenDetail;
  final VoidCallback onClearRoute;
  final VoidCallback onRecenterOnView;
  final VoidCallback onRecenterOnUser;
  final VoidCallback onSnapToNorth;

  const EsriMapFabCluster({
    Key? key,
    required this.isDark,
    this.is3D = false,
    this.showAiSearch = true,
    required this.allCategoryResultsCount,
    required this.showCategoryList,
    required this.hasLastSelectedResult,
    required this.showRouteFields,
    required this.hasRoute,
    required this.mapRotation,
    required this.onShowLayersPanel,
    required this.onShowAiSearch,
    required this.onToggleCategoryList,
    required this.onReopenDetail,
    required this.onClearRoute,
    required this.onRecenterOnView,
    required this.onRecenterOnUser,
    required this.onSnapToNorth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? Colors.grey[800]! : Colors.white;
    final fgColor = isDark ? Colors.white : Colors.grey[800]!;
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!is3D) ...[
          FloatingActionButton.small(
            heroTag: 'aiSearchBtn',
            backgroundColor: accent,
            foregroundColor: Colors.white,
            onPressed: onShowAiSearch,
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton.small(
          heroTag: 'layersBtn',
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          onPressed: onShowLayersPanel,
          child: const Icon(Icons.layers_outlined),
        ),
        const SizedBox(height: 10),
        // List view button — only when a category search is active and not in 3D
        if (!is3D && allCategoryResultsCount > 0) ...[
          FloatingActionButton.small(
            heroTag: 'listBtn',
            onPressed: onToggleCategoryList,
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            child: const Icon(Icons.list),
          ),
          const SizedBox(height: 10),
        ],
        if (!is3D && hasLastSelectedResult) ...[
          FloatingActionButton.small(
            heroTag: 'infoBtn',
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            onPressed: onReopenDetail,
            child: const Icon(Icons.info_outline),
          ),
          const SizedBox(height: 10),
        ],
        if (!is3D && (showRouteFields || hasRoute)) ...[
          FloatingActionButton.small(
            heroTag: 'clearRouteBtn',
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            onPressed: onClearRoute,
            child: const Icon(Icons.close),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton.small(
          heroTag: 'recenterBtn',
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          onPressed: onRecenterOnView,
          child: const Icon(Icons.center_focus_strong),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'locateBtn',
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          onPressed: onRecenterOnUser,
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 10),
        // Compass — rotates with the map, tapping snaps back to north
        FloatingActionButton.small(
          heroTag: 'compassBtn',
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          onPressed: onSnapToNorth,
          child: CustomPaint(
            size: const Size(22, 22),
            painter: _CompassNeedlePainter(
              rotationDegrees: mapRotation,
              southColor: fgColor.withOpacity(0.35),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  final double rotationDegrees;
  final Color southColor;

  const _CompassNeedlePainter({
    required this.rotationDegrees,
    required this.southColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final tipDist = size.height * 0.46;
    final halfWidth = size.width * 0.18;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-rotationDegrees * math.pi / 180);

    // North (red) half — points up
    final northPath = Path()
      ..moveTo(0, -tipDist)
      ..lineTo(halfWidth, 0)
      ..lineTo(-halfWidth, 0)
      ..close();

    // South (muted) half — points down
    final southPath = Path()
      ..moveTo(0, tipDist)
      ..lineTo(halfWidth, 0)
      ..lineTo(-halfWidth, 0)
      ..close();

    canvas.drawPath(northPath, Paint()..color = Colors.red);
    canvas.drawPath(southPath, Paint()..color = southColor);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassNeedlePainter old) =>
      old.rotationDegrees != rotationDegrees || old.southColor != southColor;
}
