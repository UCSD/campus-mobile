import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          Image.asset(
            'assets/images/UCSanDiegoLogo-nav.png',
            fit: BoxFit.contain,
            height: 50,
          ),
          SizedBox(height: 100),
          Container(
            color: lightTextFieldBorderColor,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'User ID',
                contentPadding: EdgeInsets.only(left: 10),
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailTextFieldController,
            ),
          ),
          SizedBox(height: 10),
          Container(
            color: lightTextFieldBorderColor,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                contentPadding: EdgeInsets.only(left: 10),
              ),
              obscureText: true,
              controller: _passwordTextFieldController,
            ),
          ),
          SizedBox(height: 10),
          Row(
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
                              Navigator.pushNamedAndRemoveUntil(context,
                                  RoutePaths.BottomNavigationBar, (_) => false);
                            }
                          });
                        },
                  textColor: lightButtonTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                child: Text(
                  'Need help logging in?',
                  style: TextStyle(color: lightButtonTextColor),
                ),
                onTap: () {
                  /// TODO
                  /// navigate user to external link that helps them log in
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
        ],
      ),
    );
  }
}
