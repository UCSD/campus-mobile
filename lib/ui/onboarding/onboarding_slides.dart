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

class _OnboardingSlidesState extends State<OnboardingSlides>
    with TickerProviderStateMixin {
  var currentIndex = 0;
  var currentBackgroundPath = 'assets/images/onboarding-slide-one-background.png';
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Dot Indicator
  Widget buildDotIndicator() {
    return DotsIndicator(
      dotsCount: 5,
      position: currentIndex,
      decorator: DotsDecorator(activeColor: const Color(0xFF182B49)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightOnboardingScreen,
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // Background Image based on currentIndex
          Container(
            width: double.infinity,
            height: double.infinity,
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage(currentBackgroundPath), // Dynamic background
            //     fit: BoxFit.cover,
            //   ),
            // ),
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemBuilder: (context, index) {
                return Image.asset(
                  "assets/images/onboarding-slide-${index+1}-background.png",
                  fit: BoxFit.fitWidth
                );
              },
            )
            // child: Image.asset(
            //   "assets/images/onboarding-slide-${currentIndex+1}-background.png",
            //   fit: BoxFit.cover
            // ),
          ),
          Column(
            children: <Widget>[
              const SizedBox(height: 110.0),
              buildDotIndicator(),
              Expanded(
                child: PageView(
                  pageSnapping: true,
                  //controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      currentIndex = page;
                      currentBackgroundPath = getBackgroundImage();
                      _pageController.jumpToPage(page);
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
  }


  Widget buildPage1() {
    return OnboardingSlideTemplate(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      heroImage: AssetImage('assets/images/hero/hero-img-campus-life.png'),
      heading: "ONE-STOP ACCESS TO CAMPUS LIFE.",
      description:
      "Keep up to date with amazing events and stay connected to campus news.",
    );
  }

  Widget buildPage2() {
    return OnboardingSlideTemplate(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      heroImage: AssetImage('assets/images/hero/hero-img-schedule.png'),
      heading: "YOUR SCHEDULE ON THE GO",
      description: "View your classes and finals schedule whenever you need.",
    );
  }

  Widget buildPage3() {
    return OnboardingSlideTemplate(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      heroImage: AssetImage('assets/images/hero/hero-img-parking.png'),
      heading: "PARKING MADE EASIER.",
      description: "Keep an eye on parking lot capacity to plan your day.",
    );
  }

  Widget buildPage4() {
    return OnboardingSlideTemplate(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      heroImage: AssetImage('assets/images/hero/hero-img-busyness.png'),
      heading: "SPEND LESS TIME WAITING.",
      description: "Easily see how busy campus locations are before you arrive.",
    );
  }

  Widget buildPage5() {
    return OnboardingSlideTemplate(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      heroImage: AssetImage('assets/images/hero/hero-img-notifications.png'),
      heading: "YOU'RE ALL SET.",
      description:
        "We recommend turning on push notifications to receive campus and safety alerts.",
    );
  }

  Widget buildGoToTheAppButton() {
    return GestureDetector(
      child: Semantics(
        hint:
          'press to skip the login process and use this app as a visitor',
        child: Text(
          "GO TO THE APP",
          style: TextStyle(
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

  String getBackgroundImage() {
    switch (currentIndex) {
      case 0:
        return 'assets/images/onboarding-slide-one-background.png';
      case 1:
        return 'assets/images/onboarding-slide-two-background.png';
      case 2:
        return 'assets/images/onboarding-slide-three-background.png';
      case 3:
        return 'assets/images/onboarding-slide-four-background.png';
      case 4:
        return 'assets/images/onboarding-slide-five-background.png';
      default:
        return 'assets/images/onboarding-slide-one-background.png';
    }
  }
}


