import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_affiliations.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import 'onboarding_login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreen createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  late AnimationController _animationController,
      _animationController2,
      _animationController3;
  late Animation<Offset> _offsetAnimation, _offsetAnimation2, _offsetAnimation3;
  double? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page!.round() != currentIndex) {
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        Container(
          child: Column(children: <Widget>[
            Expanded(
                child: PageView(
              pageSnapping: true,
              controller: _controller,
              children: [
                buildPage1(width, height),
                buildPage2(width, height),
                buildPage3(width, height),
              ],
            )),
            buildDotIndicator(),
            Container(
              height: height * 0.066,
              color: Colors.white,
            ),
            buildLoginButton(width, height),
          ]),
        ),
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
      ]),
    );
  }

  Widget buildDotIndicator() {
    return DotsIndicator(
      dotsCount: 3,
      position: currentIndex!,
      decorator: DotsDecorator(
          activeColor: ColorPrimary, spacing: EdgeInsets.all(4.0)),
    );
  }

  Widget buildLoginButton(double width, double height) {
    return Container(
        color: ColorPrimary,
        height: height * 0.089,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: TextButton(
                style: TextButton.styleFrom(
                  primary: ColorPrimary,
                ),
                onPressed: () {
                  Navigator.of(context).push(_routeToAffiliations());
                },
                child: Semantics(
                  button: true,
                  hint:
                      'press to start by choosing your affiliation to UC San Diego',
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        decoration: TextDecoration.underline),
                  ),
                ),
              )),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: ColorPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(_routeToLogin());
                  },
                  child: Semantics(
                    button: true,
                    hint: 'press to login with your ucsd account',
                    child: Text(
                      "Log In",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              )
            ]));
  }

  Widget buildPage1(double width, double height) {
    return Stack(clipBehavior: Clip.none, children: <Widget>[
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FractionallySizedBox(
          child: Container(
              height: height * 0.42,
              decoration: new BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/onboarding_background1.png'),
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
                      color: ColorPrimary.withOpacity(0.7), fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ])),
        ))
      ]),
      Container(
        padding: EdgeInsets.only(left: width * 0.03, top: height * 0.1),
        child: Container(
            height: height * 0.4,
            width: width * 0.48,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/onboarding_classes.png'),
              fit: BoxFit.fill,
            ))),
      ),
    ]);
  }

  Widget buildPage2(double width, double height) {
    return Stack(children: <Widget>[
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Container(
            height: height * 0.42,
            decoration: new BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/onboarding_background2.png'),
              fit: BoxFit.fill,
            ))),
        Container(
          height: height * 0.056,
          color: Colors.white,
        ),
        Expanded(
            child: Container(
          width: width * 0.93,
          color: Colors.white,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                Text(
                  "Made for students AND staff",
                  style: TextStyle(
                      color: ColorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * 0.01),
                ),
                Text(
                  "Log in now to gain access to personalized information.",
                  style: TextStyle(
                      color: ColorPrimary.withOpacity(0.7), fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ])),
        ))
      ]),
      Column(children: <Widget>[
        Container(
          //alignment: Alignment.topRight,
          padding: EdgeInsets.only(left: width * 0.026, top: height * 0.35),
          child: Container(
              height: height * 0.14,
              width: width * 0.49,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image:
                    AssetImage('assets/images/onboarding_student_profile.png'),
                fit: BoxFit.fill,
              ))),
        )
      ]),
    ]);
  }

  Widget buildPage3(double width, double height) {
    return Stack(children: <Widget>[
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Container(
            height: height * .42,
            decoration: new BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/onboarding_background3.png'),
              fit: BoxFit.fill,
            ))),
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
                  "Know what's going on",
                  style: TextStyle(
                      color: ColorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * 0.01),
                ),
                Text(
                  "Connect to the latest university services, news, and information when you need it most.",
                  style: TextStyle(
                      color: ColorPrimary.withOpacity(0.7), fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ])),
        ))
      ]),
      Container(
        //alignment: Alignment.topCenter,
        padding: EdgeInsets.only(left: width * 0.03, top: height * 0.1),
        child: Container(
            height: height * 0.4,
            width: width * 0.48,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/onboarding_news.png'),
              fit: BoxFit.fill,
            ))),
      )
    ]);
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
