import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/debug/build_info.dart';
//import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:campus_mobile_experimental/ui/views/onboarding/onboarding_affiliations.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreen createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen> {
  final _controller = PageController();
  double currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if(_controller.page.round() != currentIndex) {
        setState(() {
          currentIndex = _controller.page;
        });
      }
    });
  }
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
            ///PAGE 1 CONNECTIONS----------------------------------------------------
            Stack(children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height / 2 - 50,
                        decoration: new BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage('assets/images/students.png'),
                          fit: BoxFit.fill,
                        ))),
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
                padding: EdgeInsets.only(left: 15.0, top: 140.0),
                child: Container(
                    height: 290.0,
                    width: 180.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/app_preview.png'),
                      fit: BoxFit.fill,
                    ))),
              )
            ]),

            ///PAGE 2 NEWS---------------------------------------------------------
            Stack(children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height / 2 - 50,
                        decoration: new BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(
                              'assets/images/onboarding_news_background.png'),
                          fit: BoxFit.fill,
                        ))),
                    Expanded(
                        child: Container(
                      width: 350,
                      color: Colors.white,
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            Text(
                              "Know what's going on",
                              style: TextStyle(
                                  color: ColorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15),
                            ),
                            Text(
                              "get campus news, updates, events, and notifcations on the go. Discover all the "
                              "amazing events and happenings all around campus to keep you connected.",
                              style: TextStyle(
                                  color: ColorPrimary.withOpacity(0.7),
                                  fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ])),
                    ))
                  ]),
              Container(
                //alignment: Alignment.topRight,
                padding: EdgeInsets.only(left: 190.0, top: 140.0),
                child: Container(
                    height: 290.0,
                    width: 180.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/news_preview.png'),
                      fit: BoxFit.fill,
                    ))),
              )
            ]),

            ///PAGE 3 MAP----------------------------------------------------------
            Stack(children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height / 2 - 50,
                        decoration: new BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(
                              'assets/images/onboarding_map_background.png'),
                          fit: BoxFit.fill,
                        ))),
                    Expanded(
                        child: Container(
                      width: 350,
                      color: Colors.white,
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            Text(
                              "Find your way",
                              style: TextStyle(
                                  color: ColorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15),
                            ),
                            Text(
                              "Find nearby points of interest or go to our interactive campus map for more details about what's around you",
                              style: TextStyle(
                                  color: ColorPrimary.withOpacity(0.7),
                                  fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ])),
                    ))
                  ]),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 140.0),
                child: Container(
                    height: 290.0,
                    width: 180.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(
                          'assets/images/onboarding_map_preview.png'),
                      fit: BoxFit.fill,
                    ))),
              )
            ]),
          ],
        )),
        DotsIndicator(
          dotsCount: 3,
          position: currentIndex,
          decorator: DotsDecorator(
            activeColor: ColorPrimary,
            spacing: EdgeInsets.all(4.0)
          ),
        ),
        Container(
          height: 60,
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
                      Navigator.of(context).push(_routeToAffiliations());
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
                        Navigator.of(context).push(_routeToLogin());
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

  Route _routeToLogin() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          OnboardingLogin(),
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _routeToAffiliations() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          OnboardingAffiliations(),
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
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
