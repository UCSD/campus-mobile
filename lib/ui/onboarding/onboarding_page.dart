import 'package:flutter/material.dart';

import '../../app_styles.dart';

class OnboardingPage extends StatelessWidget
{
  const OnboardingPage({
    super.key,
    required this.width,
    required this.height,
    required this.background,
    required this.primary,
    required this.primaryPadding,
    required this.primaryScale,
    required this.heading,
    required this.description
  });

  final double width;
  final double height;
  final AssetImage background;
  final AssetImage primary;
  final ({double x, double y}) primaryPadding;
  final ({double x, double y}) primaryScale;
  final String heading;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: <Widget>[
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FractionallySizedBox(
          child: Container(
              height: height * 0.42,
              decoration: new BoxDecoration(
                  image: DecorationImage(
                    image: background,
                    fit: BoxFit.fill,
                  ))),
        ),
        Container(
          height: height * 0.056,
          color: Colors.white,
        ),
        Expanded(
            child: Container(
              width: width * 0.9,
              color: Colors.white,
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          heading,
                          style: TextStyle(
                              color: ColorPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.01),
                        ),
                        Text(
                          description,
                          style: TextStyle(
                              color: ColorPrimary.withOpacity(0.7), fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ])),
            ))
      ]),
      Container(
        padding: EdgeInsets.only(left: width * primaryPadding.x, top: height * primaryPadding.y),
        child: Container(
            height: height * primaryScale.y,
            width: width * primaryScale.x,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: primary,
                  fit: BoxFit.fill,
                ))),
      ),
    ]);
  }
}