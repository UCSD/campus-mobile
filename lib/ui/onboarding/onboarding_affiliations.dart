import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_login.dart';

class OnboardingAffiliations extends StatefulWidget {
  @override
  _OnboardingAffiliationsState createState() => _OnboardingAffiliationsState();
}

class _OnboardingAffiliationsState extends State<OnboardingAffiliations> {
  bool studentSelected = false;
  bool staffSelected = false;
  bool visitorSelected = false;
  bool readyToProceed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Semantics(
        label:
            'choose your affiliation with UC San Diego. Are you a student, staff, or a visitor?',
        child: Container(
          color: ColorPrimary,
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 36.0),
                  child: Text("Your affiliation with UC San Diego",
                      style: TextStyle(
                        color: lightTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              studentSelected ? darkButtonColor : ColorPrimary,
                          shape: ContinuousRectangleBorder(
                              side: BorderSide(
                                  color: darkButtonColor,
                                  width: 1,
                                  style: BorderStyle.solid)),
                        ),
                        onPressed: () {
                          this.setState(() {
                            studentSelected = !studentSelected;
                            readyToProceed = studentSelected;
                            visitorSelected = false;
                            staffSelected = false;
                          });
                        },
                        child: Semantics(
                          button: true,
                          label: 'you\'re a UC San Diego student',
                          child: Text("Student",
                              style: TextStyle(
                                  color: studentSelected
                                      ? ColorPrimary
                                      : darkButtonColor,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              staffSelected ? darkButtonColor : ColorPrimary,
                          shape: ContinuousRectangleBorder(
                              side: BorderSide(
                                  color: darkButtonColor,
                                  width: 1,
                                  style: BorderStyle.solid)),
                        ),
                        onPressed: () {
                          this.setState(() {
                            staffSelected = !staffSelected;
                            readyToProceed = staffSelected;
                            visitorSelected = false;
                            studentSelected = false;
                          });
                        },
                        child: Semantics(
                          label: 'you\'re a UC San Diego staff or faculty',
                          child: Text("Staff/Faculty",
                              style: TextStyle(
                                  color: staffSelected
                                      ? ColorPrimary
                                      : darkButtonColor,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              visitorSelected ? darkButtonColor : ColorPrimary,
                          shape: ContinuousRectangleBorder(
                              side: BorderSide(
                                  color: darkButtonColor,
                                  width: 1,
                                  style: BorderStyle.solid)),
                        ),
                        onPressed: () {
                          this.setState(() {
                            visitorSelected = !visitorSelected;
                            readyToProceed = visitorSelected;
                            studentSelected = false;
                            staffSelected = false;
                          });
                        },
                        child: Semantics(
                          label: 'you\'re a visitor to UC San Diego',
                          child: Text("Visitor",
                              style: TextStyle(
                                  color: visitorSelected
                                      ? ColorPrimary
                                      : darkButtonColor,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 160),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: readyToProceed
                                ? darkButtonColor
                                : Color(0xFF13223A),
                            shape: ContinuousRectangleBorder(
                                side: BorderSide(
                                    color: readyToProceed
                                        ? darkButtonColor
                                        : ColorPrimary,
                                    width: 1,
                                    style: BorderStyle.solid)),
                          ),
                          onPressed: !readyToProceed
                              ? null
                              : () async {
                                  if (studentSelected || staffSelected) {
                                    Navigator.of(context).push(_createRoute());
                                  } else {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RoutePaths.BottomNavigationBar,
                                        (_) => false);
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool(
                                        'showOnboardingScreen', false);
                                  }
                                },
                          child: Semantics(
                            button: true,
                            hint:
                                'press to login with your ucsd account information related to your affiliation',
                            child: Text("Next",
                                style: TextStyle(
                                    color: readyToProceed
                                        ? ColorPrimary
                                        : Colors.grey,
                                    fontSize: 17,
                                    decoration: TextDecoration.underline)),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
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
}
