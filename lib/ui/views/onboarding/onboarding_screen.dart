import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/debug/build_info.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/UCSanDiegoLogo-nav.png',
                    fit: BoxFit.contain,
                    height: 50,
                  ),
                  // SizedBox(height: 80),
                  /*  Padding(
                    padding: const EdgeInsets.only(bottom: 26.0),
                    child: Text(
                      'Hello.',
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                  ),*/
                  Text(
                    'Enter your login for a personalized experience.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      color: ColorPrimary,
                      onPressed: () {
                        Navigator.pushNamed(
                            context, RoutePaths.OnboardingLogin);
                      },
                      child: Text(
                        "Let's do it.",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      color: ColorPrimary,
                      onPressed: () async {
                        Navigator.pushNamedAndRemoveUntil(context,
                            RoutePaths.BottomNavigationBar, (_) => false);
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('showOnboardingScreen', false);
                      },
                      child: Text(
                        "Skip for now.",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
              flex: 2,
            ),
            //DebugBuildInfo(),
          ],
        ),
      ),
    );
  }
}
