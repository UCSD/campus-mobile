import 'dart:math' as math;
import 'package:flutter/material.dart';

class EsriMapFabCluster extends StatelessWidget {
  final bool isDark;
  final bool is3D;
  final double mapRotation;
  final bool isLocationActive;
  final bool isRecenterActive;
  final VoidCallback onShowLayersPanel;
  final VoidCallback onRecenterOnView;
  final VoidCallback onRecenterOnUser;
  final VoidCallback onSnapToNorth;

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

  static const _ACTIVE_COLOR = Color(0xFFC69214);
  static const _SIZE = 48.0;
  static const _BTN_HEIGHT = 44.0;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? Colors.grey[800]! : Colors.white;
    final fgColor = isDark ? Colors.white : Colors.grey[800]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Compass — matches pill width
        Material(
          elevation: 4,
          color: bgColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: onSnapToNorth,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: _SIZE,
              height: _SIZE,
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
        // Pill — my location, recenter, layers
        Material(
          elevation: 4,
          color: bgColor,
          borderRadius: BorderRadius.circular(_SIZE / 2),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: _SIZE,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!is3D)
                    _pillButton(
                      icon: Icons.my_location,
                      color: isLocationActive ? _ACTIVE_COLOR : fgColor,
                      onTap: onRecenterOnUser,
                    ),
                  _pillButton(
                    icon: Icons.center_focus_strong,
                    color: isRecenterActive ? _ACTIVE_COLOR : fgColor,
                    onTap: onRecenterOnView,
                  ),
                  _pillButton(
                    icon: Icons.layers_outlined,
                    color: fgColor,
                    onTap: onShowLayersPanel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: _BTN_HEIGHT,
        child: Center(
          child: Icon(icon, size: 22, color: color),
        ),
      ),
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
  bool shouldRepaint(_CompassNeedlePainter old) =>
      old.rotationDegrees != rotationDegrees || old.southColor != southColor;
}
