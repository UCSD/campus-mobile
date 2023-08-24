import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

final _storage = FlutterSecureStorage();

/// Save encrypted password to device
void _saveEncryptedPasswordToDevice(String encryptedPassword) {
  _storage.write(key: 'encrypted_password', value: encryptedPassword);
}

/// Get encrypted password that has been saved to device
Future<String?> getEncryptedPasswordFromDevice() {
  return _storage.read(key: 'encrypted_password');
}

/// Save username to device
void _saveUsernameToDevice(String username) {
  _storage.write(key: 'username', value: username);
}

/// Get username from device
Future<String?> getUsernameFromDevice() {
  return _storage.read(key: 'username');
}

/// Delete username from device
void _deleteUsernameFromDevice() {
  _storage.delete(key: 'username');
}

/// Delete password from device
void _deletePasswordFromDevice() {
  _storage.delete(key: 'password');
}

// Deletes password and username from device
void deleteUserCredentialsFromDevice() {
  _deleteUsernameFromDevice();
  _deletePasswordFromDevice();
}

/// Encrypt given username and password and store on device
void encryptAndSaveCredentials(String username, String password) {
  // TODO: import assets/public_key.txt
  final String pkString = '-----BEGIN PUBLIC KEY-----\n' +
  'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n' +
'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n' +
'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n' +
'CaCUGqS6FN1nNKARGwIDAQAB\n' +
'-----END PUBLIC KEY-----';
  final rsaParser = RSAKeyParser();
  final pc.RSAPublicKey publicKey = rsaParser.parse(pkString) as RSAPublicKey;
  var cipher = OAEPEncoding(pc.AsymmetricBlockCipher('RSA'));
  pc.AsymmetricKeyParameter<pc.RSAPublicKey> keyParametersPublic =
new pc.PublicKeyParameter(publicKey);
  cipher.init(true, keyParametersPublic);
  Uint8List output = cipher.process(utf8.encode(password) as Uint8List);
  var base64EncodedText = base64.encode(output);
  _saveUsernameToDevice(username);
  _saveEncryptedPasswordToDevice(base64EncodedText);
}