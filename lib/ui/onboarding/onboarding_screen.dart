import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_affiliations.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_slide_template.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_constants.dart';
import 'onboarding_login.dart';

///// FILE NOT NEEDED
/// TODO: REMOVE THIS FILE FROM EXISTENCE
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreen createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen> with TickerProviderStateMixin {
  var currentIndex = 0;
  var width, height = 0.0;

  @override
  void didChangeDependencies() {
    /// TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // Dot Indicator
  Widget buildDotIndicator() {
    return DotsIndicator(
      dotsCount: 5,
      position: currentIndex,
      decorator: DotsDecorator(
          activeColor: const Color(0xFF182B49)),
    );
  }

  // Onboarding pages (slides) generator
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightOnboardingScreen, // ColorPrimary, //Colors.white,
      body: Stack(alignment: Alignment.topCenter, children: <Widget>[
        buildDotIndicator(),
        Column(children: <Widget>[
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
              buildPage4(),
              buildPage5()
            ],
          )),
          buildGoToTheAppButton(),
        ]),
      ]),
    );
  }

  Widget buildPage1() {
    return OnboardingPage(
      width: width,
      height: height,
      heroImage: AssetImage('assets/images/hero/hero-img-campus-life.png'),
      heading: "ONE-STOP ACCESS TO CAMPUS LIFE.",
      description:
          "Keep up to date with amazing events and stay connected to campus news.",
    );
  }

  Widget buildPage2() {
    return OnboardingPage(
      width: width,
      height: height,
      heroImage: AssetImage('assets/images/hero/hero-img-schedule.png'),
      heading: "YOUR SCHEDULE ON THE GO",
      description: "View your classes and finals schedule whenever you need.",
    );
  }

  Widget buildPage3() {
    return OnboardingPage(
      width: width,
      height: height,
      heroImage:
          AssetImage('assets/images/New_Hero_Images/hero-img-parking.png'),
      heading: "PARKING MADE EASIER.",
      description: "Keep an eye on parking lot capacity to plan your day.",
    );
  }

  Widget buildPage4() {
    return OnboardingPage(
      width: width,
      height: height,
      heroImage: AssetImage('assets/images/hero/hero-img-campus-life.png'),
      heading: "SPEND LESS TIME WAITING.",
      description: "Easily see how busy campus locations are before you arrive.",
    );
  }

  Widget buildPage5() {
    return OnboardingPage(
      width: width,
      height: height,
      heroImage: AssetImage('assets/images/hero/hero-img-campus-life.png'),
      heading: "YOU'RE ALL SET.",
      description:
      "We recommend turning on push notifications to receive campus and safety alerts.",
    );
  }

  //////////////// Footer
  Widget buildGoToTheAppButton() {
    return
              GestureDetector(
                child: Semantics(
                  hint:
                      'press to skip the login process and use this app as a visitor',
                  child: Text(
                    "GO TO THE APP",
                    style: TextStyle(
                      color: Color(0xFF182B49), // Subheading color
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5,
                      height: 1.195, // line height: 16.73px
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                onTap: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutePaths.BottomNavigationBar, (_) => false);
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool('showOnboardingScreen', false);
                },
              );

  }
}
