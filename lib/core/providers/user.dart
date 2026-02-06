import 'dart:convert';
import 'dart:typed_data';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:campus_mobile_experimental/core/services/authentication.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_persistence.dart'; // tgpt code
import 'package:campus_mobile_experimental/core/services/user.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDataProvider extends ChangeNotifier {
  // --- tgpt - dev tools - blue button - start ---
  static UserDataProvider fakeGuest() {
    final provider = UserDataProvider();
    provider._authenticationModel = AuthenticationModel.fromJson({});
    return provider;
  }

  static UserDataProvider fakeLoggedIn(String token) {
    final provider = UserDataProvider();
    provider._authenticationModel = AuthenticationModel.fromJson({"access_token": token});
    return provider;
  }

  // --- tgpt - dev tools - blue button - finish ---
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  bool _isInSilentLogin = false;

  /// MODELS
  /// default authentication model and profile is needed in this class
  AuthenticationModel _authenticationModel = AuthenticationModel.fromJson({});
  UserProfileModel _userProfileModel = UserProfileModel.fromJson({});

  /// PROVIDERS
  late PushNotificationDataProvider _pushNotificationDataProvider;
  late CardsDataProvider cardsDataProvider;

  /// SERVICES
  var _authenticationService = AuthenticationService();
  var _userProfileService = UserProfileService();
  // var storage = FlutterSecureStorage();
  final storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Update the [AuthenticationModel] stored in state
  /// overwrite the [AuthenticationModel] in persistent storage with the model passed in
  Future updateAuthenticationModel(AuthenticationModel model) async {
    _authenticationModel = model;
    var box = await Hive.openBox<AuthenticationModel?>('AuthenticationModel');
    var timeBox = await Hive.openBox<DateTime?>('AuthenticationModelLastUpdated');

    // save authentication model
    await box.put('AuthenticationModel', model);
    // save last updated time
    _lastUpdated = DateTime.now();
    await timeBox.put('lastUpdated', _lastUpdated);
  }

  /// Update the [UserProfileModel] stored in state
  /// overwrite the [UserProfileModel] in persistent storage with the model passed in
  Future updateUserProfileModel(UserProfileModel model) async {
    _userProfileModel = model;
    var box;
    try {
      box = Hive.box<UserProfileModel?>('UserProfileModel');
    } catch (e) {
      box = await Hive.openBox<UserProfileModel?>('UserProfileModel');
    } finally {
      await box.put('UserProfileModel', model);
      _lastUpdated = DateTime.now();
    }
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
    var authBox = await Hive.openBox<AuthenticationModel?>('AuthenticationModel');
    var timeBox = await Hive.openBox<DateTime?>('AuthenticationModelLastUpdated');

    AuthenticationModel temp = AuthenticationModel.fromJson({});
    // Check to see if we have added the authentication model into the box already
    if (authBox.get('AuthenticationModel') == null) {
      await authBox.put('AuthenticationModel', temp);
      temp = authBox.get('AuthenticationModel')!;
      _authenticationModel = temp;
      _lastUpdated = null; // no token yet
    } else {
      // load the stored authentication model
      temp = authBox.get('AuthenticationModel')!;
      _authenticationModel = temp;

      // load original timestamp
      _lastUpdated = timeBox.get('AuthenticationModelLastUpdated');

      // Only attempt silent login if the token is expired or invalid
      if (!_authenticationModel.isLoggedIn(_lastUpdated)) {
        await silentLogin();
      } else {
        // Token is still valid, no need to silent login
        print("Token is still valid, no need to silent login");
      }
    }
  }

  /// Load [UserProfileModel] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadSavedUserProfile() async {
    var userBox = await Hive.openBox<UserProfileModel?>('UserProfileModel');
    // Create new user from temp profile
    UserProfileModel tempUserProfile = await _createNewUser(UserProfileModel.fromJson({}));
    final bool hasNoStoredProfile = userBox.get('UserProfileModel') == null;
    if (hasNoStoredProfile) await userBox.put('UserProfileModel', tempUserProfile);
    tempUserProfile = userBox.get('UserProfileModel')!;
    _userProfileModel = tempUserProfile;
    _subscribeToPushNotificationTopics(_userProfileModel.subscribedTopics!.whereType<String>().toList());
    notifyListeners();
    final chatPersistence = ChatPersistenceService(this);
    await chatPersistence.clearUserChatData();
  }

  /// Save encrypted password to device
  // void _saveEncryptedPasswordToDevice(String encryptedPassword) => storage.write(key: 'encrypted_password', value: encryptedPassword);
  Future<void> _saveEncryptedPasswordToDevice(String encryptedPassword) async =>
      await storage.write(key: 'encrypted_password', value: encryptedPassword);

  /// Get encrypted password that has been saved to device
  Future<String?> _getEncryptedPasswordFromDevice() => storage.read(key: 'encrypted_password');

  /// Save username to device
  // void _saveUsernameToDevice(String username) => storage.write(key: 'username', value: username);
  Future<void> _saveUsernameToDevice(String username) async => await storage.write(key: 'username', value: username);

  /// Get username from device
  Future<String?> getUsernameFromDevice() => storage.read(key: 'username');

  /// Delete username from device
  void _deleteUsernameFromDevice() => storage.delete(key: 'username');

  /// Delete password from device
  void _deletePasswordFromDevice() => storage.delete(key: 'password');

  /// Encrypt given username and password and store on device
  Future<void> _encryptAndSaveCredentials(String username, String password) async {
    final pkString = dotenv.get('USER_CREDENTIALS_PUBLIC_KEY');
    final rsaParser = RSAKeyParser();
    final pc.RSAPublicKey publicKey = rsaParser.parse(pkString) as RSAPublicKey;
    var cipher = OAEPEncoding(pc.AsymmetricBlockCipher('RSA'));
    pc.AsymmetricKeyParameter<pc.RSAPublicKey> keyParametersPublic = new pc.PublicKeyParameter(publicKey);
    cipher.init(true, keyParametersPublic);
    Uint8List output = cipher.process(utf8.encode(password));
    var base64EncodedText = base64.encode(output);
    await _saveUsernameToDevice(username);
    await _saveEncryptedPasswordToDevice(base64EncodedText);
  }

  /// Authenticate a user given an username and password
  /// Upon logging in we should make sure that users has an account
  /// If the user doesn't have an account one will be made by invoking [_createNewUser]
  Future manualLogin(String username, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    final bool hasUsername = username.isNotEmpty;
    final bool hasPassword = password.isNotEmpty;
    if (hasUsername && hasPassword) {
      await _encryptAndSaveCredentials(username, password);
      if (await silentLogin()) {
        if (_userProfileModel.classifications!.student!) {
          cardsDataProvider.showAllStudentCards();
        } else if (_userProfileModel.classifications!.staff!) {
          cardsDataProvider.showAllStaffCards();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _authenticationService.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    _error = 'Username or password not found';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Check if silent login should be attempted
  /// Returns true if we have stored credentials but invalid/expired token
  Future<bool> _shouldAttemptSilentLogin() async {
    String? username = await getUsernameFromDevice();
    String? encryptedPassword = await _getEncryptedPasswordFromDevice();

    // No stored credentials - don't attempt silent login
    if (username == null || encryptedPassword == null) return false;

    // Have credentials but token is invalid/expired - attempt silent login
    return !_authenticationModel.isLoggedIn(_lastUpdated);
  }

  /// Logs user in with saved credentials on device
  /// If this login mechanism fails then the user is logged out
  Future<bool> silentLogin() async {
    _isInSilentLogin = true;
    notifyListeners();

    // Check if we should even attempt silent login
    if (!await _shouldAttemptSilentLogin()) {
      _isInSilentLogin = false;
      notifyListeners();
      return _authenticationModel.isLoggedIn(_lastUpdated);
    }

    String? username = await getUsernameFromDevice();
    String? encryptedPassword = await _getEncryptedPasswordFromDevice();

    /// Allow silentLogin if username, pw are set, and the user is not logged in
    if (username != null && encryptedPassword != null) {
      final String base64EncodedWithEncryptedPassword = base64.encode(utf8.encode(username + ':' + encryptedPassword));
      resetHomeScrollOffset();
      resetAllCardHeights();
      resetNotificationsScrollOffset();

      final bool silentLoginSuccessful = await _authenticationService.silentLogin(base64EncodedWithEncryptedPassword);
      if (silentLoginSuccessful) {
        await updateAuthenticationModel(_authenticationService.data!);
        await fetchUserProfile();
        var _cardsDataProvider = CardsDataProvider();
        _cardsDataProvider.updateAvailableCards(_userProfileModel.ucsdAffiliation);
        _subscribeToPushNotificationTopics(List<String>.from(userProfileModel.subscribedTopics!));
        _pushNotificationDataProvider.registerDevice(_authenticationService.data!.accessToken);
        await analytics.logEvent(name: 'loggedIn');
        _isInSilentLogin = false;
        notifyListeners();
        return true;
      }
    }

    logout();
    return false;
  }

  /// Logs out user
  /// Unregisters device from direct push notification using [_pushNotificationDataProvider]
  /// Resets all [AuthenticationModel] and [UserProfileModel] data from persistent storage
  void logout() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    resetHomeScrollOffset();
    resetAllCardHeights();
    resetNotificationsScrollOffset();
    _pushNotificationDataProvider.unregisterDevice(_authenticationModel.accessToken);
    updateAuthenticationModel(AuthenticationModel.fromJson({}));
    updateUserProfileModel(await _createNewUser(UserProfileModel.fromJson({})));
    _deletePasswordFromDevice();
    _deleteUsernameFromDevice();
    var _cardsDataProvider = CardsDataProvider();
    _cardsDataProvider.updateAvailableCards("");
    var box = await Hive.openBox<AuthenticationModel?>('AuthenticationModel');
    await box.clear();
    await analytics.logEvent(name: 'loggedOut');
    _isLoading = false;
    notifyListeners();
  }

  /// Remove topic from [_userProfileModel.subscribedTopics]
  /// Use [_pushNotificationDataProvider] to un/subscribe device from push notifications
  void toggleNotifications(String topic) {
    if (_userProfileModel.subscribedTopics!.contains(topic))
      _userProfileModel.subscribedTopics!.remove(topic);
    else
      _userProfileModel.subscribedTopics!.add(topic);

    postUserProfile(_userProfileModel);
    _pushNotificationDataProvider.toggleNotificationsForTopic(topic);
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

    if (isLoggedIn) {
      /// we fetch the user data now
      final Map<String, String> headers = {'Authorization': 'Bearer ' + _authenticationModel.accessToken!};

      if (await _userProfileService.downloadUserProfile(headers)) {
        /// if the user profile has no ucsd affiliation then we know the user is new
        /// so create a new profile and upload to DB using [postUserProfile]
        var newModel = _userProfileService.userProfileModel;
        if (newModel.ucsdAffiliation == null) {
          newModel = await _createNewUser(newModel);
          await postUserProfile(newModel);
        } else {
          newModel.username = await getUsernameFromDevice();
          newModel.ucsdAffiliation = _authenticationModel.ucsdaffiliation;
          newModel.pid = _authenticationModel.pid;
          List<String> castSubscriptions = newModel.subscribedTopics!.cast<String>();
          newModel.subscribedTopics = castSubscriptions.toSet().toList();
          final studentPattern = RegExp('[BGJMU]');
          final staffPattern = RegExp('[E]');

          if ((newModel.ucsdAffiliation ?? "").contains(studentPattern)) {
            newModel..classifications = Classifications.fromJson({'student': true, 'staff': false});
          } else if ((newModel.ucsdAffiliation ?? "").contains(staffPattern)) {
            newModel..classifications = Classifications.fromJson({'staff': true, 'student': false});
          } else {
            newModel.classifications = Classifications.fromJson({'student': false, 'staff': false});
          }
          await updateUserProfileModel(newModel);
          _pushNotificationDataProvider.subscribeToTopics(newModel.subscribedTopics!.cast<String>());
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
    await _pushNotificationDataProvider.fetchTopicsList();
    try {
      profile.username = await getUsernameFromDevice();
      profile.ucsdAffiliation = _authenticationModel.ucsdaffiliation;
      profile.pid = _authenticationModel.pid;
      profile.subscribedTopics = _pushNotificationDataProvider.publicTopics();
      final studentPattern = RegExp('[BGJMU]');
      final staffPattern = RegExp('[E]');

      if ((profile.ucsdAffiliation ?? "").contains(studentPattern)) {
        profile
          ..classifications = Classifications.fromJson({'student': true, 'staff': false})
          ..subscribedTopics!.addAll(_pushNotificationDataProvider.studentTopics());
      } else if ((profile.ucsdAffiliation ?? "").contains(staffPattern)) {
        profile
          ..classifications = Classifications.fromJson({'staff': true, 'student': false})
          ..subscribedTopics!.addAll(_pushNotificationDataProvider.staffTopics());
      } else {
        profile.classifications = Classifications.fromJson({'student': false, 'staff': false});
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
      final Map<String, String> headers = {'Authorization': "Bearer " + _authenticationModel.accessToken!};

      /// we only want to push data that is not null
      var tempJson = Map<String, dynamic>();
      for (var key in profile.toJson().keys) {
        final bool hasValue = profile.toJson()[key] != null;
        if (hasValue) tempJson[key] = profile.toJson()[key];
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

  /// Check if the current token is still valid
  /// This can be called periodically to check token status
  bool isTokenValid() => _authenticationModel.isLoggedIn(_lastUpdated);

  /// Proactively refresh authentication if token is about to expire
  /// Call this method periodically (e.g., when app comes to foreground)
  Future<void> refreshAuthenticationIfNeeded() async {
    final bool isTokenInvalid = !isTokenValid();
    final bool shouldAttemptLogin = await _shouldAttemptSilentLogin();

    if (isTokenInvalid && shouldAttemptLogin) await silentLogin();
  }

  /// SIMPLE SETTERS
  set pushNotificationDataProvider(PushNotificationDataProvider value) => _pushNotificationDataProvider = value;

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  get isLoggedIn => _authenticationModel.isLoggedIn(_lastUpdated);
  get isInSilentLogin => _isInSilentLogin;
  UserProfileModel get userProfileModel => _userProfileModel;
  AuthenticationModel get authenticationModel => _authenticationModel;

  // TODO: fix this after UserProfileModel's nullability is fixed - December 2025
  List<String?>? get subscribedTopics => _userProfileModel.subscribedTopics;
}
