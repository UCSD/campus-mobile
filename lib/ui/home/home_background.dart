import 'package:flutter/material.dart';

/// Paints the existing circles without adding height or mounting card widgets.
class HomeBackgroundDecoration extends Decoration {
  const HomeBackgroundDecoration();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _HomeBackgroundPainter(onChanged);
}

class _HomeBackgroundPainter extends BoxPainter {
  _HomeBackgroundPainter(super.onChanged);

  static const _circles = [
    (
      asset: 'assets/images/circles/circle-1-background.png',
      top: 355.0,
      x: -101.0,
      fromRight: true,
      size: Size(298.64, 280),
    ),
    (asset: 'assets/images/circles/real_circle_2.png', top: 720.0, x: -64.0, fromRight: false, size: Size(136, 136)),
    (
      asset: 'assets/images/circles/circle-4-background.png',
      top: 1065.0,
      x: 190.0,
      fromRight: false,
      size: Size(399.7, 398),
    ),
    (asset: 'assets/images/circles/real_circle_5.png', top: 1908.0, x: -88.0, fromRight: false, size: Size(197, 197)),
    (asset: 'assets/images/circles/real_circle_6.png', top: 2585.0, x: -21.0, fromRight: true, size: Size(188, 188)),
    (
      asset: 'assets/images/circles/circle-3-background.png',
      top: 3392.0,
      x: -142.0,
      fromRight: false,
      size: Size(300, 298.6),
    ),
  ];

  List<BoxPainter> _painters = [];
  double? _devicePixelRatio;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final pixelRatio = configuration.devicePixelRatio ?? 1;
    if (_devicePixelRatio != pixelRatio) {
      for (final painter in _painters) {
        painter.dispose();
      }
      _devicePixelRatio = pixelRatio;
      _painters = [
        for (final circle in _circles)
          BoxDecoration(
            image: DecorationImage(
              image: ResizeImage(
                AssetImage(circle.asset),
                width: (circle.size.width * pixelRatio).ceil(),
                height: (circle.size.height * pixelRatio).ceil(),
                policy: ResizeImagePolicy.fit,
              ),
              fit: BoxFit.contain,
            ),
          ).createBoxPainter(onChanged),
      ];
    }
    final size = configuration.size!;
    canvas.save();
    // The sliver supplies content bounds and a paint offset that follows scroll.
    canvas.clipRect(offset & size);
    for (var index = 0; index < _circles.length; index++) {
      final circle = _circles[index];
      final left = circle.fromRight ? size.width - circle.x - circle.size.width : circle.x;
      _painters[index].paint(canvas, offset + Offset(left, circle.top), configuration.copyWith(size: circle.size));
    }
    canvas.restore();
  }

  @override
  void dispose() {
    for (final painter in _painters) {
      painter.dispose();
    }
    super.dispose();
  }
}
