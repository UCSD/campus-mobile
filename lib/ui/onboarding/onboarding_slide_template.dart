import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class OnboardingSlideTemplate extends StatelessWidget {
  const OnboardingSlideTemplate({
    super.key,
    required this.u,
    this.landscape = false,
    required this.heroImage,
    required this.heading,
    required this.description,
  });

  static const double heroAspectRatio = 984 / 900;

  final double u;
  final bool landscape;
  final AssetImage heroImage;
  final String heading;
  final String description;

  // Three body lines is the conservative estimate used by the outer column;
  // scrolling is only a fallback when even the minimum sizes cannot fit.
  static double contentHeight({
    required double unit,
    required double textScale,
    required bool landscape,
    double photoFactor = 0.9,
  }) {
    final photoWidth = photoFactor * unit;
    final photoHeight = photoWidth / heroAspectRatio;
    final textHeight =
        2 * math.max(28.0, 0.12 * unit) * 1.1 * textScale +
        0.0595 * unit +
        3 * math.max(14.0, 0.041 * unit) * 1.3 * textScale;
    return landscape ? math.max(photoHeight, textHeight) : photoHeight + 0.0945 * unit + textHeight;
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final basePhotoFactor = textScale > 1.15 ? 0.8 : 0.9;
    final shrunkPhotoFactor = textScale > 1.15 ? 0.72 : 0.8;
    final headingFontSize = math.max(28.0, 0.12 * u);
    final bodyFontSize = math.max(14.0, 0.041 * u);

    Widget content(double photoFactor) {
      final photoWidth = photoFactor * u;
      final photoHeight = photoWidth / heroAspectRatio;

      final photo = SizedBox(
        width: photoWidth,
        height: photoHeight,
        child: Image(image: heroImage, fit: BoxFit.contain),
      );

      final text = SizedBox(
        width: 0.8 * u,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                heading,
                style: TextStyle(
                  fontFamily: 'Refrigerator Deluxe',
                  color: ColorPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: headingFontSize,
                  height: 1.1,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 0.0595 * u),
            Text(
              description,
              style: TextStyle(color: const Color(0xFF182B49), fontSize: bodyFontSize, height: 1.3),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      );

      if (landscape) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            photo,
            SizedBox(width: 0.10 * u),
            text,
          ],
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          photo,
          SizedBox(height: 0.0945 * u),
          text,
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = contentHeight(
          unit: u,
          textScale: textScale,
          landscape: landscape,
          photoFactor: basePhotoFactor,
        );
        var photoFactor = basePhotoFactor;
        if (constraints.maxHeight < minHeight) {
          final shrunkMinHeight = contentHeight(
            unit: u,
            textScale: textScale,
            landscape: landscape,
            photoFactor: shrunkPhotoFactor,
          );
          if (constraints.maxHeight < shrunkMinHeight) {
            return SingleChildScrollView(child: Center(child: content(basePhotoFactor)));
          }
          photoFactor = shrunkPhotoFactor;
        }
        return Center(child: content(photoFactor));
      },
    );
  }
}
