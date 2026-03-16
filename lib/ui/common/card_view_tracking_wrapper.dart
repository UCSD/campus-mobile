import 'dart:async';

import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Wraps a home screen card and logs a [cardId]_card_viewed analytics event when
/// the card has been in view for more than [viewDuration] (e.g. dining_card_viewed).
class CardViewTrackingWrapper extends StatefulWidget {
  const CardViewTrackingWrapper({
    super.key,
    required this.cardId,
    required this.child,
    this.visibilityThreshold = 0.5,
    this.viewDuration = const Duration(seconds: 3),
  });

  final String cardId;
  final Widget child;
  final double visibilityThreshold;
  final Duration viewDuration;

  @override
  State<CardViewTrackingWrapper> createState() => _CardViewTrackingWrapperState();
}

class _CardViewTrackingWrapperState extends State<CardViewTrackingWrapper> {
  Timer? _viewTimer;
  bool _hasLoggedViewThisSession = false;

  @override
  void dispose() {
    _viewTimer?.cancel();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction >= widget.visibilityThreshold;

    if (visible) {
      if (_hasLoggedViewThisSession) return;
      _viewTimer ??= Timer(widget.viewDuration, () {
        _viewTimer = null;
        if (!mounted) return;
        _hasLoggedViewThisSession = true;
        analytics.logEvent(name: '${widget.cardId}_card_viewed');
      });
    } else {
      _viewTimer?.cancel();
      _viewTimer = null;
      _hasLoggedViewThisSession = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('card_view_${widget.cardId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: widget.child,
    );
  }
}
