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
  /// STATES
  bool _passwordObscured = true;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();

  @override
  void didChangeDependencies() {
    /// TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// TODO: Remove back button since this is going to be the very first screen in the future
      appBar: AppBar(
        backgroundColor:
            lightOnboardingScreen, // Sets the background color to red
        leading: BackButton(color: Colors.white),
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: lightOnboardingScreen, // ColorPrimary, //Colors.white,
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
        constraints: BoxConstraints(maxWidth: 365),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align items at the top
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center items horizontally
            children: <Widget>[
              // UCSD Logo
              Image.asset(
                'assets/images/UCSanDiegoLogo__Blue.png',
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30.0),

              // Welcome Heading
              Text(
                "WELCOME TO THE UC SAN DIEGO MOBILE APP",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182B49), // Subheading color
                ),
              ),
              const SizedBox(height: 20),

              // Description Text
              Text(
                "Your personalized gateway to campus life, events, news and more.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  /// TODO: Get desired fonts
                  fontFamily: 'Sans',
                  fontSize: 30,
                  color: Color(0xFF5D5E60), // Foreground body color
                ),
              ),
              SizedBox(height: 30.0),

              // UCSD Email Input
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 2),
                        ]), //lightTextFieldBorderColor,
                    child: TextField(
                      style: TextStyle(
                          textBaseline: TextBaseline.alphabetic,
                          color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'UCSD Email',
                        // I'm leaving this here in case we want a black border
                        // focusedBorder: OutlineInputBorder(
                        //   /*borderSide: BorderSide(
                        //     color: Colors.black,
                        //   ),*/
                        //   borderRadius: BorderRadius.all(Radius.circular(5)),
                        // ),
                        // enabledBorder: OutlineInputBorder(
                        //   /*borderSide: BorderSide(
                        //     color: Colors.black,
                        //   ),*/
                        //   borderRadius: BorderRadius.all(Radius.circular(5)),
                        // ),
                        contentPadding: EdgeInsets.only(left: 10),
                        hintStyle: TextStyle(color: ColorPrimary),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailTextFieldController,
                    ),
                  )),
              SizedBox(height: 15),

              // Password Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 2),
                      ]),
                  child: TextField(
                    style: TextStyle(
                      textBaseline: TextBaseline.alphabetic,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
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
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      contentPadding: EdgeInsets.only(left: 10),
                      hintStyle: TextStyle(color: ColorPrimary),
                    ),
                    obscureText: _passwordObscured,
                    controller: _passwordTextFieldController,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // SIGN IN and Forgot Password?
              Row(
                children: [
                  const SizedBox(width: 10),
                  SizedBox(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCD00), // Yellow Button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Semantics(
                      button: true,
                      hint:
                          'press to login with your information inputted in above textfields',
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Colors.black, // Text color on button
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: _userDataProvider.isLoading
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
                                prefs.setBool('showOnboardingScreen', false);
                              } else {
                                showAlertDialog(context);
                              }
                            });
                          },
                  )),
                  const SizedBox(width: 145),
                  GestureDetector(
                    child: Semantics(
                      hint:
                          'press to be redirected to the UCSD Password reset page',
                      child: Text(
                        'Forgot Password?',
                        style:
                            TextStyle(color: Color(0xFF00629B)), // Light Blue
                      ),
                    ),
                    onTap: () async {
                      try {
                        /// TODO: Update link to redirect to password reset
                        String link =
                            'https://acms.ucsd.edu/students/accounts-and-passwords/index.html';
                        await launch(link, forceSafariVC: true);
                      } catch (e) {
                        // an error occurred, do nothing
                      }
                    },
                  ),
                ],
              ),

              ///////////////////////// Footer ////////////////////////////
              const SizedBox(height: 40),
              // Not affiliated text
              Text(
                "Not affiliated with UC San Diego?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5D5E60), // Foreground body color
                ),
              ),
              const SizedBox(height: 10),
              // Skip This Step
              GestureDetector(
                child: Semantics(
                  hint:
                      'press to skip the login process and use this app as a visitor',
                  child: Text(
                    "SKIP THIS STEP",
                    style: TextStyle(
                      color: Color(0xFF182B49), // Subheading color
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                onTap: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutePaths.BottomNavigationBar, (_) => false);
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool('showOnboardingScreen', false);
                },
              )
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
        foregroundColor: Theme.of(context).colorScheme.background,
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
