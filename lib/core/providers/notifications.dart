import 'dart:async';
import 'dart:io';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/topics.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/services/notifications.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _androidNotificationChannelId = 'campus_mobile_notifications';
const String _androidNotificationChannelName = 'Campus Mobile Notifications';
const String _androidNotificationChannelDescription = 'Campus Mobile alerts and messages';

class PushNotificationDataProvider extends ChangeNotifier {
  PushNotificationDataProvider() {
    initState();
  }

  /// Context as Global Variable
  late BuildContext context;

  /// STATES
  DateTime? _lastUpdated;
  String? _error;
  Map<String?, bool> _topicSubscriptionState = {};

  /// MODELS
  var _topicsModel = <TopicsModel>[];
  Map<String, dynamic> _deviceData = {};

  /// SERVICES
  var _notificationService = NotificationService();
  var deviceInfoPlugin = DeviceInfoPlugin();
  var _fcm = FirebaseMessaging.instance;

  /// invokes correct method to receive device info
  /// invokes [fetchTopicsList]
  initState() async {
    fetchTopicsList();
    // onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    if (Platform.isAndroid) {
      _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      // Handled automatically by getToken
      // _fcm.requestPermission(const IosNotificationSettings(
      //     sound: true, badge: true, alert: true, provisional: true));
      // _fcm.onIosSettingsRegistered
      //     .listen((IosNotificationSettings settings) {});
    }

