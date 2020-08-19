import 'dart:ui';

import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/debug/build_info.dart';

//import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:campus_mobile_experimental/ui/views/onboarding/onboarding_affiliations.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'onboarding_login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreen createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  AnimationController _animationController,
      _animationController2,
      _animationController3;
  Animation<Offset> _offsetAnimation, _offsetAnimation2, _offsetAnimation3;
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

    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..forward();

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(3.0, -0.59),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController2 =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..forward();
    _offsetAnimation2 = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-5.0, 0.98),
    ).animate(CurvedAnimation(
      parent: _animationController2,
      curve: Curves.linear,
    ));

    _animationController3 =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..forward();
    _offsetAnimation3 = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(3.0, -0.59),
    ).animate(CurvedAnimation(
      parent: _animationController3,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _animationController2.dispose();
    _animationController3.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        Container(
          child: Column(children: <Widget>[
            Expanded(
                child: PageView(
              pageSnapping: true,
              controller: _controller,
              children: [
                ///PAGE 1 CONNECTIONS----------------------------------------------------
                (Stack(overflow: Overflow.clip, children: <Widget>[
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
                        Container(
                          height: 50,
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
                                AutoSizeText(
                                  "Make the most out of your CAMPUS CONNECTIONS",
                                  maxLines: 2,
                                  minFontSize: 18,
                                  maxFontSize: 25,
                                  style: TextStyle(
                                      color: ColorPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
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

                ///PAGE 2 NEWS---------------------------------------------------------
                Stack(children: <Widget>[
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height * .46,
                            decoration: new BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/onboarding_affiliation_background.png'),
                              fit: BoxFit.fill,
                            ))),
                        Expanded(
                            child: Container(
                          width: width * 0.93,
                          color: Colors.white,
                          child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                Padding(padding: EdgeInsets.only(top: 40.0)),
                                Text(
                                  "Made for students AND staff",
                                  style: TextStyle(
                                      color: ColorPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                Text(
                                  "Log in now to gain access to personalized information",
                                  style: TextStyle(
                                      color: ColorPrimary.withOpacity(0.7),
                                      fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ])),
                        ))
                      ]),
                  Column(children: <Widget>[
                    Container(
                      //alignment: Alignment.topRight,
                      padding: EdgeInsets.only(
                          left: width * 0.026, top: height * 0.22),
                      child: Container(
                          height: height * 0.14,
                          width: width * 0.49,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image:
                                AssetImage('assets/images/student_profile.png'),
                            fit: BoxFit.fill,
                          ))),
                    ),
                    Container(
                      //alignment: Alignment.topRight,
                      padding: EdgeInsets.only(
                          left: width * 0.026, top: height * 0.025),
                      child: Container(
                          height: height * 0.14,
                          width: width * 0.49,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image:
                                AssetImage('assets/images/student_profile.png'),
                            fit: BoxFit.fill,
                          ))),
                    )
                  ]),
                ]),

                ///PAGE 3 MAP----------------------------------------------------------
                Stack(children: <Widget>[
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height * .46,
                            decoration: new BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/onboarding_social.png'),
                              fit: BoxFit.fill,
                            ))),
                        Expanded(
                            child: Container(
                          width: width * 0.93,
                          color: Colors.white,
                          child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                Padding(padding: EdgeInsets.only(top: 40.0)),
                                Text(
                                  "Know what's going on",
                                  style: TextStyle(
                                      color: ColorPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                Text(
                                  "Connect to the latest university services, news, and information when you need it most",
                                  style: TextStyle(
                                      color: ColorPrimary.withOpacity(0.7),
                                      fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ])),
                        ))
                      ]),
                  Container(
                    //alignment: Alignment.topCenter,
                    padding:
                        EdgeInsets.only(left: width * 0.48, top: height * 0.11),
                    child: Container(
                        height: height * 0.44,
                        width: width * 0.44,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(
                              'assets/images/onboarding_news_preview.png'),
                          fit: BoxFit.fill,
                        ))),
                  )
                ]),
              ],
            )),
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
                        onPressed: () {
                          Navigator.of(context).push(_routeToAffiliations());
                        },
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
                          onPressed: () {
                            Navigator.of(context).push(_routeToLogin());
                          },
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

        ///---------------------------COMMENT OUT FOR FUNCTIONALITY
        /* BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: AnimatedOpacity(
              opacity: _visible ? 0.5 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Container(
                width: width,
                height: height,
                color: ColorPrimary,
              ),
            )),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_tappedScreen == true) {
              print("hello");
              setState(() {
                _visible = !_visible;
                _animateScreen = true;
              });
              _tappedScreen = false;
              _visibleBackground = false;
            }
          },
        ),*/

        SlideTransition(
          position: _offsetAnimation,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: buildRectangleBar1(width, height)),
        ),

        SlideTransition(
          position: _offsetAnimation2,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: buildRectangleBar2(width, height)),
        ),
        SlideTransition(
          position: _offsetAnimation3,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: buildRectangleBar3(width, height)),
        ),
        // buildRectangleBar1(width, height),
        // buildRectangleBar2(width, height),
        // buildRectangleBar3(width, height),

        ///---------------------------------------------
      ]),
    );
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

  Route _routeToLogin() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          OnboardingLogin(),
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _routeToAffiliations() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          OnboardingAffiliations(),
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
