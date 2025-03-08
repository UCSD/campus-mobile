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
            const SizedBox(height: 18.0),
            Expanded(
              child: Container(
                width: width * 0.9,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Heading
                      Flexible(
                        flex: 0,
                        child: FractionallySizedBox(
                          widthFactor: 0.83333333,
                          child: Text(
                            heading,
                            // TODO: make the text thicker to match the Figma. Most likely will require a new font file.
                            style: const TextStyle(
                              fontFamily: "Refrigerator Deluxe",
                              color: const Color(0xFF182B49),
                              fontWeight: FontWeight.w800,
                              fontSize: 45,
                              height: 0.97777778,
                              letterSpacing: -0.4,
                            ),
                            textAlign: TextAlign.left,
                          )
                        )
                      ),
                      SizedBox(height: height * 0.025),

                      // Description
                      Flexible(
                        flex: 0,
                        child: FractionallySizedBox(
                          widthFactor: 0.83333333,//0.76388889,
                          child: Text(
                            description,
                            style: const TextStyle(
                              fontFamily: "Brix Sans",
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: -0.2,
                              height: 1.26666667,
                              color: const Color(0xFF182B49)
                            ),
                            textAlign: TextAlign.left,
                          ),
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
  }
}
