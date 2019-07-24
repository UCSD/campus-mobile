import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pointycastle/asymmetric/api.dart';
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

void doLogin(String email, String password) async {
  final publicKeyFile = await rootBundle.loadString('assets/public_key.txt');
  final rsaParser = RSAKeyParser();
  final RSAPublicKey publicKey = rsaParser.parse(publicKeyFile);

  final encrypter = Encrypter(RSA(publicKey: publicKey));
  Encrypted encryptedPassword = encrypter.encrypt(password);
  print(encryptedPassword.base64);

  final String userPassword = email + ':' + encryptedPassword.base64;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  final String base64EncodedWithEncryptedPassword =
      stringToBase64.encode(userPassword);
  String ecpIdpPackage;
  String ecpEndpoint;

  // Step 1
  // get ECP endpoint URL
  getResponseConsumerUrl('get response consumer URL', ecpTokenUrl, headerValues)
      .then((response) {
    ecpIdpPackage = response; // save for use in request to ECP
    // parse SOAP XML for 'responseConsumerURL' attribute value
    var document = xml.parse(response);

    ecpEndpoint = document
        .findAllElements('paos:Request')
        .first
        .getAttribute('responseConsumerURL')
        .toString();

    // TODO: is ecpEndpoint used?
    print(ecpEndpoint);
  });

  // TODO: call IDP_URL with credentials
  final Map<String, String> headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'Authorization': 'Basic ' + base64EncodedWithEncryptedPassword
  };
  getSamlAssertion('Get SAML Assertion', idpUrl, headers, ecpIdpPackage)
      .then((response) {
    print(response);
  });

  //
  // Step 2
  // get authenticated SAML assertion from ECP
  //
  // BEGIN node.js code
  //
  //  logger('SSO User: ' + SSO.USER.LOGIN)
  //
  //  var encryptedPass = encryptWithRsaPublicKey(SSO.USER.PASSWORD, './public_key.txt')
  //  var encodedAuthWithEncryptedPass = encodeBase64(SSO.USER.LOGIN + ':' + encryptedPass)
  //
  //  var IDP_FETCH_OPTIONS = {
  //    method: 'POST',
  //    body: SSO.ECP_INIT_IDP_PACKAGE,
  //    headers: {
  //      'Content-Type': 'text/xml; charset=utf-8',
  //      'Authorization': 'Basic ' + encodedAuthWithEncryptedPass
  //    }
  //  }
  //
  //  var resp = await fetchWithLogging('Post crafted response to IdP', SSO.IDP_URL, IDP_FETCH_OPTIONS)
  //  var responseText = await resp.text()
  //
  //  if (!resp.ok) {
  //    throw new Error('Invalid response from IdP [' + SSO.IDP_URL + ']')
  //  }
  //
  //  const doc = domParser.parseFromString(responseText)
  //
  //  const SAMLstatusCode = xpathSelect("//saml2p:Status/saml2p:StatusCode/@Value", doc, true).value
  //
  //  if (SAMLstatusCode != "urn:oasis:names:tc:SAML:2.0:status:Success") {
  //    logger("SAML STATUS: " + xpathSelect("//saml2p:Status", doc, true))
  //    throw new Error('IDP returned status was not success')
  //  }
  //
  //
  //  SSO.IDP_SAML_ASSERTION = responseText
  //  SSO.IDP_ASSERTION_CONSUMER_SERVICE_URL = xpathSelect("//ecp:Response/@AssertionConsumerServiceURL", doc, true).value
  //
  //  if (SSO.ECP_INIT_RESPONSE_CONSUMER_URL !== SSO.IDP_ASSERTION_CONSUMER_SERVICE_URL) {
  //    throw new Error(`ACS URL returned by SP (${SSO.ECP_INIT_RESPONSE_CONSUMER_URL}) does not match the one returned by the IDP (${SSO.IDP_ASSERTION_CONSUMER_SERVICE_URL})`)
  //  }
  //
  // END node.js code
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
                    color: Color(0xFF034263),
                    textColor: Colors.white,
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
