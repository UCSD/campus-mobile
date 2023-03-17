import 'dart:ui';

import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import 'onboarding_screen.dart';

class OnboardingInitial extends StatefulWidget {
  @override
  _OnboardingInitialState createState() => _OnboardingInitialState();
}

class _OnboardingInitialState extends State<OnboardingInitial>
    with TickerProviderStateMixin {
  nextPage() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).push(_createRoute());
  }

  @override
  void initState() {
    super.initState();
    nextPage();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Expanded(
                  child: Stack(clipBehavior: Clip.none, children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FractionallySizedBox(
                        child: Container(
                            height: MediaQuery.of(context).size.height * .42,
                            decoration: new BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/onboarding_background1.png'),
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
                                "Make the most out of your CAMPUS CONNECTIONS",
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
                                "Your trusted, on-the-go, location-based campus resource for all things Triton.",
                                style: TextStyle(
                                    color: ColorPrimary.withOpacity(0.7),
                                    fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ])),
                      ))
                    ]),
                Container(
                  padding:
                      EdgeInsets.only(left: width * 0.03, top: height * 0.1),
                  child: Container(
                      height: height * 0.35,
                      width: width * 0.48,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image:
                            AssetImage('assets/images/onboarding_classes.png'),
                        fit: BoxFit.fill,
                      ))),
                ),
              ])),
              DotsIndicator(
                dotsCount: 3,
                position: 0,
                decorator: DotsDecorator(
                    activeColor: ColorPrimary, spacing: EdgeInsets.all(4.0)),
              ),
              Container(
                height: height * 0.066,
                color: Colors.white,
              ),
              Container(
                  color: ColorPrimary,
                  height: height * 0.089,
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                            child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: ColorPrimary,
                          ),
                          onPressed: () {},
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                decoration: TextDecoration.underline),
                          ),
                        )),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: ColorPrimary,
                            ),
                            onPressed: () {},
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        )
                      ]))
            ]),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              width: width,
              height: height,
              color: ColorPrimary.withOpacity(0.4),
            ),
          ),
          buildRectangleBar1(width, height),
          buildRectangleBar2(width, height),
          buildRectangleBar3(width, height),
        ]));
  }

  Widget buildRectangleBar1(double width, double height) {
    return Transform.rotate(
        angle: 0.785,
        child: Transform.translate(
            offset: Offset(width - (width * 0.773), width * -0.66),
            child: Container(
              width: width * 0.266,
              height: height * 0.625,
              color: Colors.yellow,
            )));
  }

  Widget buildRectangleBar2(double width, double height) {
    return Transform.rotate(
        angle: 0.785,
        child: Transform.translate(
            offset: Offset(width - (width * 0.459), width * -0.32),
            child: Container(
              width: width * 0.266,
              height: height * 0.625,
              color: Colors.yellow,
            )));
  }

  Widget buildRectangleBar3(double width, double height) {
    return Transform.rotate(
        angle: 0.785,
        child: Transform.translate(
            offset: Offset(width - (width * 0.145), width * -0.66),
            child: Container(
              width: width * 0.266,
              height: height * 0.625,
              color: Colors.yellow,
            )));
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          OnboardingScreen(),
      transitionDuration: Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
