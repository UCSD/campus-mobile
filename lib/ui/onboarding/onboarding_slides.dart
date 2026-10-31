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

  double _stackHeight(double u, double textScale, bool landscape, {double? contentUnit}) {
    final linkLine = math.max(14.0, 0.039 * u) * 1.195 * textScale;
    final gapBL = math.max(0.084 * u, 50.0 - linkLine);
    return 0.03 * u +
        0.03 * u +
        OnboardingSlideTemplate.contentHeight(
          unit: contentUnit ?? u,
          textScale: textScale,
          landscape: landscape,
          photoFactor: textScale > 1.15 ? 0.8 : 0.9,
        ) +
        gapBL +
        linkLine;
  }

  double _boostedContentUnit(double u, double textScale, double baseSpare, double usableHeight) {
    if (baseSpare <= 0) return u;
    final photoFactor = textScale > 1.15 ? 0.8 : 0.9;
    double content(double unit) => OnboardingSlideTemplate.contentHeight(
      unit: unit,
      textScale: textScale,
      landscape: false,
      photoFactor: photoFactor,
    );
    final target = content(u) + 0.165 * baseSpare;
    var unit = u;
    for (var i = 0; i < 3; i++) {
      final deficit = target - content(unit);
      if (deficit <= 0.1) break;
      final slope = content(unit + 1.0) - content(unit);
      if (slope <= 0) break;
      unit += deficit / slope;
    }
    // Bias the solve to undershoot: the PageView is sized to the modeled height.
    unit = math.max(u, unit - 0.25);
    final maxStackHeight = usableHeight - 0.835 * baseSpare;
    while (unit > u && _stackHeight(u, textScale, false, contentUnit: unit) > maxStackHeight) {
      unit = math.max(u, unit - 1.0);
    }
    return unit;
  }

  // Dot Indicator
  Widget buildDotIndicator(double u) => DotsIndicator(
    dotsCount: 5,
    position: currentIndex.toDouble(),
    decorator: DotsDecorator(
      activeColor: const Color(0xFF00619B),
      activeSize: Size.square(0.03 * u),
      size: Size.square(0.02 * u),
      spacing: const EdgeInsets.symmetric(horizontal: 6.0),
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
    final baseSpare = math.max(0.0, usableHeight - _stackHeight(u, textScale, landscape));
    final contentUnit = landscape ? u : _boostedContentUnit(u, textScale, baseSpare, usableHeight);
    final linkFontSize = math.max(14.0, 0.039 * u);
    final linkLineHeight = linkFontSize * 1.195 * textScale;
    final gapBL = math.max(0.084 * u, 50.0 - linkLineHeight);
    final linkPadding = math.max(0.0, math.min(48.0 - linkLineHeight, gapBL - 2.0));

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
                  if (!landscape) SizedBox(height: baseSpare * 0.385),
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
                        buildPage1(contentUnit, landscape),
                        buildPage2(contentUnit, landscape),
                        buildPage3(contentUnit, landscape),
                        buildPage4(contentUnit, landscape),
                        buildPage5(contentUnit, landscape),
                      ],
                    ),
                  ),
                  SizedBox(height: gapBL - linkPadding),
                  Transform.translate(
                    offset: Offset(0, landscape ? -math.min(0.1 * u, gapBL) : 0),
                    child: buildGoToTheAppButton(u, linkPadding),
                  ),
                  if (!landscape) SizedBox(height: baseSpare * 0.45),
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
