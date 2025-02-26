import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: lightOnboardingScreen, // ColorPrimary, //Colors.white,
      body: _userDataProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(lightAccentColor),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/images/login-background.png"),
                  fit:
                      BoxFit.cover, // Ensure the image covers the entire screen
                ),
              ),
              child: _buildLoginWidget(),
            ),
    );
  }

  Widget _buildLoginWidget() {
    // TODO: we should look into replacing the Constrained Boxes with FractionallySizedBoxes
    return SafeArea(
        child: Center(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Align items at the top
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center items horizontally
          children: <Widget>[
            const Spacer(flex: 3),
            // UCSD Logo
            Flexible(
              flex: 0,
              child: FractionallySizedBox(
                widthFactor: 0.78055556, //0.76986301,
                child: Image.asset(
                  //fit: BoxFit.fill,
                  'assets/images/UCSanDiegoLogo-Blue.png',
                ),
              ),
            ),
            //const SizedBox(height: 44.0),
            ConstrainedBox(constraints: const BoxConstraints(minHeight: 44.0)),

            // Welcome Heading
            // ConstrainedBox(
            //   constraints: const BoxConstraints(maxWidth: 261.0),//298.265),
            const Flexible(
              flex: 0,
              child: const FractionallySizedBox(
                  widthFactor: 0.725,
                  child: const Text(
                    "WELCOME TO THE UC SAN\nDIEGO MOBILE APP",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "Refrigerator Deluxe",
                      fontSize: 34.5,
                      height: 0.9333, // line height: 20px
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF182B49), // Subheading color
                    ),
                  )),
            ),
            const SizedBox(height: 12.5),

            // Description Text
            // ConstrainedBox(
            //   constraints: const BoxConstraints(maxWidth: 280),//266.267),
            const Flexible(
                flex: 0,
                child: const FractionallySizedBox(
                  widthFactor: 0.64722222,
                  child: const Text(
                    // TODO: the font here seems a bit light. Might need to swap that out later
                    "Your personalized gateway to campus life, events, news and more.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Brix Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      letterSpacing: 2.2,
                      height: 1.2778, // line height: ~26px
                      color: const Color(0xFF182B49), // Foreground body color
                    ),
                  ),
                )),
            ConstrainedBox(constraints: const BoxConstraints(minHeight: 35.0)),

            // TODO: figure out if the two following SizedBoxes should be replaced with ConstrainedBoxes for better scaling

            // UCSD Email Input
            _buildEmailField(),
            const SizedBox(height: 18.5),

            // Password Input
            _buildPasswordField(),
            const SizedBox(height: 20.0),

            // SIGN IN and Forgot Password?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCD00), // Yellow Button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0.0,
                    fixedSize: () {
                      // calculate width using scaling ratio, then calculate height from width using aspect ratio
                      final width =
                          MediaQuery.sizeOf(context).width * 0.24111111;
                      final height = width / 2.29268293;
                      return Size(width, height);
                    }(),
                    //padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0)
                  ),
                  child: Semantics(
                    button: true,
                    hint:
                        'press to login with your information inputted in above textfields',
                    child: Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontFamily: 'Brix Sans',
                        fontSize: 15.0,
                        height: 1.195,
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
                              Navigator.pushNamedAndRemoveUntil(context,
                                  RoutePaths.OnboardingInitial, (_) => false);
                            } else {
                              showAlertDialog(context);
                            }
                          });
                        },
                ),
                // the spacer in between sign in and forgot password
                SizedBox(width: MediaQuery.of(context).size.width * 0.202),

                GestureDetector(
                  child: Semantics(
                    hint:
                        'press to be redirected to the UCSD Password reset page',
                    child: const Text(
                      'Forgot Password?',
                      style: const TextStyle(
                        color: const Color(0xFF00629B),
                        height: 1.42857143,
                        //fontFamily: "Source Sans Pro" // this doesn't seem to be doing anything, so disabling for now
                      ), // Light Blue
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
            //ConstrainedBox(constraints: const BoxConstraints(minHeight: 76.0)),
            const Spacer(flex: 2),
            // Not affiliated text
            const Text(
              "Not affiliated with UC San Diego?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.42, // line height: 20px
                color: const Color(0xFF5D5E60), // Foreground body color
              ),
            ),
            const SizedBox(height: 12.0),
            // Skip This Step
            GestureDetector(
              child: Semantics(
                hint:
                    'press to skip the login process and use this app as a visitor',
                child: const Text(
                  "SKIP THIS STEP",
                  style: const TextStyle(
                    color: const Color(0xFF182B49), // Subheading color
                    fontFamily: 'Brix Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                    height: 1.195, // line height: 16.73px
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              onTap: () async {
                Navigator.pushNamedAndRemoveUntil(
                    context, RoutePaths.OnboardingInitial, (_) => false);
              },
            ),
            const Spacer()
          ],
        ),
      ),
    ));
  }

  // TODO: change the font for the password field (it's a lighter gray than what is currently there)
  Widget _buildInputField(
          InputDecoration decoration, TextEditingController controller,
          {TextInputType? keyboardType, bool obscureText = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                //borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 2.0,
                      offset: const Offset(2.0, 2.0)),
                ]), //lightTextFieldBorderColor,
            child: Flexible(
                child: FractionallySizedBox(
                    widthFactor: 0.74444444,
                    child: TextField(
                      style: const TextStyle(
                          fontFamily: 'Brix Sans',
                          textBaseline: TextBaseline.alphabetic,
                          color: const Color(
                              0xFF737373), // TODO: figure out why color is being ignored
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0,
                          height: 1.277, // line height: 23px
                          letterSpacing: 1.2),
                      decoration: decoration,
                      keyboardType: keyboardType,
                      controller: controller,
                      obscureText: obscureText,
                    ))),
          ));

  Widget _buildEmailField() => _buildInputField(
      const InputDecoration(
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
        isDense: true,
        contentPadding: const EdgeInsets.only(left: 10, top: 7.0, bottom: 7.0),
        hintStyle: const TextStyle(color: ColorPrimary),
      ),
      _emailTextFieldController,
      keyboardType: TextInputType.emailAddress);

  Widget _buildPasswordField() => _buildInputField(
      InputDecoration(
        border: InputBorder.none,
        hintText: 'Password',
        suffixIconConstraints: const BoxConstraints(minWidth: 2, minHeight: 2),
        suffixIcon: Semantics(
          hint: 'press to toggle the visibility of your password field',
          child: IconButton(
            icon: Icon(
              _passwordObscured ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColorDark,
            ),
            padding: const EdgeInsets.only(right: 10), // Remove padding
            constraints: const BoxConstraints(), // Remove constraints
            onPressed: () =>
                _toggle(), // TODO: figure out if this is unnecessarily double nesting callbacks
          ),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.only(left: 10, top: 7.0, bottom: 7.0),
        hintStyle: const TextStyle(color: ColorPrimary),
      ),
      _passwordTextFieldController,
      obscureText: _passwordObscured);

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _passwordObscured = !_passwordObscured;
    });
  }

  void showAlertDialog(BuildContext context) {
    // set up the button
    final okButton = TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        foregroundColor: Theme.of(context).colorScheme.background,
      ),
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    final alert = AlertDialog(
      title: const Text(LoginConstants.loginFailedTitle),
      content: const Text(LoginConstants.loginFailedDesc),
      actions: [okButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
}
