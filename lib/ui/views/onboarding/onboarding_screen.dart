import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
              fit: BoxFit.contain,
              height: 50,
            ),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Text(
                'Hello.',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Text(
              'Enter your login for a personlized experience.',
              style: TextStyle(color: Colors.white, fontSize: 25),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RoutePaths.OnboardingLogin);
                },
                child: Text(
                  "Let's do it.",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutePaths.BottomNavigationBar, (_) => false);
                },
                child: Text(
                  "Skip for now.",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
