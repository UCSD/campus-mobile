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
                  image: DecorationImage(
                    image: heroImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: width * 0.9,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Heading
                      Text(
                        heading,
                        style: const TextStyle(
                          color: ColorPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.025),
                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          color: ColorPrimary.withOpacity(0.7),
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
  }
}
