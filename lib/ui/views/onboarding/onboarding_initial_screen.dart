import 'dart:ui';

import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_screen.dart';

class OnboardingInitial extends StatefulWidget {
  @override
  _OnboardingInitialState createState() => _OnboardingInitialState();
}

class _OnboardingInitialState extends State<OnboardingInitial>
    with TickerProviderStateMixin {
  bool _visible = true;
  bool _tappedScreen = true;
  bool _visibleBackground = true;
  bool _animateScreen = false;
  final _controller = PageController();
  double currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page.round() != currentIndex) {
        setState(() {
          currentIndex = _controller.page;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Expanded(
                  child:

                      ///PAGE 1 CONNECTIONS----------------------------------------------------

                      Stack(overflow: Overflow.clip, children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          height: MediaQuery.of(context).size.height * .46,
                          decoration: new BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage(
                                'assets/images/onboarding_connections_background.png'),
                            fit: BoxFit.fill,
                          ))),
                      Expanded(
                          child: Container(
                        width: width * 0.9,
                        color: Colors.white,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                  Padding(padding: EdgeInsets.only(top: 40.0)),
                                  Text(
                                    "Make the most out of your CAMPUS CONNECTIONS",
                                    style: TextStyle(
                                        color: ColorPrimary,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  Text(
                                    "Your trusted, on-the-go, location-based campus resource for all things Triton.",
                                    style: TextStyle(
                                        color: ColorPrimary.withOpacity(0.7),
                                        fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ])),
                          ),
                        ),
                      ))
                    ]),
                Container(
                  padding:
                      EdgeInsets.only(left: width * 0.03, top: height * 0.2),
                  child: Container(
                      height: height * 0.35,
                      width: width * 0.48,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/app_preview.png'),
                        fit: BoxFit.fill,
                      ))),
                ),
              ])),
              DotsIndicator(
                dotsCount: 3,
                position: currentIndex,
                decorator: DotsDecorator(
                    activeColor: ColorPrimary, spacing: EdgeInsets.all(4.0)),
              ),
              Container(
                height: 60,
                color: Colors.white,
              ),
              Container(
                  color: ColorPrimary,
                  height: 80,
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                            child: FlatButton(
                          color: ColorPrimary,
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                decoration: TextDecoration.underline),
                          ),
                        )),
                        Expanded(
                          child: FlatButton(
                            color: ColorPrimary,
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
          Container(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_tappedScreen == true) {
                setState(() {
                  _visible = !_visible;
                  Navigator.of(context).push(_createRoute());
                });
              }
            },
          ),
        ]));
  }

  Widget buildRectangleBar1(double width, double height) {
    return Transform.rotate(
        angle: 0.785,
        child: Transform.translate(
            offset: Offset(width - 320, -220),
            child: Container(
              width: 110,
              height: 560,
              color: Colors.yellow,
            )));
  }

  Widget buildRectangleBar2(double width, double height) {
    return Transform.rotate(
        angle: 0.785,
        child: Transform.translate(
            offset: Offset(width - 190, -80),
            child: Container(
              width: 110,
              height: 560,
              color: Colors.yellow,
            )));
  }

  Widget buildRectangleBar3(double width, double height) {
    return Transform.rotate(
        angle: 0.785,
        child: Transform.translate(
            offset: Offset(width - 60, -220),
            child: Container(
              width: 110,
              height: 560,
              color: Colors.yellow,
            )));
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          OnboardingScreen(),
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
