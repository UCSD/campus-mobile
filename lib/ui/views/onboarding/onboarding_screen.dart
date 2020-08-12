import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/debug/build_info.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreen createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen> {
  final _controller = PageController();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: Column(children: <Widget>[
          Expanded(
              child: PageView(
            pageSnapping: true,
            controller: _controller,
            children: [
              Container(
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      "page 1",
                      style: TextStyle(color: Colors.black),
                    ),
                  )),
              Container(
                  color: Colors.orange,
                  child: Center(
                    child: Text(
                      "page 2",
                      style: TextStyle(color: Colors.black),
                    ),
                  )),
              Container(
                  color: Colors.yellow,
                  child: Center(
                    child: Text(
                      "page 3",
                      style: TextStyle(color: Colors.black),
                    ),
                  )),
            ],
          )),
          DotsIndicator(
            color: Colors.grey[50],
            controller: _controller,
            itemCount: 3,
            onPageSelected: (int index) {
              _controller.animateToPage(
                index,
                duration: Duration(seconds: 1),
                curve: Curves.ease,
              );
            },
          ),
          Container(
            child: Row(children: <Widget>[
              RaisedButton(
                color: ColorPrimary,
                onPressed: () {
                  Navigator.pushNamed(context, RoutePaths.OnboardingLogin);
                },
                child: Text(
                  "Let's do it.",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      decoration: TextDecoration.underline),
                ),
              ),
              RaisedButton(
                color: ColorPrimary,
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutePaths.BottomNavigationBar, (_) => false);
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
            ]),
          )
        ]));
  }
}

/*Column(
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
                      Navigator.pushNamed(context, RoutePaths.OnboardingLogin);
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
    );
  }
  */
