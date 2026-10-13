import 'dart:math' as math;
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const _CONTENT_WIDTH_FACTOR = 0.74444444;
  static const _SIGN_IN_BUTTON_WIDTH_FACTOR = 0.24111111;
  static const _SIGN_IN_BUTTON_ASPECT = 2.29268293;
  static const _HEADING_FONT_FLOOR = 34.5;
  static const _HEADING_FONT_FACTOR = 0.077;
  static const _BODY_FONT_FLOOR = 18.0;
  static const _BODY_FONT_FACTOR = 0.0402;
  static const _FOOTER_FONT_FLOOR = 15.5;
  static const _FOOTER_FONT_FACTOR = 0.0346;
  static const _SKIP_FONT_FLOOR = 16.5;
  static const _SKIP_FONT_FACTOR = 0.0368;

  double _contentUnit(double width, double usableHeight) {
    final cap = width < 600
        ? 480.0
        : width < 900
            ? 560.0
            : width < 1200
                ? 620.0
                : 680.0;
    return math.min(width, math.min(usableHeight / 1.6, cap));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userDataProvider = context.watch();
  }

  @override
  Widget build(BuildContext context) =>
      // This improves colors and styling of the status bar text
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light, // for iOS
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: lightOnboardingScreen,
          body: _userDataProvider.isLoading
              ? const Center(
                  child: const CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(darkAccentColor),
                  ),
                )
              : MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset('assets/images/login-background.png', fit: BoxFit.cover),
                      ),
                      SafeArea(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = MediaQuery.sizeOf(context);
                            final viewPadding = MediaQuery.viewPaddingOf(context);
                            final usableHeight = size.height - viewPadding.top - viewPadding.bottom;
                            final u = _contentUnit(constraints.maxWidth, usableHeight);
                            return SingleChildScrollView(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                    maxWidth: u,
                                  ),
                                  child: IntrinsicHeight(child: _buildLoginWidget(u)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );

  Widget _buildLoginWidget(double u) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Align items at the top
      crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
      children: <Widget>[
        const Spacer(flex: 3),

        // UCSD Logo
        Flexible(
          flex: 0,
          child: FractionallySizedBox(
            widthFactor: 0.78055556,
            child: Image.asset('assets/images/UCSanDiegoLogo-Blue.png'),
          ),
        ),
        SizedBox(height: math.max(44.0, 0.0982 * u)),

        // Welcome Heading
        Flexible(
          flex: 0,
          child: FractionallySizedBox(
            widthFactor: 0.725,
            child: Text(
              "WELCOME TO THE UC SAN DIEGO MOBILE APP",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Refrigerator Deluxe",
                fontSize: math.max(_HEADING_FONT_FLOOR, _HEADING_FONT_FACTOR * u),
                height: 0.9333, // line height: 20px
                fontWeight: FontWeight.w900,
                color: const Color(0xFF182B49), // Subheading color
              ),
            ),
          ),
        ),
        SizedBox(height: math.max(12.5, 0.0279 * u)),

        // Description Text
        Flexible(
          flex: 0,
          child: FractionallySizedBox(
            widthFactor: 0.64722222,
            child: Text(
              // TODO: the font here seems a bit light. Might need to swap that out later - December 2025
              "Your personalized gateway to campus life, events, news and more.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Brix Sans',
                fontWeight: FontWeight.w400,
                fontSize: math.max(_BODY_FONT_FLOOR, _BODY_FONT_FACTOR * u),
                letterSpacing: 2.2,
                height: 1.2778, // line height: ~26px
                color: const Color(0xFF182B49), // Foreground body color
              ),
            ),
          ),
        ),
        SizedBox(height: math.max(35.0, 0.0781 * u)),

        // UCSD Email Input
        _buildEmailField(u),
        SizedBox(height: math.max(18.5, 0.0413 * u)),

        // Password Input
        _buildPasswordField(u),
        SizedBox(height: math.max(20.0, 0.0446 * u)),

        // SIGN IN and Forgot Password?
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: u * ((1 - _CONTENT_WIDTH_FACTOR) / 2) + 6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCD00), // Yellow Button
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0.0,
                  fixedSize: () {
                    // calculate width using scaling ratio, then calculate height from width using aspect ratio
                    final width = u * _SIGN_IN_BUTTON_WIDTH_FACTOR;
                    final height = width / _SIGN_IN_BUTTON_ASPECT;
                    return Size(width, height);
                  }(),
                ),
                child: Semantics(
                  button: true,
                  hint: 'press to login with your information inputted in above textfields',
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontFamily: 'Brix Sans',
                      fontSize: math.max(_BODY_FONT_FLOOR, _BODY_FONT_FACTOR * u),
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
                            .manualLogin(_emailTextFieldController.text, _passwordTextFieldController.text)
                            .then((isLoggedIn) async {
                              if (isLoggedIn) {
                                Navigator.pushNamedAndRemoveUntil(context, RoutePaths.ONBOARDING_INITIAL, (_) => false);
                              } else {
                                showAlertDialog(context);
                              }
                            });
                      },
              ),
            ),

            // the spacer in between sign in and forgot password
            // SizedBox(width: _screenWidth * 0.202),
            Padding(
              padding: EdgeInsets.only(right: u * ((1 - _CONTENT_WIDTH_FACTOR) / 2) + 6),
              child: GestureDetector(
                child: Semantics(
                  hint: 'press to be redirected to the UCSD Password reset page',
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: const Color(0xFF00629B),
                      height: 1.42857143,
                      decoration: TextDecoration.underline,
                      fontSize: math.max(_BODY_FONT_FLOOR, _BODY_FONT_FACTOR * u),
                    ), // Light Blue
                  ),
                ),
                onTap: () async {
                  try {
                    // TODO: Update link to redirect to password reset - December 2025
                    String link = 'https://acms.ucsd.edu/students/accounts-and-passwords/index.html';
                    await launchUrl(Uri.parse(link), mode: LaunchMode.inAppBrowserView);
                  } catch (e) {
                    // an error occurred, do nothing
                  }
                },
              ),
            ),
          ],
        ),

        ///////////////////////// Footer ////////////////////////////
        const Spacer(flex: 2),

        // Not affiliated text
        Text(
          "Not affiliated with UC San Diego?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: math.max(_FOOTER_FONT_FLOOR, _FOOTER_FONT_FACTOR * u),
            height: 1.42, // line height: 20px
            color: const Color(0xFF5D5E60), // Foreground body color
          ),
        ),
        SizedBox(height: math.max(12.0, 0.0268 * u)),

        // Skip This Step
        GestureDetector(
          child: Semantics(
            hint: 'press to skip the login process and use this app as a visitor',
            child: Text(
              "SKIP THIS STEP",
              style: TextStyle(
                color: const Color(0xFF182B49), // Subheading color
                fontFamily: 'Brix Sans',
                fontWeight: FontWeight.w700,
                fontSize: math.max(_SKIP_FONT_FLOOR, _SKIP_FONT_FACTOR * u),
                height: 1.195, // line height: 16.73px
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          onTap: () async {
            Navigator.pushNamedAndRemoveUntil(context, RoutePaths.ONBOARDING_INITIAL, (_) => false);
          },
        ),

        const Spacer(),
      ],
    ),
  );

  // TODO: change the font for the password field (it's a lighter gray than what is currently there) - December 2025
  static Widget _buildInputField(
    InputDecoration decoration,
    TextEditingController controller, {
    required double u,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          const BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2.0, offset: const Offset(2.0, 2.0)),
        ],
      ),
      child: FractionallySizedBox(
        widthFactor: _CONTENT_WIDTH_FACTOR,
        child: TextField(
          style: TextStyle(
            fontFamily: 'Brix Sans',
            textBaseline: TextBaseline.alphabetic,
            color: const Color(0xFF182B49), // Fixed color format with full opacity
            fontWeight: FontWeight.w400,
            fontSize: math.max(_BODY_FONT_FLOOR, _BODY_FONT_FACTOR * u),
            height: 1.277, // line height: 23px
            letterSpacing: 1.2,
          ),
          decoration: decoration,
          keyboardType: keyboardType,
          controller: controller,
          obscureText: obscureText,
        ),
      ),
    ),
  );

  Widget _buildEmailField(double u) => _buildInputField(
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
      hintStyle: const TextStyle(color: Color(0xFF6A6B6D)),
    ),
    _emailTextFieldController,
    u: u,
    keyboardType: TextInputType.emailAddress,
  );

  Widget _buildPasswordField(double u) => _buildInputField(
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
          onPressed: _toggle,
        ),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.only(left: 10, top: 7.0, bottom: 7.0),
      hintStyle: const TextStyle(color: Color(0xFF6A6B6D)),
    ),
    _passwordTextFieldController,
    u: u,
    obscureText: _passwordObscured,
  );

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _passwordObscured = !_passwordObscured;
    });
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialogWidget(
        type: MessageTypeConstants.ERROR,
        icon: Icons.error_outline,
        title: LoginConstants.LOGIN_FAILED_TITLE,
        description: LoginConstants.LOGIN_FAILED_DESC,
        onClose: () {
          Navigator.of(context).pop(); // Close the dialog
        },
      ),
    );
  }
}
