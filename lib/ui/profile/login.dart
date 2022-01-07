import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  late UserDataProvider _userDataProvider;
  bool _passwordObscured = true;

  @override
  void didChangeDependencies() {
    print('_LoginState:didChangeDependencies');
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_userDataProvider.isLoading!) {
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

  Widget buildUserProfileTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      title: Text(
        _userDataProvider.userProfileModel!.username != null
            ? _userDataProvider.userProfileModel!.username!
            : "",
        style: TextStyle(fontSize: 17),
      ),
      trailing: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Theme.of(context).buttonColor,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Single Sign-On',
              style: TextStyle(fontSize: 17),
            ),
            SizedBox(height: 10),
            TextField(
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
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordObscured state choose the icon
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).primaryColorDark,
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).buttonColor,
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.button!.color),
                    ),
                    onPressed: _userDataProvider.isLoading!
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
              ],
            ),
            Center(
                child: GestureDetector(
              child: Container(
                height: 35,
                child: Center(
                  child: Text(
                    'Need help logging in?',
                    style: TextStyle(fontSize: 16),
                  ),
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
            )),
          ],
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
        primary: Theme.of(context).buttonColor,
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
