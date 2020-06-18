import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: ColorPrimary,
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
        constraints: BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Image.asset(
                'assets/images/UCSanDiegoLogo-nav.png',
                fit: BoxFit.contain,
                height: 50,
              ),
            ),
            SizedBox(height: 80),
            Flexible(
              child: Container(
                color: Theme.of(context).accentColor, // lightTextFieldBorderColor,
                child: TextField(
                  style: TextStyle(
                      textBaseline: TextBaseline.alphabetic,
                      color: Colors.black
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                    hintStyle: TextStyle(color: darkAccentColor),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailTextFieldController,
                ),
              ),
            ),
            SizedBox(height: 10),
            Flexible(
              child: Container(
                color: Theme.of(context).accentColor, // lightTextFieldBorderColor,
                child: TextField(
                  style: TextStyle(
                    textBaseline: TextBaseline.alphabetic,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      ),
                      contentPadding: EdgeInsets.only(left: 10),
                      hintStyle: TextStyle(color: darkAccentColor),
                      fillColor: Colors.white,
                      filled: true
                  ),
                  obscureText: true,
                  controller: _passwordTextFieldController,
                ),
              ),
            ),
            SizedBox(height: 20),
            Flexible(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlineButton(
                      borderSide: BorderSide(color: lightButtonBorderColor),
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _userDataProvider.isLoading
                          ? null
                          : () {
                        _userDataProvider
                            .login(_emailTextFieldController.text,
                            _passwordTextFieldController.text)
                            .then((isLoggedIn) {
                          if (isLoggedIn) {
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                RoutePaths.BottomNavigationBar,
                                    (_) => false);
                          } else {
                            showAlertDialog(context);
                          }
                        });
                      },
                      textColor: lightButtonTextColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Flexible(
              child: Row(
                children: [
                  GestureDetector(
                    child: Text(
                      'Need help logging in?',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      String link =
                          'https://acms.ucsd.edu/students/accounts-and-passwords/index.html';
                      if (await canLaunch(link)) {
                        await launch(link);
                      }
                    },
                  ),
                  GestureDetector(
                    child: Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RoutePaths.BottomNavigationBar, (_) => false);
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
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
