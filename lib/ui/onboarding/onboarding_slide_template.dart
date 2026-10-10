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

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final photoWidth = (textScale > 1.15 ? 0.8 : 0.9) * u;
    final photoHeight = photoWidth / heroAspectRatio;
    final headingFontSize = math.max(28.0, 0.12 * u);
    final bodyFontSize = math.max(14.0, 0.041 * u);

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
          SizedBox(height: 0.085 * u),
          Text(
            description,
            style: TextStyle(color: const Color(0xFF182B49), fontSize: bodyFontSize, height: 1.3),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );

    final Widget content;
    if (landscape) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          photo,
          SizedBox(width: 0.10 * u),
          text,
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          photo,
          SizedBox(height: 0.135 * u),
          text,
        ],
      );
    }

    // Three body lines is the conservative estimate used by the outer column;
    // scrolling is only a fallback when even the minimum sizes cannot fit.
    final minTextHeight = 2 * headingFontSize * 1.1 * textScale + 0.085 * u + 3 * bodyFontSize * 1.3 * textScale;
    final minHeight = landscape ? math.max(photoHeight, minTextHeight) : photoHeight + 0.135 * u + minTextHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < minHeight) {
          return SingleChildScrollView(child: Center(child: content));
        }
        return Center(child: content);
      },
    );
  }
}
