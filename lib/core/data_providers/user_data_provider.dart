import 'package:campus_mobile_experimental/core/models/authentication_model.dart';
import 'package:campus_mobile_experimental/core/models/user_profile_model.dart';
import 'package:campus_mobile_experimental/core/services/authentication_service.dart';
import 'package:campus_mobile_experimental/core/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class UserDataProvider extends ChangeNotifier {
  UserDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _authenticationService = AuthenticationService();
    _userProfileService = UserProfileService();
    storage = FlutterSecureStorage();

    ///default authentication model is needed in this class to check login state
    ///in most classes the model data can remain null
    _authenticationModel = AuthenticationModel.fromJson({});
    _userProfileModel = UserProfileModel.fromJson({});
    _cardStates = {
      'dining': true,
      'links': true,
      'availability': true,
      'parking': true,
      'weather': true,
      'events': true,
      'special_events': true,
      'news': true,
      'schedule': true,
      'finals': true,
    };
    _cardOrder = [
      'special_events',
      'schedule',
      'finals',
      'weather',
      'availability',
      'parking',
      'dining',
      'news',
      'events',
      'links',
    ];
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  AuthenticationModel _authenticationModel;
  UserProfileModel _userProfileModel;
  FlutterSecureStorage storage;

  ///SERVICES
  AuthenticationService _authenticationService;
  UserProfileService _userProfileService;
  Map<String, bool> _cardStates;

  List<String> _cardOrder;

  ///Update the authentication model saved in state and save the model in persistent storage
  void updateAuthenticationModel(AuthenticationModel model) {
    _authenticationModel = model;
    _authenticationModel.save();
  }

  void loadSavedData() async {
    Hive.registerAdapter(AuthenticationModelAdapter());
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    //check to see if we have added the authentication model into the box already
    if (box.get('AuthenticationModel') == null) {
      await box.add(AuthenticationModel.fromJson({}));
    }
    updateAuthenticationModel(
      AuthenticationModel.fromJson({}),
    );
  }

  ///Save encrypted password to device
  void saveEncryptedPasswordToDevice(String encryptedPassword) {
    storage.write(key: 'encrypted_password', value: encryptedPassword);
  }

  ///Get encrypted password that has been saved to device
  Future<String> getEncryptedPasswordFromDevice() {
    return storage.read(key: 'encrypted_password');
  }

  ///Save email to device
  void saveUsernameToDevice(String username) {
    storage.write(key: 'username', value: username);
  }

  ///Get email from device
  Future<String> getUsernameFromDevice() {
    return storage.read(key: 'username');
  }

  void deleteUsernameFromDevice() {
    storage.delete(key: 'username');
  }

  void deletePasswordFromDevice() {
    storage.delete(key: 'password');
  }

  ///authenticate a user given an email and password
  ///upon logging in we should make sure that users upload the correct
  ///ucsdaffiliation and classification
  void login(String email, String password) async {
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

    _error = null;
    _isLoading = true;
    notifyListeners();

    bool response =
        await _authenticationService.login(base64EncodedWithEncryptedPassword);
    if (response) {
      _authenticationModel = _authenticationService.data;
      print(_authenticationModel.toJson());
      saveUsernameToDevice(email);
      saveEncryptedPasswordToDevice(base64EncodedText);
      updateAuthenticationModel(_authenticationModel);
      getUserProfile();
      _lastUpdated = DateTime.now();
    } else {
      /// here we know that the authentication failed but we still have access to stale data because it has not been overwritten
      /// however if this failure occurs on the first attempt then our data model will have a default expiration of 0
      /// TODO: make sure this is the correct error message to show the user in the AuthenticationService class
      /// this is the error we will display to the user
      _error = _authenticationService.error;

      ///reset all auth settings if login was unsuccessful
      _authenticationModel = AuthenticationModel.fromJson({});
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleCard(String card) {
    _cardStates[card] = !_cardStates[card];
    notifyListeners();
  }

  void reorderCards(List<String> order) {
    _cardOrder = order;
    notifyListeners();
  }

  void logout() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    updateAuthenticationModel(AuthenticationModel.fromJson({}));
    _userProfileModel = UserProfileModel.fromJson({});
    _isLoading = false;
    notifyListeners();
  }

  ///FETCH USER PROFILE FROM SERVER
  ///TODO: check to see if user profile is blank, if it is then upload current profile to cloud
  void getUserProfile() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    if (_authenticationModel.isLoggedIn(_authenticationService.lastUpdated)) {
      /// we fetch the user data now
      final Map<String, String> headers = {
        'Authorization': 'Bearer ' + _authenticationModel.accessToken
      };
      if (await _userProfileService.downloadUserProfile(headers)) {
        _userProfileModel = _userProfileService.userProfileModel;
        print('downlaoded user profile: ');
        print(_userProfileService.userProfileModel.toJson().toString());
      }
    } else {
      _error = 'not logged in';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// UPLOAD USER PROFILE TO SERVER
  void postUserProfile(UserProfileModel profile) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    if (_authenticationModel.isLoggedIn(_authenticationService.lastUpdated)) {
      final Map<String, String> headers = {
        'Authorization': "Bearer " + _authenticationModel.accessToken
      };
      if (await _userProfileService.uploadUserProfile(
          headers, profile.toJson())) {
        _error = null;
        _isLoading = false;
      }
    } else {
      _error = 'not logged in';
    }
    _userProfileModel = profile;
    _isLoading = false;
    notifyListeners();
  }

  ///Uses saved refresh token to reauthenticate user
  ///Invokes [reauthenticate] on failure
  ///TODO: check if we need to change the loading boolean since this is a silent login mechanism
  void refreshToken() async {
    _error = null;
    if (await _authenticationService
        .refreshAccessToken(_authenticationModel.refreshToken)) {
      updateAuthenticationModel(_authenticationService.data);
    } else {
      ///TODO: check if the error is the refresh token is expired
      ///if it is then use stored credentials to get new access token
      _error = _authenticationService.error;

      ///TODO figure out what message is returned for expired refresh token
      if (_error == 'The given refresh token was invalid') {
        ///Try to use user's credentials to login again
        await reauthenticate();
      }
    }
    notifyListeners();
  }

  ///Uses saved credentials to reauthenticate user
  ///Invokes [logout] on failure
  void reauthenticate() async {
    String email = await getUsernameFromDevice();
    String encryptedPassword = await getEncryptedPasswordFromDevice();
    final String base64EncodedWithEncryptedPassword =
        base64.encode(utf8.encode(email + ':' + encryptedPassword));
    if (await _authenticationService
        .login(base64EncodedWithEncryptedPassword)) {
      updateAuthenticationModel(_authenticationService.data);
    } else {
      logout();
    }
  }

  ///GETTERS FOR MODELS
  UserProfileModel get userProfileModel => _userProfileModel;
  AuthenticationModel get authenticationModel => _authenticationModel;

  ///GETTERS FOR STATES
  String get error => _error;
  bool get isLoggedIn => _authenticationModel.isLoggedIn(_lastUpdated);
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
  Map<String, bool> get cardStates => _cardStates;
  List<String> get cardOrder => _cardOrder;
}
