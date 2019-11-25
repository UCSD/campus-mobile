import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

// TODO: Move to remote config
const String AUTH_SERVICE_API_URL =
    'https://3hepzvdimd.execute-api.us-west-2.amazonaws.com/dev/v1/access-profile';
// TODO: Move to Codemagic and generate new key
const String AUTH_SERVICE_API_KEY = 'eKFql1kJAj53iyU2fNKyH4jI2b7t70MZ5YbAuPBZ';

// TODO: Setup as a standalone service
Future<String> mobileAuthService(String url, Map<String, String> options) async {
  final response = await http.post(url, headers: options);

  if (response.statusCode == 200) {
    // If server returns an OK response, return the response body
    return response.body;
  } else {
    // If that response was not OK, throw an error.
    if (response.body == null) {
      throw Exception('An unknown error occurred.');
    } else {
      throw Exception(response.body);
    }
  }
}

void doLogin(String email, String password) async {
  print("SSO login initiated for user: $email");

  // TODO: import assets/public_key.txt
  final String pkString = '-----BEGIN PUBLIC KEY-----\n' +
      'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n' +
      'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n' +
      'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n' +
      'CaCUGqS6FN1nNKARGwIDAQAB\n' +
      '-----END PUBLIC KEY-----';

  final rsaParser = RSAKeyParser();
  final pc.RSAPublicKey publicKey = rsaParser.parse(pkString);
  var cipher = OAEPEncoding(pc.AsymmetricBlockCipher('RSA'));
  pc.AsymmetricKeyParameter<pc.RSAPublicKey> keyParametersPublic =
      new pc.PublicKeyParameter(publicKey);
  cipher.init(true, keyParametersPublic);
  Uint8List output = cipher.process(utf8.encode(password));
  var base64EncodedText = base64.encode(output);
  final String base64EncodedWithEncryptedPassword =
      base64.encode(utf8.encode(email + ':' + base64EncodedText));
  final Map<String, String> authServiceHeaders = {
    'x-api-key': AUTH_SERVICE_API_KEY,
    'Authorization': base64EncodedWithEncryptedPassword,
  };
  final response =
      await mobileAuthService(AUTH_SERVICE_API_URL, authServiceHeaders);
  debugPrint(response);

  // TODO: Setup authentication model
  // TODO: Make available to provider
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                hintText: 'Email',
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailTextFieldController,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
              controller: _passwordTextFieldController,
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Text('Sign In'),
                    onPressed: () {
                      doLogin(_emailTextFieldController.text,
                          _passwordTextFieldController.text);
                    },
                    color: Theme.of(context).buttonColor,
                    textColor: Theme.of(context).textTheme.button.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(child: Text('Need help logging in?')),
          ],
        ),
      ),
    );
  }
}
