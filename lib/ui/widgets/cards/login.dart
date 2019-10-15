import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'package:xml/xml.dart' as xml;

// QA Environment
const String idpUrl =
    'https://a5-stage.ucsd.edu:443/tritON/profile/SAML2/SOAP/ECP';
const String ecpTokenUrl = 'https://wso2is-qa.ucsd.edu/ecptoken/token';
const String clientId = 'fdKucQk8__ZXvEKMFfx4CJiWvCka';
const Map<String, String> headerValues = {
  'Content-Type': 'application/x-www-form-urlencoded',
  'Accept': 'text/html; application/vnd.paos+xml',
  'PAOS':
      'ver="urn:liberty:paos:2003-08";"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp"',
};

Future<String> getResponseConsumerUrl(
    String msg, String url, Map<String, String> options) async {
  print(msg);
  final response =
      await http.post(url, headers: options, body: {'client_id': clientId});

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the XML.

    return response.body;
  } else {
    // If that response was not OK, throw an error.
    print(response.statusCode);
    print(response.body);
    throw Exception('Failed to load call');
  }
}

Future<String> getSamlAssertion(String msg, String url,
    Map<String, String> options, String ecpIdpPackage) async {
  print(msg);
//  print(url);
//  debugPrint('*** ' + ecpIdpPackage);
//  print('***');

  final response = await http.post(url, headers: options, body: ecpIdpPackage);

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the XML
    return response.body;
  } else {
    // If that response was not OK, throw an error.
    print(response.statusCode);
    print(response.body);
    throw Exception('Failed to load call');
  }
}

void printWrapped(String text) {
  final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

void doLogin(String email, String password) async {
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

  String ecpIdpPackage;
  String ecpEndpoint;

  // Step 1
  // get ECP endpoint URL
  getResponseConsumerUrl('get response consumer URL', ecpTokenUrl, headerValues)
      .then((response) {
    ecpIdpPackage = response; // save for use in request to ECP

    // Note: ecpIdpPackage looks correct
    //
    // parse SOAP XML for 'responseConsumerURL' attribute value
    var document = xml.parse(response);

    ecpEndpoint = document
        .findAllElements('paos:Request')
        .first
        .getAttribute('responseConsumerURL')
        .toString();

    // TODO: is ecpEndpoint used?

    // structure of call is correct
    final Map<String, String> headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'Authorization': 'Basic ' + base64EncodedWithEncryptedPassword
    };
    getSamlAssertion('Get SAML Assertion', idpUrl, headers, ecpIdpPackage)
        .then((response) {
      debugPrint('***');
      debugPrint(idpUrl);
      debugPrint(headers.toString());
      debugPrint(ecpIdpPackage);
      debugPrint('response: ' + response);
      debugPrint('***');
    });
  });
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
