import 'dart:math' as math;

import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'onboarding_slide_template.dart';

class OnboardingSlides extends StatefulWidget {
  @override
  _OnboardingSlidesState createState() => _OnboardingSlidesState();
}

class _OnboardingSlidesState extends State<OnboardingSlides> with TickerProviderStateMixin {
  var currentIndex = 0;
  final _foregroundPageController = PageController();
  final _backgroundPageController = PageController();

  @override
  void initState() {
    super.initState();
    _foregroundPageController.addListener(() {
      _backgroundPageController.jumpTo(_foregroundPageController.page! * MediaQuery.sizeOf(context).width);
    });
  }

  double _portraitUnit(double width, double usableHeight) {
    final cap = width < 600
        ? double.infinity
        : width < 900
        ? 520.0
        : width < 1200
        ? 600.0
        : 680.0;
    return math.min(width, math.min(usableHeight / 1.8, cap));
  }

  double _landscapeUnit(double width, double usableHeight) {
    final cap = width < 900
        ? double.infinity
        : width < 1200
        ? 600.0
        : width < 1500
        ? 680.0
        : 760.0;
    return math.min(0.77 * usableHeight, math.min(0.49 * width, cap));
  }

  double _stackHeight(double u, double textScale, bool landscape) {
    final photoWidth = (textScale > 1.15 ? 0.8 : 0.9) * u;
    final photoHeight = photoWidth / OnboardingSlideTemplate.heroAspectRatio;
    final textHeight =
        2 * math.max(28.0, 0.12 * u) * 1.1 * textScale + 0.085 * u + 3 * math.max(14.0, 0.041 * u) * 1.3 * textScale;
    final contentHeight = landscape ? math.max(photoHeight, textHeight) : photoHeight + 0.135 * u + textHeight;
    final linkLine = math.max(14.0, 0.039 * u) * 1.195 * textScale;
    return 0.03 * u + 0.03 * u + contentHeight + 0.12 * u + linkLine;
  }

  // Dot Indicator
  Widget buildDotIndicator(double u) => DotsIndicator(
    dotsCount: 5,
    position: currentIndex.toDouble(),
    decorator: DotsDecorator(
      activeColor: const Color(0xFF00619B),
      activeSize: Size.square(0.03 * u),
      size: Size.square(0.02 * u),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final usableHeight = size.height - padding.top - padding.bottom;
    final landscape = size.width > size.height && size.shortestSide >= 600;
    final u = landscape ? _landscapeUnit(size.width, usableHeight) : _portraitUnit(size.width, usableHeight);
    final textScale = math.min(MediaQuery.textScalerOf(context).scale(14) / 14, 1.3);
    final spare = math.max(0.0, usableHeight - _stackHeight(u, textScale, landscape));
    final linkFontSize = math.max(14.0, 0.039 * u);
    final linkLineHeight = linkFontSize * 1.195 * textScale;
    final linkPadding = math.max(0.0, math.min(48.0 - linkLineHeight, 0.12 * u - 2.0));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightOnboardingScreen,
      body: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            // Background Image transitioning smoothly
            PageView.builder(
              controller: _backgroundPageController,
              physics: const NeverScrollableScrollPhysics(),
              pageSnapping: false,
              itemCount: 5,
              itemBuilder: (_, index) => Stack(
                children: [
                  Positioned(
                    left: -2.5,
                    right: -2.5,
                    top: 0,
                    bottom: 0,
                    child: Image.asset(
                      "assets/images/onboarding/slide-${index + 1}-background.jpg",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom),
              child: Column(
                children: <Widget>[
                  if (!landscape) SizedBox(height: spare * 0.55),
                  buildDotIndicator(u),
                  SizedBox(height: 0.03 * u),
                  Expanded(
                    child: PageView(
                      controller: _foregroundPageController,
                      onPageChanged: (int page) {
                        setState(() {
                          currentIndex = page;
                        });
                      },
                      children: [
                        buildPage1(u, landscape),
                        buildPage2(u, landscape),
                        buildPage3(u, landscape),
                        buildPage4(u, landscape),
                        buildPage5(u, landscape),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.12 * u - linkPadding),
                  buildGoToTheAppButton(u, linkPadding),
                  if (!landscape) SizedBox(height: spare * 0.45),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage1(double u, bool landscape) => OnboardingSlideTemplate(
    u: u,
    landscape: landscape,
    heroImage: const AssetImage('assets/images/onboarding/hero-1-campus-life.png'),
    heading: "ONE-STOP ACCESS\nTO CAMPUS LIFE.",
    description: "Keep up to date with amazing events and stay connected to campus news.",
  );

  Widget buildPage2(double u, bool landscape) => OnboardingSlideTemplate(
    u: u,
    landscape: landscape,
    heroImage: const AssetImage('assets/images/onboarding/hero-2-schedule.png'),
    heading: "YOUR SCHEDULE\nON THE GO.",
    description: "View your classes and finals schedule whenever you need.",
  );

  Widget buildPage3(double u, bool landscape) => OnboardingSlideTemplate(
    u: u,
    landscape: landscape,
    heroImage: const AssetImage('assets/images/onboarding/hero-3-parking.png'),
    heading: "PARKING\nMADE EASIER.",
    description: "Keep an eye on parking lot capacity to plan your day.",
  );

  Widget buildPage4(double u, bool landscape) => OnboardingSlideTemplate(
    u: u,
    landscape: landscape,
    heroImage: const AssetImage('assets/images/onboarding/hero-4-busyness.png'),
    heading: "SPEND LESS\nTIME WAITING.",
    description: "Easily see how busy campus locations are before you arrive.",
  );

  Widget buildPage5(double u, bool landscape) => OnboardingSlideTemplate(
    u: u,
    landscape: landscape,
    heroImage: const AssetImage('assets/images/onboarding/hero-5-notifications.png'),
    heading: "YOU'RE ALL SET.",
    description: "We recommend turning on push notifications to receive campus and safety alerts.",
  );

  Widget buildGoToTheAppButton(double u, double topPadding) => GestureDetector(
    child: Semantics(
      hint: 'press to skip the login process and use this app as a visitor',
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Text(
          "GO TO THE APP",
          style: TextStyle(
            color: const Color(0xFF182B49), // Subheading color
            fontWeight: FontWeight.w700,
            fontSize: math.max(14.0, 0.039 * u),
            height: 1.195, // line height: 16.73px
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFF00629B),
          ),
        ),
      ),
    ),
    onTap: () async {
      Navigator.pushNamedAndRemoveUntil(context, RoutePaths.BOTTOM_NAVIGATION_BAR, (_) => false);
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('showOnboardingScreen', false);
    },
  );
}
