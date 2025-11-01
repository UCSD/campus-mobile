import 'package:flutter/material.dart';
import '../../app_styles.dart';

class OnboardingSlideTemplate extends StatelessWidget {
  const OnboardingSlideTemplate({
    super.key,
    required this.width,
    required this.height,
    required this.heroImage,
    required this.heading,
    required this.description,
  });

  final double width;
  final double height;
  final AssetImage heroImage;
  final String heading;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 10.0),
        // Hero Image
        FractionallySizedBox(
          child: Container(
            height: height * .42,
            width: width * .9,
            decoration: BoxDecoration(
              image: DecorationImage(image: heroImage, fit: BoxFit.fill),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Heading
                Text(
                  heading,
                  style: const TextStyle(
                    fontFamily: 'Refrigerator Deluxe',
                    color: ColorPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 50,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: height * 0.025),
                // Description
                Text(
                  description,
                  style: TextStyle(color: const Color(0xFF182B49), fontSize: 18),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
