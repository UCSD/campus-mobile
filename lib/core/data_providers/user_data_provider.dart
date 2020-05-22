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

  /// Update the [AuthenticationModel] stored in state
  /// overwrite the [AuthenticationModel] in persistent storage with the model passed in
  Future updateAuthenticationModel(AuthenticationModel model) async {
    _authenticationModel = model;
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    await box.put('AuthenticationModel', model);
    _lastUpdated = DateTime.now();
  }

  /// Update the [UserProfileModel] stored in state
  /// overwrite the [UserProfileModel] in persistent storage with the model passed in
  Future updateUserProfileModel(UserProfileModel model) async {
    _userProfileModel = model;
    var box = await Hive.box<UserProfileModel>('UserProfileModel');
    await box.put('UserProfileModel', model);
    _lastUpdated = DateTime.now();
  }

  /// Load data from persistent storage by invoking the following methods:
  /// [_loadSavedAuthenticationModel]
  /// [_loadSavedUserProfile]
  Future loadSavedData() async {
    await _loadSavedAuthenticationModel();

    await _loadSavedUserProfile();
  }

  /// Load [AuthenticationModel] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadSavedAuthenticationModel() async {
    Hive.registerAdapter(AuthenticationModelAdapter());
    var authBox =
        await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    AuthenticationModel temp = AuthenticationModel.fromJson({});
    //check to see if we have added the authentication model into the box already
    if (authBox.get('AuthenticationModel') == null) {
      await authBox.put('AuthenticationModel', temp);
    }
    temp = authBox.get('AuthenticationModel');
    _authenticationModel = temp;
    await refreshToken();
  }

  /// Load [UserProfileModel] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadSavedUserProfile() async {
    Hive.registerAdapter(UserProfileModelAdapter());
    var userBox = await Hive.openBox<UserProfileModel>('UserProfileModel');
    UserProfileModel tempUserProfile =
        await _createNewUser(UserProfileModel.fromJson({}));
    if (userBox.get('UserProfileModel') == null) {
      await userBox.put('UserProfileModel', tempUserProfile);
    }
    tempUserProfile = userBox.get('UserProfileModel');
    _userProfileModel = tempUserProfile;
    _subscribeToPushNotificationTopics(_userProfileModel.subscribedTopics);
    notifyListeners();
  }

  /// Save encrypted password to device
  void _saveEncryptedPasswordToDevice(String encryptedPassword) {
    storage.write(key: 'encrypted_password', value: encryptedPassword);
  }

  /// Get encrypted password that has been saved to device
  Future<String> _getEncryptedPasswordFromDevice() {
    return storage.read(key: 'encrypted_password');
  }

  /// Save username to device
  void _saveUsernameToDevice(String username) {
    storage.write(key: 'username', value: username);
  }

  /// Get username from device
  Future<String> _getUsernameFromDevice() {
    return storage.read(key: 'username');
  }

  /// Delete username from device
  void _deleteUsernameFromDevice() {
    storage.delete(key: 'username');
  }

  /// Delete password from device
  void _deletePasswordFromDevice() {
    storage.delete(key: 'password');
  }

  /// Encrypt given username and password and store on device
  void _encryptLoginInfo(String username, String password) {
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
    _saveUsernameToDevice(username);
    _saveEncryptedPasswordToDevice(base64EncodedText);
  }

  /// Logs user in with saved credentials on device
  /// If this login mechanism fails then the user is logged out
  Future<bool> _silentLogin() async {
    String username = await _getUsernameFromDevice();
    String encryptedPassword = await _getEncryptedPasswordFromDevice();
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

  /// Authenticate a user given an username and password
  /// Upon logging in we should make sure that users has an account
  /// If the user doesn't have an account one will be made by invoking [_createNewUser]
  Future<bool> login(String username, String password) async {
    bool returnVal = false;
    if ((username?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false)) {
      _encryptLoginInfo(username, password);
      _error = null;
      _isLoading = true;
      notifyListeners();
      if (await _silentLogin()) {
        await fetchUserProfile();

        /// turn on all saved push notifications preferences for user
        _subscribeToPushNotificationTopics(userProfileModel.subscribedTopics);
        returnVal = true;
      }
      _isLoading = false;
      notifyListeners();
    }
    return returnVal;
  }

  /// Remove topic from [_userProfileModel.subscribedTopics]
  /// Use [_pushNotificationDataProvider] to un/subscribe device from push notifications
  void toggleNotifications(String topic) {
    if (_userProfileModel.subscribedTopics.contains(topic)) {
      _userProfileModel.subscribedTopics.remove(topic);
    } else {
      _userProfileModel.subscribedTopics.add(topic);
    }
    postUserProfile(_userProfileModel);
    _pushNotificationDataProvider.toggleNotificationsForTopic(topic);
    notifyListeners();
  }

  /// Logs out user
  /// Unregisters device from direct push notification using [_pushNotificationDataProvider]
  /// Resets all [AuthenticationModel] and [UserProfileModel] data from persistent storage
  void logout() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _pushNotificationDataProvider
        .unregisterDevice(_authenticationModel.accessToken);
    updateAuthenticationModel(AuthenticationModel.fromJson({}));
    updateUserProfileModel(await _createNewUser(UserProfileModel.fromJson({})));
    _deletePasswordFromDevice();
    _deleteUsernameFromDevice();
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    await box.clear();
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch the [UserProfileModel] from the server if the user is logged in
  /// if the user has no profile in the db then we create on by invoking [_createNewUser]
  /// invoke [postUserProfile] once user profile is created
  /// if user has a profile then we invoke [updateUserProfileModel]
  Future fetchUserProfile() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    if (_authenticationModel.isLoggedIn(_authenticationService.lastUpdated)) {
      /// we fetch the user data now
      final Map<String, String> headers = {
        'Authorization': 'Bearer ' + _authenticationModel.accessToken
      };
      if (await _userProfileService.downloadUserProfile(headers)) {
        /// if the user profile has no ucsd affiliation then we know the user is new
        /// so create a new profile and upload to DB using [postUserProfile]
        UserProfileModel newModel = _userProfileService.userProfileModel;
        if (newModel.ucsdaffiliation == null) {
          newModel = await _createNewUser(newModel);
          await postUserProfile(newModel);
        } else {
          await updateUserProfileModel(newModel);
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

  /// Given a list of topics
  /// invoke [_pushNotificationDataProvider.unsubscribeFromAllTopics()]
  /// invoke [_pushNotificationDataProvider.toggleNotificationsForTopic] on each of the topics
  void _subscribeToPushNotificationTopics(List<String> topics) {
    /// turn on all saved push notifications preferences for user
    _pushNotificationDataProvider.unsubscribeFromAllTopics();
    for (String topic in topics) {
      _pushNotificationDataProvider.toggleNotificationsForTopic(topic);
    }
  }

  /// Create a new user profile based on SSO info
  /// Subscribe students to student topics by appending to [profile]'s [subscribedTopics] list
  /// Subscribe users to public topics appending to [profile]'s [subscribedTopics] list
  /// invokes [_subscribeToPushNotificationTopics] to subscribe user to topics
  /// returns newly created [UserProfileModel]
  Future<UserProfileModel> _createNewUser(UserProfileModel profile) async {
    try {
      profile.username = await _getUsernameFromDevice();
      profile.ucsdaffiliation = _authenticationModel.ucsdaffiliation;
      profile.pid = _authenticationModel.pid;
      profile.subscribedTopics =
          await _pushNotificationDataProvider.publicTopics();
      final pattern = RegExp('[BGJMU]');
      if ((profile.ucsdaffiliation ?? "").contains(pattern)) {
        profile
          ..classifications = Classifications.fromJson({'student': true})
          ..subscribedTopics
              .addAll(await _pushNotificationDataProvider.studentTopics());
      } else {
        profile.classifications = Classifications.fromJson({'student': false});
      }
    } catch (e) {
      print(e.toString());
    }
    return profile;
  }

  /// Invoke [updateUserProfileModel] with user profile that was passed in
  /// If user is logged in upload [UserProfileModel] to DB
  Future postUserProfile(UserProfileModel profile) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    /// save settings to local storage
    await updateUserProfileModel(profile);

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
    _isLoading = false;
    notifyListeners();
  }

  /// Use saved [AuthenticationModel] to refesh access token
  /// Invokes [_silentLogin] on failure
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
      await _silentLogin();
    }
    notifyListeners();
  }

  set pushNotificationDataProvider(PushNotificationDataProvider value) {
    _pushNotificationDataProvider = value;
  }

  List<String> get subscribedTopics => _userProfileModel.subscribedTopics;

  ///GETTERS FOR MODELS
  UserProfileModel get userProfileModel => _userProfileModel;
  AuthenticationModel get authenticationModel => _authenticationModel;

  ///GETTERS FOR STATES
  String get error => _error;
  bool get isLoggedIn => _authenticationModel.isLoggedIn(_lastUpdated);
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
