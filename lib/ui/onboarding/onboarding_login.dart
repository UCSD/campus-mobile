import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late UserDataProvider _userDataProvider;
  bool _passwordObscured = true;

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
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: lightPrimaryColor, // ColorPrimary, //Colors.white,
      body: _userDataProvider.isLoading!
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
        child: SingleChildScrollView(
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
                            .colorScheme
                            .secondary), //lightTextFieldBorderColor,
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
                    color: Theme.of(context).colorScheme.secondary),
                child: TextField(
                  style: TextStyle(
                    textBaseline: TextBaseline.alphabetic,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: Semantics(
                      hint:
                          'press to toggle the visibility of your password field',
                      child: IconButton(
                        icon: Icon(
                          // Based on passwordObscured state choose the icon
                          _passwordObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () => _toggle(),
                      ),
                    ),
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
                  obscureText: _passwordObscured,
                  controller: _passwordTextFieldController,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.white),
                          ),
                          primary: ColorPrimary,
                          textStyle: TextStyle(
                            color: lightButtonTextColor,
                          ),
                          //child: OutlineButton(
                          //borderSide: BorderSide(color: ColorPrimary),
                        ),
                        child: Semantics(
                          button: true,
                          hint:
                              'press to login with your information inputted in above textfields',
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        onPressed: _userDataProvider.isLoading!
                            ? null
                            : () {
                                _userDataProvider
                                    .manualLogin(_emailTextFieldController.text,
                                        _passwordTextFieldController.text)
                                    .then((isLoggedIn) async {
                                  if (isLoggedIn) {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RoutePaths.BottomNavigationBar,
                                        (_) => false);
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool(
                                        'showOnboardingScreen', false);
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },

                        // ),
                      )),
                    ],
                  )),
              SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    child: Semantics(
                      hint:
                          'press to open service now webpage to read about frequently asked question for login process',
                      child: Text(
                        'Need help logging in?',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
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
                  GestureDetector(
                    child: Semantics(
                      hint:
                          'press to skip the login process and use this app as a visitor',
                      child: Text(
                        'Skip',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pushNamedAndRemoveUntil(context,
                          RoutePaths.BottomNavigationBar, (_) => false);
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('showOnboardingScreen', false);
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _passwordObscured = !_passwordObscured;
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(context).backgroundColor,
      ),
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(LoginConstants.loginFailedTitle),
      content: Text(LoginConstants.loginFailedDesc),
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
