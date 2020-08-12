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
      backgroundColor: Colors.white,
      body: Column(children: <Widget>[
        Expanded(
            child: PageView(
          pageSnapping: true,
          controller: _controller,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.purple,
                    ),
                  ),
                  Expanded(
                      child: Container(
                    width: 350,
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
                            padding: EdgeInsets.only(top: 10),
                          ),
                          Text(
                            "your trusted, on-the-go, location-based campus resource for all things Triton.",
                            style: TextStyle(
                                color: ColorPrimary.withOpacity(0.7),
                                fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ])),
                  ))
                ]),
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
          color: Colors.grey,
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
          height: 80,
          color: Colors.white,
        ),
        Container(
            color: ColorPrimary,
            height: 80,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: FlatButton(
                    color: ColorPrimary,
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RoutePaths.OnboardingAffiliations);
                    },
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          decoration: TextDecoration.underline),
                    ),
                  )),
                  Expanded(
                    child: FlatButton(
                      color: ColorPrimary,
                      onPressed: () {
                        Navigator.pushNamed(
                            context, RoutePaths.OnboardingLogin);
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                ]))
      ]),
    );

    /*
          Container(
            child: Row(children: <Widget>[
              Align(
                  alignment: Alignment.bottomLeft,
                  child: RaisedButton(
                    color: ColorPrimary,
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RoutePaths.OnboardingAffiliations);
                    },
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          decoration: TextDecoration.underline),
                    ),
                  )),
              Align(
                alignment: Alignment.bottomRight,
                child: RaisedButton(
                  color: ColorPrimary,
                  onPressed: () {
                    Navigator.pushNamed(context, RoutePaths.OnboardingLogin);
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        decoration: TextDecoration.underline),
                  ),
                ),
              )
            ]),
          )
          */
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
