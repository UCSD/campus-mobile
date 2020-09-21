import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingLogin extends StatefulWidget {
  @override
  _OnboardingLoginState createState() => _OnboardingLoginState();
}

class _OnboardingLoginState extends State<OnboardingLogin> {
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  UserDataProvider _userDataProvider;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      backgroundColor: lightPrimaryColor, // ColorPrimary, //Colors.white,
      body: _userDataProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(lightAccentColor),
              ),
            )
          : buildLoginWidget(),
    );
  }

  Widget buildLoginWidget() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
              fit: BoxFit.contain,
              height: 50,
              color: Colors.white,
            ),
            SizedBox(height: 100.0),
            Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      color: Theme.of(context)
                          .accentColor), //lightTextFieldBorderColor,
                  child: TextField(
                    style: TextStyle(
                        textBaseline: TextBaseline.alphabetic,
                        color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'UCSD Email',
                      focusedBorder: OutlineInputBorder(
                        /*borderSide: BorderSide(
                          color: Colors.black,
                        ),*/
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        /*borderSide: BorderSide(
                          color: Colors.black,
                        ),*/
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      contentPadding: EdgeInsets.only(left: 10),
                      hintStyle: TextStyle(color: ColorPrimary),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailTextFieldController,
                  ),
                )),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  color: Theme.of(context).accentColor),
              child: TextField(
                style: TextStyle(
                  textBaseline: TextBaseline.alphabetic,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Password',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  contentPadding: EdgeInsets.only(left: 10),
                  hintStyle: TextStyle(color: ColorPrimary),
                  fillColor: Colors.white,
                  filled: true,
                ),
                obscureText: true,
                controller: _passwordTextFieldController,
              ),
            ),
            SizedBox(height: 40),
            Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.white),
                      ),
                      color: ColorPrimary,
                      textColor: lightButtonTextColor,
                      //child: OutlineButton(
                      //borderSide: BorderSide(color: ColorPrimary),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: _userDataProvider.isLoading
                          ? null
                          : () {
                              _userDataProvider
                                  .login(_emailTextFieldController.text,
                                      _passwordTextFieldController.text)
                                  .then((isLoggedIn) async {
                                if (isLoggedIn) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      RoutePaths.BottomNavigationBar,
                                      (_) => false);
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('showOnboardingScreen', false);
                                } else {
                                  showAlertDialog(context);
                                }
                              });
                            },

                      // ),
                    )),
                  ],
                )),
            SizedBox(height: 5),
            Row(
              children: [
                GestureDetector(
                  child: Text(
                    'Need help logging in?',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onTap: () async {
                    try {
                      String link =
                          'https://acms.ucsd.edu/students/accounts-and-passwords/index.html';
                      await launch(link, forceSafariVC: true);
                    } catch (e) {
                      // an error occurred, do nothing
                    }
                  },
                ),

                /* GestureDetector(
                  child: Text(
                    'Skip',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context,
                        RoutePaths.BottomNavigationBar, (_) => false);
                  },
                )*/
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ],
        ),
      ),
    );
  }

  Widget showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Sorry, unable to sign you in"),
      content: Text(
          "Be sure you are using the correct credentials; TritonLink login if you are a student, SSO if you are Faculty/Staff."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
