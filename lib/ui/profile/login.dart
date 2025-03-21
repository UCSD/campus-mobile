import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /// STATES
  var _passwordObscured = true;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_userDataProvider.isLoading) {
      if (_userDataProvider.isLoggedIn) {
        return buildLoggedInWidget(context);
      } else {
        return buildLoginWidget();
      }
    }

    return Container(
        constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
        child: Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary)));
  }

  Widget buildLoggedInWidget(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'You are logged in as: ',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              buildUserProfileTile(context),
            ]),
      ),
    );
  }

  /// Parses username by removing trailing spaces and characters + making all
  /// letters lowercase
  /// (necessary due to the way SSO is currently set up since it only check if
  /// the first characters of the input are a valid username, irrespective of
  /// trailing characters and capitaliation, which can lead to usernames
  /// displaying very weirdly in our app (e.g., mixed capitalizatio and random
  /// trailing characters if input in that manner))
  static String parseUsername(String username) {
    username = username.toLowerCase();
    RegExpMatch? match = RegExp(r'ucsd.edu').firstMatch(username);
    if (match != null) {
      return username.substring(0, match.end);
    } else {
      return username;
    }
  }

  Widget buildUserProfileTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      title: Text(
        _userDataProvider.userProfileModel.username != null
            ? parseUsername(_userDataProvider.userProfileModel.username!)
            : "",
        style: TextStyle(fontSize: 17),
      ),
      trailing: OutlinedButton(
        style: OutlinedButton.styleFrom(
          // primary: Theme.of(context).buttonColor,
          foregroundColor: Theme.of(context).colorScheme.background,
        ),
        child: Text('Log out'),
        onPressed: () => executeLogout(),
      ),
    );
  }

  void executeLogout() {
    _passwordTextFieldController.clear();
    _emailTextFieldController.clear();
    _userDataProvider.logout();
  }

  Widget buildLoginWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'SINGLE SIGN-ON',
            style: titleMediumLight,
          ),
          SizedBox(height: 10),
          TextField(
            style: TextStyle(
                fontFamily: 'Brix Sans',
                fontWeight: FontWeight.w400,
                color: const Color(0xFF737373)),
            decoration: InputDecoration(
              hintText: 'UCSD Email',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              border: OutlineInputBorder(),
              focusedBorder: new OutlineInputBorder(
                borderSide: new BorderSide(
                    color: Theme.of(context).colorScheme.secondary),
              ),
              labelText: 'UCSD Email',
              labelStyle: TextStyle(
                color: ucLabelColor,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            controller: _emailTextFieldController,
          ),
          SizedBox(height: 10),
          TextField(
            style: TextStyle(
                fontFamily: 'Brix Sans',
                fontWeight: FontWeight.w400,
                color: const Color(0xFF737373)),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                    // Based on passwordObscured state choose the icon
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,

                    /// TODO: Change color to improve its visibility in dark theme.
                    color:
                        Color(0xFF8B8B8B) // Theme.of(context).primaryColorDark,
                    ),
                onPressed: () => _toggle(),
              ),
              border: OutlineInputBorder(),
              focusedBorder: new OutlineInputBorder(
                borderSide: new BorderSide(
                    color: Theme.of(context).colorScheme.secondary),
              ),
              labelText: 'Password',
              labelStyle: TextStyle(
                color: ucLabelColor,
              ),
            ),
            obscureText: _passwordObscured,
            controller: _passwordTextFieldController,
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 41,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionButtonBackgroundColor,
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          fontFamily: 'Brix Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.labelLarge!.color),
                    ),
                    onPressed: _userDataProvider.isLoading
                        ? null
                        : () {
                            _userDataProvider
                                .manualLogin(_emailTextFieldController.text,
                                    _passwordTextFieldController.text)
                                .then((isLoggedIn) {
                              if (!isLoggedIn) {
                                showAlertDialog(context);
                              }
                            });
                          },
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              Expanded(
                child: GestureDetector(
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                        fontFamily: 'Brix Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).textTheme.labelLarge!.color),
                    textAlign: TextAlign.right,
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
              ),
            ],
          ),
        ],
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
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      titlePadding: EdgeInsets.fromLTRB(5, 5, 0, 0),
      contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 20),
      backgroundColor: Color(0xFFE6EFF5),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF00629B)),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Icon(Icons.info_outline),
            flex: 1,
          ),
          Expanded(
            child: Text(
              LoginConstants.loginFailedTitle,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: linkTextColorLight,
                  fontFamily: 'Brix Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18.0),
            ),
            flex: 6,
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.close),
              alignment: Alignment.topRight,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            flex: 2,
          ),
        ],
      ),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.6, // Set max height to 60% of screen height
        ),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LoginConstants.loginFailedDesc,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: linkTextColorLight,
                          fontFamily: 'Source Sans Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
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
