import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_affiliations.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_page.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import 'onboarding_login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreen createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen> with TickerProviderStateMixin {
  var currentIndex = 0;
  var width = 0.0;
  var height = 0.0;

  @override
  void didChangeDependencies() {
    /// TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        Container(
          child: Column(children: <Widget>[
            Expanded(
                child: PageView(
                  pageSnapping: true,
                  onPageChanged: (int page) {
                    setState(() {
                      currentIndex = page;
                    });
                  },
                  children: [
                    buildPage1(),
                    buildPage2(),
                    buildPage3(),
                  ],
            )),
            buildDotIndicator(),
            Container(
              height: height * 0.066,
              color: Colors.white,
            ),
            buildLoginButton(),
          ]),
        ),
      ]),
    );
  }

  Widget buildDotIndicator() {
    return DotsIndicator(
      dotsCount: 3,
      position: currentIndex,
      decorator: DotsDecorator(
          activeColor: ColorPrimary, spacing: EdgeInsets.all(4.0)),
    );
  }

  Widget buildLoginButton() {
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
                  foregroundColor: ColorPrimary,
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
                    foregroundColor: ColorPrimary,
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

  Widget buildPage1() {
    return OnboardingPage(
        width: width,
        height: height,
        background: AssetImage('assets/images/hero/hero-img_campus-life.png'),
        primary: AssetImage('assets/images/onboarding_classes.png'),
        primaryPadding: (x: 0.03, y: 0.1),
        primaryScale: (x: 0.48, y: 0.4),
        heading: "Make the most out of your CAMPUS CONNECTIONS",
        description: "Your trusted, on-the-go, location-based campus resource for all things Triton.",
    );
  }

  Widget buildPage2() {
    return OnboardingPage(
      width: width,
      height: height,
      background: AssetImage('assets/images/onboarding_background2.png'),
      primary: AssetImage('assets/images/onboarding_student_profile.png'),
      primaryPadding: (x: 0.026, y: 0.35),
      primaryScale: (x: 0.49, y: 0.14),
      heading: "Made for students AND staff",
      description: "Log in now to gain access to personalized information.",
    );
  }

  Widget buildPage3() {
    return OnboardingPage(
      width: width,
      height: height,
      background: AssetImage('assets/images/onboarding_background3.png'),
      primary: AssetImage('assets/images/onboarding_news.png'),
      primaryPadding: (x: 0.03, y: 0.1),
      primaryScale: (x: 0.48, y: 0.4),
      heading: "Know what's going on",
      description: "Connect to the latest university services, news, and information when you need it most.",
    );
  }

  Route _routeToLogin() {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => OnboardingLogin(),
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) =>
        SlideTransition(
          position: animation.drive(
              Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero
              ).chain(
                  CurveTween(curve: Curves.ease)
              )
          ),
          child: child,
        ),
    );
  }

  Route _routeToAffiliations() {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => OnboardingAffiliations(),
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) =>
        SlideTransition(
          position: animation.drive(
              Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero
              ).chain(
                  CurveTween(curve: Curves.ease)
              )
          ),
          child: child,
        ),
    );
  }
}
