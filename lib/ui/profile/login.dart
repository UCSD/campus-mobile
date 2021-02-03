import 'package:campus_mobile_experimental/app_constants.dart';
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
  UserDataProvider _userDataProvider;
  bool _passwordObscured = true;

  @override
  void didChangeDependencies() {
    print('_LoginState:didChangeDependencies');
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context);
    print('_userDataProvider1:');
    print(_userDataProvider.userProfileModel.toJson());
  }

  @override
  Widget build(BuildContext context) {
    print('_LoginState:build: --------------------- 1');
    if (!_userDataProvider.isLoading) {
      print('_LoginState:build:isLoading FALSE --------------------- 2');
      if (_userDataProvider.isLoggedIn) {
        print('_LoginState:build:isLoggedIn TRUE ------------------- 3');
        return buildLoggedInWidget(context);
      } else {
        print('_LoginState:build: --------------------- 4');
        return buildLoginWidget();
      }
    }

    return Container(
        constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
        child: Center(child: CircularProgressIndicator()));
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
    if (_userDataProvider.userProfileModel.username != null) {
      print('_LoginState:buildUserProfileTile:username: FOUND');
    } else {
      print('_LoginState:buildUserProfileTile:username: NULL');
    }

    var username1 = Provider.of<UserDataProvider>(context, listen: false)
        .userProfileModel
        .username;
    print('username1:-------------------------');
    print(username1);

    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      title: Text(
        _userDataProvider.userProfileModel.username != null
            ? _userDataProvider.userProfileModel.username
            : "",
        style: TextStyle(fontSize: 17),
      ),
      trailing: OutlineButton(
        child: Text('logout'),
        onPressed: () => _userDataProvider.logout(),
      ),
    );
  }

  Widget buildLoginWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Single Sign-On'),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'UCSD Email',
                border: OutlineInputBorder(),
                labelText: 'UCSD Email',
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailTextFieldController,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordObscured state choose the icon
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () => _toggle(),
                ),
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: _passwordObscured,
              controller: _passwordTextFieldController,
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Text('Sign In'),
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
                    color: Theme.of(context).buttonColor,
                    textColor: Theme.of(context).textTheme.button.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
                child: GestureDetector(
              child: Text('Need help logging in?'),
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
