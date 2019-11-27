import 'package:campus_mobile_experimental/core/models/authentication_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class AuthenticationService extends ChangeNotifier {
  AuthenticationService();
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  AuthenticationModel _data;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint =
      "https://3hepzvdimd.execute-api.us-west-2.amazonaws.com/dev/v1/access-profile";
  final String AUTH_SERVICE_API_KEY =
      'eKFql1kJAj53iyU2fNKyH4jI2b7t70MZ5YbAuPBZ';

  login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    print("SSO login initiated for user: $email");

    // TODO: import assets/public_key.txt
    final String pkString = '-----BEGIN PUBLIC KEY-----\n' +
        'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n' +
        'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n' +
        'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n' +
        'CaCUGqS6FN1nNKARGwIDAQAB\n' +
        '-----END PUBLIC KEY-----';

    try {
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

      /// fetch data
      String response =
          await _networkHelper.authorizedPost(endpoint, authServiceHeaders);

      /// parse data
      final authenticationModel = authenticationModelFromJson(response);
      print(authenticationModel.toJson().toString());
      _isLoading = false;

      _data = data;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  AuthenticationModel get data => _data;
  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  NetworkHelper get availabilityService => _networkHelper;
}
