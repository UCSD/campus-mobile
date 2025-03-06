import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_constants.dart';
import 'onboarding_slide_template.dart';

class OnboardingSlides extends StatefulWidget {
  @override
  _OnboardingSlidesState createState() => _OnboardingSlidesState();
}

class _OnboardingSlidesState extends State<OnboardingSlides> with TickerProviderStateMixin
{
  var currentIndex = 0;
  final _foregroundPageController = PageController();
  final _backgroundPageController = PageController();
  late final _screenWidth = MediaQuery.sizeOf(context).width;
  late final _screenHeight = MediaQuery.sizeOf(context).height;

  @override
  void initState() {
    super.initState();
    _foregroundPageController.addListener(() {
      _backgroundPageController.jumpTo(_foregroundPageController.page! * MediaQuery.of(context).size.width);
    });
  }

  // Dot Indicator
  Widget buildDotIndicator() =>
    DotsIndicator(
      dotsCount: 5,
      position: currentIndex,
      decorator: const DotsDecorator(activeColor: const Color(0xFF182B49)),
    );

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightOnboardingScreen,
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // Background Image transitioning smoothly
          PageView.builder(
            controller: _backgroundPageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (_, index) =>
              Image.asset(
                "assets/images/onboarding-slide-${index + 1}-background.png",
                fit: BoxFit.fitWidth,
              )
          ),
          Column(
            children: <Widget>[
              const SizedBox(height: 110.0),
              buildDotIndicator(),
              
              Expanded(
                child: PageView(
                  controller: _foregroundPageController,
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
                    buildPage5(),
                  ],
                ),
              ),

              buildGoToTheAppButton(),
              const SizedBox(height: 80.0),
            ],
          ),
        ],
      ),
    );

  Widget buildPage1() =>
    OnboardingSlideTemplate(
      width: _screenWidth,
      height: _screenHeight,
      heroImage: const AssetImage('assets/images/hero/hero-img-campus-life.png'),
      heading: "ONE-STOP ACCESS TO CAMPUS LIFE.",
      description:
      "Keep up to date with amazing events and stay connected to campus news.",
    );

  Widget buildPage2() =>
    OnboardingSlideTemplate(
      width: _screenWidth,
      height: _screenHeight,
      heroImage: const AssetImage('assets/images/hero/hero-img-schedule.png'),
      heading: "YOUR SCHEDULE ON THE GO",
      description: "View your classes and finals schedule whenever you need.",
    );

  Widget buildPage3() =>
    OnboardingSlideTemplate(
      width: _screenWidth,
      height: _screenHeight,
      heroImage: const AssetImage('assets/images/hero/hero-img-parking.png'),
      heading: "PARKING MADE EASIER.",
      description: "Keep an eye on parking lot capacity to plan your day.",
    );

  Widget buildPage4() =>
    OnboardingSlideTemplate(
      width: _screenWidth,
      height: _screenHeight,
      heroImage: const AssetImage('assets/images/hero/hero-img-busyness.png'),
      heading: "SPEND LESS TIME WAITING.",
      description: "Easily see how busy campus locations are before you arrive.",
    );

  Widget buildPage5() =>
    OnboardingSlideTemplate(
      width: _screenWidth,
      height: _screenHeight,
      heroImage: const AssetImage('assets/images/hero/hero-img-notifications.png'),
      heading: "YOU'RE ALL SET.",
      description:
      "We recommend turning on push notifications to receive campus and safety alerts.",
    );

  Widget buildGoToTheAppButton() =>
    GestureDetector(
      child: Semantics(
        hint:
        'press to skip the login process and use this app as a visitor',
        child: const Text(
          "GO TO THE APP",
          style: const TextStyle(
            color: const Color(0xFF182B49), // Subheading color
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            height: 1.195, // line height: 16.73px
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      onTap: () async {
        Navigator.pushNamedAndRemoveUntil(context,
            RoutePaths.BottomNavigationBar, (_) => false);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('showOnboardingScreen', false);
      },
    );
}
