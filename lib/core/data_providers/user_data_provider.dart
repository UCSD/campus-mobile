import 'package:campus_mobile_experimental/core/data_providers/push_notifications_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/authentication_model.dart';
import 'package:campus_mobile_experimental/core/models/user_profile_model.dart';
import 'package:campus_mobile_experimental/core/services/authentication_service.dart';
import 'package:campus_mobile_experimental/core/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
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

    ///default authentication model and profile is needed in this class
    _authenticationModel = AuthenticationModel.fromJson({});
    _userProfileModel = UserProfileModel.fromJson({});
    _cardStates = {
      'availability': true,
      'events': true,
      'links': true,
      'news': true,
      'parking': true,
      'special_events': true,
      'weather': true,
      'dining': true,
      'finals': true,
      'schedule': true,
      'my_chart': true
    };
    _cardOrder = [
//      'availability',
//      'dining',
//      'events',
//      'links',
//      'news',
//      'parking',
//      'weather',
//      'special_events',
      'finals',
      'schedule',
      'my_chart'
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
  PushNotificationDataProvider _pushNotificationDataProvider;

  Map<String, bool> _cardStates;

  List<String> _cardOrder;

  ///Update the authentication model saved in state and save the model in persistent storage
  Future updateAuthenticationModel(AuthenticationModel model) async {
    _authenticationModel = model;
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    await box.put('AuthenticationModel', model);
    _lastUpdated = DateTime.now();
  }

  ///Load data from persistent storage
  ///Will create persistent storage if  no data is found
  Future loadSavedData() async {
    Hive.registerAdapter(AuthenticationModelAdapter());
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    AuthenticationModel temp = AuthenticationModel.fromJson({});
    //check to see if we have added the authentication model into the box already
    if (box.get('AuthenticationModel') == null) {
      await box.put('AuthenticationModel', temp);
    }
    temp = box.get('AuthenticationModel');
    _authenticationModel = temp;
    await refreshToken();
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

  ///Encrypt given username and password and store on device
  void encryptLoginInfo(String username, String password) {
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
    saveUsernameToDevice(username);
    saveEncryptedPasswordToDevice(base64EncodedText);
  }

  ///logs user in with saved credentials on device
  ///if this login mechanism fails then the user is logged out
  Future<bool> silentLogin() async {
    String username = await getUsernameFromDevice();
    String encryptedPassword = await getEncryptedPasswordFromDevice();
    if (username != null && encryptedPassword != null) {
      final String base64EncodedWithEncryptedPassword =
          base64.encode(utf8.encode(username + ':' + encryptedPassword));
      if (await _authenticationService
          .login(base64EncodedWithEncryptedPassword)) {
        updateAuthenticationModel(_authenticationService.data);
        _pushNotificationDataProvider
            .registerDevice(_authenticationService.data.accessToken);
        return true;
      } else {
        logout();
        _error = _authenticationService.error;
        return false;
      }
    }
    return false;
  }

  ///authenticate a user given an email and password
  ///upon logging in we should make sure that users upload the correct
  ///ucsdaffiliation and classification
  Future<bool> login(String username, String password) async {
    bool returnVal = false;
    if ((username?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false)) {
      encryptLoginInfo(username, password);
      _error = null;
      _isLoading = true;
      notifyListeners();
      if (await silentLogin()) {
        await getUserProfile();
        returnVal = true;
      }
      _isLoading = false;
      notifyListeners();
    }
    return returnVal;
  }

  void toggleCard(String card) {
    _cardStates[card] = !_cardStates[card];
    notifyListeners();
  }

  void reorderCards(List<String> order) {
    _cardOrder = order;
    notifyListeners();
  }

  ///Logs out user
  ///Resets all authentication data and all userProfile data
  void logout() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _pushNotificationDataProvider
        .unregisterDevice(_authenticationModel.accessToken);
    updateAuthenticationModel(AuthenticationModel.fromJson({}));
    _userProfileModel = UserProfileModel.fromJson({});
    deletePasswordFromDevice();
    deleteUsernameFromDevice();
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    await box.clear();
    _isLoading = false;
    notifyListeners();
  }

  ///FETCH USER PROFILE FROM SERVER
  Future getUserProfile() async {
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

        /// if the user profile has no ucsd affiliation then we know the user is new
        /// so create a new profile and upload to DB using [postUserProfile]
        if (_userProfileModel.ucsdaffiliation == null) {
          await createNewUser();
        }
      } else {
        _error = _userProfileService.error;
      }
    } else {
      _error = 'not logged in';
    }
    _isLoading = false;
    notifyListeners();
  }

  ///Create a new user profile based on SSO info
  Future createNewUser() async {
    _userProfileModel
      ..username = await getUsernameFromDevice()
      ..ucsdaffiliation = _authenticationModel.ucsdaffiliation
      ..pid = _authenticationModel.pid;

    final pattern = RegExp('[BGJMU]');
    if (_userProfileModel.ucsdaffiliation.contains(pattern)) {
      _userProfileModel.classifications =
          Classifications.fromJson({'student': true});
    } else {
      _userProfileModel.classifications =
          Classifications.fromJson({'student': false});
    }
    await postUserProfile(_userProfileModel);
  }

  /// UPLOAD USER PROFILE TO SERVER
  Future postUserProfile(UserProfileModel profile) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    /// check if user is logged in
    if (_authenticationModel.isLoggedIn(_authenticationService.lastUpdated)) {
      final Map<String, String> headers = {
        'Authorization': "Bearer " + _authenticationModel.accessToken
      };

      /// we only want to push data that is not null
      var tempJson = Map<String, dynamic>();
      for (var key in profile.toJson().keys) {
        if (profile.toJson()[key] != null) {
          tempJson[key] = profile.toJson()[key];
        }
      }
      if (await _userProfileService.uploadUserProfile(headers, tempJson)) {
        _error = null;
        _isLoading = false;
      } else {
        _error = _userProfileService.error;
      }
    } else {
      _error = 'not logged in';
    }
    _userProfileModel = profile;
    _isLoading = false;
    notifyListeners();
  }

  ///Uses saved refresh token to reauthenticate user
  ///Invokes [silentLogin] on failure
  ///TODO: check if we need to change the loading boolean since this is a silent login mechanism
  Future refreshToken() async {
    _error = null;
    if (await _authenticationService
        .refreshAccessToken(_authenticationModel.refreshToken)) {
      /// this is only added to refresh token method because the response for the refresh token does not include
      /// pid and ucsdaffiliation fields
      if (_authenticationModel.ucsdaffiliation != null) {
        AuthenticationModel finalModel = _authenticationService.data;
        finalModel.ucsdaffiliation = _authenticationModel.ucsdaffiliation;
        finalModel.pid = _authenticationModel.pid;
      }
      await updateAuthenticationModel(_authenticationService.data);
    } else {
      ///if the token passed from the device was empty then [_error] will be populated with 'The given refresh token was invalid'
      ///if the token passed from the device was malformed or expired then [_error] will be populated with 'invalid_grant'
      _error = _authenticationService.error;

      ///Try to use user's credentials to login again
      await silentLogin();
    }
    notifyListeners();
  }

  set pushNotificationDataProvider(PushNotificationDataProvider value) {
    _pushNotificationDataProvider = value;
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
