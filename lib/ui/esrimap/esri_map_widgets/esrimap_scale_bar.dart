/// ============================================================================
/// File: esrimap_scale_bar.dart
/// Description: Google Maps-style dynamic scale indicator widget displaying
///              dual Imperial and Metric distance scale brackets based on current
///              map zoom scale, with automatic fade-in on zoom and fade-out on stop.
/// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

/// Dynamic scale bar widget modeled after Google Maps' scale indicator.
/// Appears when zooming in/out and automatically fades out when zooming stops.
class EsriMapScaleBar extends StatefulWidget {
  /// Current map scale denominator (e.g. 24000 for 1:24,000 scale).
  final double scale;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether the scale bar automatically fades in on scale change and fades out when stopped.
  final bool autoFade;

  /// Inactivity delay before fading out after zooming ceases.
  final Duration fadeDelay;

  const EsriMapScaleBar({
    Key? key,
    required this.scale,
    this.isDark = false,
    this.autoFade = true,
    this.fadeDelay = const Duration(milliseconds: 1080),
  }) : super(key: key);

  @override
  State<EsriMapScaleBar> createState() => _EsriMapScaleBarState();
}

class _EsriMapScaleBarState extends State<EsriMapScaleBar> {
  bool _isVisible = false;
  Timer? _fadeTimer;
  double _lastScale = 0.0;

  /// Standard round imperial distances in feet.
  static const List<double> _imperialDistances = [
    1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000,
    5280, // 1 mi
    10560, // 2 mi
    26400, // 5 mi
    52800, // 10 mi
    105600, // 20 mi
    264000, // 50 mi
  ];

  /// Standard round metric distances in meters.
  static const List<double> _metricDistances = [
    0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500,
    1000, // 1 km
    2000, // 2 km
    5000, // 5 km
    10000, // 10 km
    20000, // 20 km
    50000, // 50 km
    100000, // 100 km
  ];

  @override
  void initState() {
    super.initState();
    _lastScale = widget.scale;
    if (!widget.autoFade) _isVisible = true;
  }

  @override
  void didUpdateWidget(covariant EsriMapScaleBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect zoom/scale changes
    if (widget.scale > 0 && (widget.scale - _lastScale).abs() > 0.05) {
      _lastScale = widget.scale;
      if (widget.autoFade) _triggerZoomFade();
    }
  }

  void _triggerZoomFade() {
    _fadeTimer?.cancel();
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
    _fadeTimer = Timer(widget.fadeDelay, () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scale <= 0) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _buildScaleContent(context),
    );
  }

  Widget _buildScaleContent(BuildContext context) {
    // 1 logical pixel in meters at standard 96 DPI: (scale * 0.0254 / 96.0)
    final metersPerPx = (widget.scale * 0.0254) / 96.0;
    if (metersPerPx <= 0) return const SizedBox.shrink();

    // Target scale bar width between 40 and 100 logical pixels
    double chosenImperialFt = _imperialDistances.first;
    double chosenWidthPx = 60.0;

    for (final ft in _imperialDistances) {
      final meters = ft * 0.3048;
      final px = meters / metersPerPx;
      if (px >= 40 && px <= 100) {
        chosenImperialFt = ft;
        chosenWidthPx = px;
        break;
      }
      if (px > 100) {
        chosenImperialFt = ft;
        chosenWidthPx = px.clamp(40.0, 100.0);
        break;
      }
    }

    // Format imperial label (e.g. "20 ft", "500 ft", "1 mi")
    final String imperialLabel = chosenImperialFt >= 5280
        ? '${(chosenImperialFt / 5280).toStringAsFixed(chosenImperialFt % 5280 == 0 ? 0 : 1)} mi'
        : '${chosenImperialFt.toInt()} ft';

    // Find matching metric distance for the chosen width
    final barMeters = chosenWidthPx * metersPerPx;
    double chosenMetricMeters = _metricDistances.first;
    for (final m in _metricDistances) {
      if (m <= barMeters * 1.3) {
        chosenMetricMeters = m;
      } else {
        break;
      }
    }

    // Format metric label (e.g. "5 m", "200 m", "1 km")
    final String metricLabel = chosenMetricMeters >= 1000
        ? '${(chosenMetricMeters / 1000).toStringAsFixed(chosenMetricMeters % 1000 == 0 ? 0 : 1)} km'
        : (chosenMetricMeters < 1
              ? '${(chosenMetricMeters * 100).round()} cm'
              : '${chosenMetricMeters % 1 == 0 ? chosenMetricMeters.toInt() : chosenMetricMeters.toStringAsFixed(1)} m');

    final textColor = widget.isDark ? Colors.white70 : const Color(0xFF3C4043);
    final lineColor = widget.isDark ? Colors.white70 : const Color(0xFF5F6368);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: (widget.isDark ? Colors.black54 : Colors.white70).withOpacity(0.65),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Imperial distance (Top)
          Text(
            imperialLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 1),

          // Scale bracket bar: |___________|
          SizedBox(
            width: chosenWidthPx,
            height: 6,
            child: CustomPaint(painter: _ScaleBarBracketPainter(color: lineColor)),
          ),
          const SizedBox(height: 1),

          // Metric distance (Bottom)
          Text(
            metricLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.2,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering the horizontal line with vertical tick marks on both ends.
class _ScaleBarBracketPainter extends CustomPainter {
  final Color color;

  const _ScaleBarBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Left tick
    path.moveTo(1, 0);
    path.lineTo(1, size.height);
    // Horizontal center bar
    path.lineTo(size.width - 1, size.height);
    // Right tick
    path.lineTo(size.width - 1, 0);

    // Center tick
    final midX = size.width / 2;
    path.moveTo(midX, size.height);
    path.lineTo(midX, size.height - 3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScaleBarBracketPainter oldDelegate) => oldDelegate.color != color;
}
