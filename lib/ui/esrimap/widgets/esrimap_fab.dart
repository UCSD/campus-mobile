/// ============================================================================
/// File: esrimap_fab.dart
/// Description: Floating Action Button (FAB) cluster widget containing the
///              compass needle, recenter on user/view, and layers toggle buttons.
/// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating action button cluster widget rendered in top-right of map view.
class EsriMapFabCluster extends StatelessWidget {
  /// Whether dark theme mode is active.
  final bool isDark;

  /// Whether a 3D scene mode is active.
  final bool is3D;

  /// Map rotation heading in degrees.
  final double mapRotation;

  /// Whether location tracking button is active.
  final bool isLocationActive;

  /// Whether recenter button is active.
  final bool isRecenterActive;

  /// Callback when layers panel button is pressed.
  final VoidCallback onShowLayersPanel;

  /// Callback when recenter on view button is pressed.
  final VoidCallback onRecenterOnView;

  /// Callback when recenter on user location button is pressed.
  final VoidCallback onRecenterOnUser;

  /// Callback when compass snap-to-north button is pressed.
  final VoidCallback onSnapToNorth;

  /// Constructs an [EsriMapFabCluster] instance.
  const EsriMapFabCluster({
    Key? key,
    required this.isDark,
    this.is3D = false,
    required this.mapRotation,
    this.isLocationActive = false,
    this.isRecenterActive = false,
    required this.onShowLayersPanel,
    required this.onRecenterOnView,
    required this.onRecenterOnUser,
    required this.onSnapToNorth,
  }) : super(key: key);

  /// Active state highlight color.
  static const Color ACTIVE_COLOR = Color(0xFFC69214);

  /// Fixed button diameter size.
  static const double SIZE = 48.0;

  /// Height for individual pill button segments.
  static const double BTN_HEIGHT = 44.0;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? Colors.grey[800]! : Colors.white;
    final fgColor = isDark ? Colors.white : Colors.grey[800]!;

    final locationColor = isLocationActive ? ACTIVE_COLOR : fgColor;
    final recenterColor = isRecenterActive ? ACTIVE_COLOR : fgColor;
    final isNot3D = !is3D;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Compass needle button
        Material(
          elevation: 4,
          color: bgColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: onSnapToNorth,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: SIZE,
              height: SIZE,
              child: Center(
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: _CompassNeedlePainter(
                    rotationDegrees: mapRotation,
                    southColor: fgColor.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Pill container with action buttons
        Material(
          elevation: 4,
          color: bgColor,
          borderRadius: BorderRadius.circular(SIZE / 2),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: SIZE,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNot3D)
                    _pillButton(
                      icon: Icons.my_location,
                      color: locationColor,
                      onTap: onRecenterOnUser,
                    ),
                  _pillButton(
                    icon: Icons.center_focus_strong,
                    color: recenterColor,
                    onTap: onRecenterOnView,
                  ),
                  _pillButton(icon: Icons.layers_outlined, color: fgColor, onTap: onShowLayersPanel),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: BTN_HEIGHT,
        child: Center(child: Icon(icon, size: 22, color: color)),
      ),
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  final double rotationDegrees;
  final Color southColor;

  const _CompassNeedlePainter({required this.rotationDegrees, required this.southColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final tipDist = size.height * 0.46;
    final halfWidth = size.width * 0.18;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-rotationDegrees * math.pi / 180);

    final northPath = Path()
      ..moveTo(0, -tipDist)
      ..lineTo(halfWidth, 0)
      ..lineTo(-halfWidth, 0)
      ..close();

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
  bool shouldRepaint(_CompassNeedlePainter old) {
    final isRotationChanged = old.rotationDegrees != rotationDegrees;
    final isColorChanged = old.southColor != southColor;
    return isRotationChanged || isColorChanged;
  }
}
