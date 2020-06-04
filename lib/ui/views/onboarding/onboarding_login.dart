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
              child: CircularProgressIndicator(),
            )
          : buildLoginWidget(),
    );
  }

  Widget buildLoginWidget() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
              fit: BoxFit.contain,
              height: 50,
            ),
          ),
          SizedBox(height: 100),
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
                  contentPadding: EdgeInsets.only(left: 10),
                  hintStyle: TextStyle(height:1.0, color: darkAccentColor),
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
                  contentPadding: EdgeInsets.only(left: 10),
                  hintStyle: TextStyle(color: darkAccentColor, height: 1.0),
                  fillColor: Colors.white,
                  filled: true
                ),
                obscureText: true,
                controller: _passwordTextFieldController,
              ),
            ),
          ),
          SizedBox(height: 10),
          Flexible(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlineButton(
                    borderSide: BorderSide(color: lightButtonBorderColor),
                    child: Text('Sign In'),
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
                    style: TextStyle(color: lightButtonTextColor),
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
                    style: TextStyle(color: lightButtonTextColor),
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