    /// listen for token changes and register user
    _fcm.onTokenRefresh.listen((token) {
      registerDevice(token);
    });
  }

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String _NOTIFICATION_PERMISSION_REQUESTED_KEY = 'notification_permission_requested';
  bool _platformStateInitialized = false;

  /// Configures the [_fcm] object to receive push notifications
  Future<void> initPlatformState(BuildContext context) async {
    try {
      /// Initialize flutter notification settings
      this.context = context;
      if (_platformStateInitialized) {
        debugPrint('[PushNotifications] initPlatformState skipped; already initialized');
        return;
      }
      _platformStateInitialized = true;
      debugPrint('[PushNotifications] initPlatformState starting');

      /// Request notification permission on Android once (early, like iOS)
      if (Platform.isAndroid) {
        final prefs = await SharedPreferences.getInstance();
        var isPermissionRequested = prefs.getBool(_NOTIFICATION_PERMISSION_REQUESTED_KEY) ?? false;
        if (!isPermissionRequested) {
          final settings = await FirebaseMessaging.instance.requestPermission();
          debugPrint('[PushNotifications] Android permission requested: ${settings.authorizationStatus}');
          await prefs.setBool(_NOTIFICATION_PERMISSION_REQUESTED_KEY, true);
        } else {
          final settings = await FirebaseMessaging.instance.getNotificationSettings();
          debugPrint('[PushNotifications] Android permission already requested: ${settings.authorizationStatus}');
        }
      }

      const initializationSettingsAndroid = AndroidInitializationSettings("@drawable/ic_notif_round");
      final initializationSettingsIOS = DarwinInitializationSettings();
      final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: selectNotification,
      );
      if (Platform.isAndroid) await _createAndroidNotificationChannel();

      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        _logRemoteMessage('initialMessage', initialMessage);
        await Provider.of<MessagesDataProvider>(context, listen: false).fetchMessages(true);

        /// switch to the notifications tab
        Provider.of<BottomNavigationBarProvider>(context, listen: false).currentIndex =
            NavigatorConstants.NOTIFICATIONS_TAB;
      }

      /// Foreground messaging
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logRemoteMessage('onMessage', message);

        /// foreground messaging callback via flutter_local_notifications
        /// only show message if the message has not been seen before
        final bool isNewMessage = !_receivedMessageIds.contains(message.messageId);
        if (isNewMessage) showNotification(message);
        // add messageId as it has been shown already
        _receivedMessageIds.add(message.messageId!);

        /// Fetch in-app messages
        Provider.of<MessagesDataProvider>(context, listen: false).fetchMessages(true);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logRemoteMessage('onMessageOpenedApp', message);

        /// Fetch in-app messages
        Provider.of<MessagesDataProvider>(context, listen: false).fetchMessages(true);

        /// Set tab bar index to the Notifications tab
        Provider.of<BottomNavigationBarProvider>(context, listen: false).currentIndex =
            NavigatorConstants.NOTIFICATIONS_TAB;

        /// Navigate to Notifications tab
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RoutePaths.BOTTOM_NAVIGATION_BAR, (Route<dynamic> route) => false);
      });
    } on PlatformException {
      _error = 'Failed to get platform info.';
      _platformStateInitialized = false;
    }
  }

  /// Handles notification when selected
  void selectNotification(NotificationResponse details) {
    /// Fetch in-app messages
    Provider.of<MessagesDataProvider>(this.context, listen: false).fetchMessages(true);

    /// Navigate to Notifications tab
    Navigator.of(
      this.context,
    ).pushNamedAndRemoveUntil(RoutePaths.BOTTOM_NAVIGATION_BAR, (Route<dynamic> route) => false);

    /// Set tab bar index to the Notifications tab
    Provider.of<BottomNavigationBarProvider>(this.context, listen: false).currentIndex =
        NavigatorConstants.NOTIFICATIONS_TAB;
    Provider.of<CustomAppBar>(context, listen: false).changeTitle("Notifications");
  }

  /// Displays the notification
  showNotification(RemoteMessage message) async {
    debugPrint(
      '[PushNotifications] showNotification start channel=$_androidNotificationChannelId '
      'messageId=${message.messageId}',
    );
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _androidNotificationChannelId,
      _androidNotificationChannelName,
      channelDescription: _androidNotificationChannelDescription,
      icon: '@drawable/ic_notif_round',
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/app_icon'),
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
    // This is where you put info from firebase
    try {
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        message.notification?.title ?? message.data['title']?.toString(),
        message.notification?.body ?? message.data['body']?.toString(),
        platformChannelSpecifics,
        payload: 'This is the payload',
      );
      debugPrint('[PushNotifications] showNotification posted messageId=${message.messageId}');
    } catch (error, stackTrace) {
      debugPrint('[PushNotifications] showNotification failed: $error');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _androidNotificationChannelId,
      _androidNotificationChannelName,
      description: _androidNotificationChannelDescription,
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    debugPrint('[PushNotifications] Android channel ensured: $_androidNotificationChannelId');
  }

  /// Fetches topics from endpoint
  /// Deletes topics that are no longer supported
  /// Transfers over previous subscriptions
  Future fetchTopicsList() async {
    Map<String?, bool> newTopics = <String?, bool>{};
    if (await _notificationService.fetchTopics()) {
      for (TopicsModel model in _notificationService.topicsModel) {
        for (Topic topic in model.topics!) {
          newTopics[topic.topicId] = _topicSubscriptionState[topic.topicId] ?? false;
        }
      }
      _topicSubscriptionState = newTopics;
      _topicsModel = _notificationService.topicsModel;
      notifyListeners();
    }
  }

  /// Reads android device info and returns info as a Map
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'deviceId': build.id,
      'systemFeatures': build.systemFeatures,
    };
  }

  /// Reads ios device info returns info as a Map
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'deviceId': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  /// Registers device to receive push notifications
  Future<bool> registerDevice(String? accessToken) async {
    String? deviceId = _deviceData['deviceId'];
    if (deviceId == null) {
      _error = 'Failed to get device ID';
      return false;
    } else {
      // Get the token for this device
      String? fcmToken;
      try {
        fcmToken = await _fcm.getToken();
      } catch (error, stackTrace) {
        _error = 'Failed to get firebase token: $error';
        debugPrint('[PushNotifications] registerDevice getToken failed: $error');
        debugPrint(stackTrace.toString());
        return false;
      }
      final bool hasFcmToken = fcmToken != null && fcmToken.isNotEmpty;
      final bool hasAccessToken = accessToken?.isNotEmpty ?? false;
      debugPrint(
        '[PushNotifications] registerDevice deviceId=$deviceId '
        'hasFcmToken=$hasFcmToken hasAccessToken=$hasAccessToken',
      );
      if (hasFcmToken && hasAccessToken) {
        Map<String, String> headers = {'Authorization': 'Bearer ' + accessToken!};
        Map<String, String> body = {'deviceId': deviceId, 'token': fcmToken};
        if ((await _notificationService.postPushToken(headers, body))) {
          debugPrint('[PushNotifications] registerDevice postPushToken succeeded');
          return true;
        } else {
          _error = _notificationService.error;
          debugPrint('[PushNotifications] registerDevice postPushToken failed: $_error');
          return false;
        }
      } else {
        _error = 'Failed to get firebase token.';
        debugPrint('[PushNotifications] registerDevice failed: $_error');
        return false;
      }
    }
  }

  void _logRemoteMessage(String source, RemoteMessage message) {
    debugPrint(
      '[PushNotifications] $source '
      'messageId=${message.messageId} '
      'hasNotification=${message.notification != null} '
      'title=${message.notification?.title ?? message.data['title']} '
      'body=${message.notification?.body ?? message.data['body']} '
      'data=${message.data}',
    );
  }

  /// Unregisters device from receiving push notifications
  Future<bool> unregisterDevice(String? accessToken) async {
    String? fcmToken = await _fcm.getToken();
    final bool hasFcmToken = fcmToken != null && fcmToken.isNotEmpty;
    final bool hasAccessToken = accessToken?.isNotEmpty ?? false;
    if (hasFcmToken && hasAccessToken) {
      Map<String, String> headers = {'Authorization': 'Bearer ' + accessToken!};
      if ((await _notificationService.deletePushToken(headers, fcmToken))) {
        return true;
      } else {
        _error = _notificationService.error;
        return false;
      }
    } else {
      _error = 'Failed to delete firebase token.';
      return false;
    }
  }

  void unsubscribeFromAllTopics() {
    _unsubscribeToTopics(_topicSubscriptionState.keys.whereType<String>().toList());
    for (String? topic in _topicSubscriptionState.keys) {
      topicSubscriptionState[topic] = false;
    }
  }

  void toggleNotificationsForTopic(String topic) {
    if (_topicSubscriptionState[topic] ?? true) {
      _topicSubscriptionState[topic] = false;
      _unsubscribeToTopics([topic]);
    } else {
      _topicSubscriptionState[topic] = true;
      subscribeToTopics([topic]);
    }
    notifyListeners();
  }

  /// Iterates through passed in topics list
  /// Invokes [unsubscribeFromTopic] on firebase object [_fcm]
  void subscribeToTopics(List<String?> topics) {
    for (String? topic in topics) {
      if ((topic ?? "").isNotEmpty) {
        _topicSubscriptionState[topic] = true;
        if (topic != null) _fcm.subscribeToTopic(topic);
      }
    }
  }

  /// Iterates through passed in topics list
  /// Invokes [unsubscribeFromTopic] on firebase object [_fcm]
  void _unsubscribeToTopics(List<String> topics) {
    for (String topic in topics) {
      if (topic.isNotEmpty) {
        _topicSubscriptionState[topic] = false;
        _fcm.unsubscribeFromTopic(topic);
      }
    }
  }

  /// Get the topic name given the topic id
  String? getTopicName(String topicId) {
    for (TopicsModel model in _topicsModel) {
      for (Topic topic in model.topics!) {
        if (topic.topicId == topicId) return topic.topicMetadata!.name;
      }
    }
    return 'Topic not found';
  }

  /// Get student only topics
  List<String?> studentTopics() {
    List<String?> topicsToReturn = [];
    for (TopicsModel model in _notificationService.topicsModel) {
      if (model.audienceId == 'student') {
        for (Topic topic in model.topics!) {
          topicsToReturn.add(topic.topicId);
        }
        return topicsToReturn;
      }
    }
    return topicsToReturn;
  }

  /// Get staff only topics
  List<String?> staffTopics() {
    List<String?> topicsToReturn = [];
    for (TopicsModel model in _notificationService.topicsModel) {
      if (model.audienceId == 'staff') {
        for (Topic topic in model.topics!) {
          topicsToReturn.add(topic.topicId);
        }
        return topicsToReturn;
      }
    }
    return topicsToReturn;
  }

  /// Get all public topics
  List<String?> publicTopics() {
    List<String?> topicsToReturn = [];
    for (TopicsModel model in _topicsModel) {
      if (model.audienceId == 'all') {
        for (Topic topic in model.topics!) {
          topicsToReturn.add(topic.topicId);
        }
        return topicsToReturn;
      }
    }
    return topicsToReturn;
  }

  /// SIMPLE SETTERS
  Set<String> _receivedMessageIds = Set();

  /// SIMPLE GETTERS
  get error => _error;
  get lastUpdated => _lastUpdated;
  Map<String?, bool> get topicSubscriptionState => _topicSubscriptionState;
}
