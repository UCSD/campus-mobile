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
  var _passwordObscured = true;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

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
    // TODO: we should look into replacing the Constrained Boxes with FractionallySizedBoxes
    return Center(
      // TODO: this specifically could be replace w/ SizedBox.expand or Unconstrained Box (need to figure out which one)
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
                width: 321.12,
              ),
              const SizedBox(height: 45.0),

              // Welcome Heading
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 261.0),//298.265),
                child: const Text(
                  "WELCOME TO THE UC SAN DIEGO MOBILE APP",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "Refrigerator Deluxe",
                    fontSize: 28.0,
                    letterSpacing: -0.2,
                    height: 0.8333, // line height: 20px
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF182B49), // Subheading color
                  ),
                ),
              ),
              const SizedBox(height: 12.5),

              // Description Text
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280),//266.267),
                child: const Text(
                  "Your personalized gateway to campus life, events, news and more.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Brix Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    letterSpacing: 2.2,
                    height: 1.2778, // line height: ~26px
                    color: const Color(0xFF182B49), // Foreground body color
                  ),
                ),
              ),
              const SizedBox(height: 30.0),

              // UCSD Email Input
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    height: 44.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        //borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              spreadRadius: 2.0,
                              offset: const Offset(2.0, 2.0)),
                        ]), //lightTextFieldBorderColor,
                    child: TextField(
                      style: TextStyle(
                          textBaseline: TextBaseline.alphabetic,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0,
                          height: 1.277, // line height: 23px
                          letterSpacing: 1.2),
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
              SizedBox(height: 18.5),

              // Password Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 44.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      //borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2.0,
                            offset: const Offset(2.0, 2.0)),
                      ]),
                  child: TextField(
                    style: TextStyle(
                        textBaseline: TextBaseline.alphabetic,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                        height: 1.277,
                        letterSpacing: 1.2),
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
              SizedBox(height: 24),

              // SIGN IN and Forgot Password?
              Row(
                children: [
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 94,
                      height: 41,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFCD00), // Yellow Button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0.0,
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
                                    prefs.setBool(
                                        'showOnboardingScreen', false);
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                      )),
                  const Spacer(),
                  //const SizedBox(width: 145),
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
                  SizedBox(width: 10.0)
                ],
              ),

              ///////////////////////// Footer ////////////////////////////
              const SizedBox(height: 40),
              // Not affiliated text
              Text(
                "Not affiliated with UC San Diego?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.42, // line height: 20px
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
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5,
                      height: 1.195, // line height: 16.73px
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
