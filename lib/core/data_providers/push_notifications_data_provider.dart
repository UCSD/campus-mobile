import 'dart:io';
import 'package:campus_mobile_experimental/core/models/topics_model.dart';
import 'package:campus_mobile_experimental/core/services/notification_service.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PushNotificationDataProvider extends ChangeNotifier {
  PushNotificationDataProvider() {
    ///INITIALIZE SERVICES
    _notificationService = NotificationService();
    deviceInfoPlugin = DeviceInfoPlugin();
    _fcm = FirebaseMessaging();
    initState();
  }

  ///Models
  FirebaseMessaging _fcm;
  DeviceInfoPlugin deviceInfoPlugin;
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  ///STATES
  DateTime _lastUpdated;
  String _error;
  List<TopicsModel> _topicsModel;
  Map<String, bool> _topicSubscriptionState = <String, bool>{};

  ///SERVICES
  NotificationService _notificationService;

  /// invokes correct method to receive device info
  /// invokes [fetchTopicsList]
  initState() async {
    fetchTopicsList();
    if (Platform.isAndroid) {
      _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      _fcm.requestNotificationPermissions(const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: true));
      _fcm.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {});
    }
  }

  /// configures the [_fcm] object to recive push notifications
  /// TODO: deep linking also belongs here
  Future<void> initPlatformState(BuildContext context) async {
    try {
      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
        },
        //onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");

          /// navigate to routeName or home if no route was specified
          Navigator.of(context)
              .pushNamed(message["routeName"] ?? 'BottomTabBar');
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");

          /// navigate to routeName or home if no route was specified
          Navigator.of(context)
              .pushNamed(message["routeName"] ?? 'BottomTabBar');
        },
      );
    } on PlatformException {
      _error = 'Failed to get platform info.';
    }
  }

  /// fetches topics from endpoint
  /// deletes topics that are no longer supported
  /// transfers over previous subscriptions as well
  Future fetchTopicsList() async {
    Map<String, bool> newTopics = <String, bool>{};
    if (await _notificationService.fetchTopics()) {
      for (TopicsModel model in _notificationService.topicsModel) {
        for (Topic topic in model.topics) {
          newTopics[topic.topicId] =
              _topicSubscriptionState[topic.topicId] ?? false;
        }
      }
      _topicSubscriptionState = newTopics;
      _topicsModel = _notificationService.topicsModel;
    } else {
      _error = 'failed to fetch topics';
    }
    notifyListeners();
  }

  /// reads android device info
  /// returns info as a Map
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
      'deviceId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  /// reads ios device info
  /// returns info as a Map
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

  /// registers device to receive push notifications
  Future<bool> registerDevice(String accessToken) async {
    String deviceId = _deviceData['deviceId'];
    if (deviceId == null) {
      _error = 'Failed to get device ID';
      return false;
    } else {
      // Get the token for this device
      String fcmToken = await _fcm.getToken();
      if (fcmToken.isNotEmpty && (accessToken?.isNotEmpty ?? false)) {
        Map<String, String> headers = {
          'Authorization': 'Bearer ' + accessToken
        };
        Map<String, String> body = {'deviceId': deviceId, 'token': fcmToken};
        if ((await _notificationService.postPushToken(headers, body))) {
          return true;
        } else {
          _error = _notificationService.error;
          return false;
        }
      } else {
        _error = 'Failed to get firebase token.';
        return false;
      }
    }
  }

  /// unregisters device from receiving push notifications
  Future<bool> unregisterDevice(String accessToken) async {
    // Get the token for this device
    String fcmToken = await _fcm.getToken();
    if (fcmToken.isNotEmpty && (accessToken?.isNotEmpty ?? false)) {
      Map<String, String> headers = {'Authorization': 'Bearer ' + accessToken};
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
    _unsubscribeToTopics(_topicSubscriptionState.keys.toList());
    for (String topic in _topicSubscriptionState.keys) {
      topicSubscriptionState[topic] = false;
    }
  }

  void toggleNotificationsForTopic(String topic) {
    if (_topicSubscriptionState[topic] ?? true) {
      _topicSubscriptionState[topic] = false;
      _unsubscribeToTopics([topic]);
    } else {
      _topicSubscriptionState[topic] = true;
      _subscribeToTopics([topic]);
    }
    notifyListeners();
  }

  /// iterates through passed in topics list
  /// invokes [unsubscribeFromTopic] on firebase object [_fcm]
  void _subscribeToTopics(List<String> topics) {
    for (String topic in topics) {
      if ((topic ?? "").isNotEmpty) {
        _topicSubscriptionState[topic] = true;
        _fcm.subscribeToTopic(topic);
      }
    }
  }

  /// iterates through passed in topics list
  /// invokes [unsubscribeFromTopic] on firebase object [_fcm]
  void _unsubscribeToTopics(List<String> topics) {
    for (String topic in topics) {
      if ((topic ?? "").isNotEmpty) {
        _topicSubscriptionState[topic] = false;
        _fcm.unsubscribeFromTopic(topic);
      }
    }
  }

  /// get the topic name given the topic id
  String getTopicName(String topicId) {
    for (TopicsModel model in _topicsModel) {
      for (Topic topic in model.topics) {
        if (topic.topicId == topicId) {
          return topic.topicMetadata.name;
        }
      }
    }
  }

  /// get student only topics
  List<String> studentTopics() {
    List<String> topicsToReturn = List<String>();
    for (TopicsModel model in _notificationService.topicsModel ?? []) {
      if (model.audienceId == 'student') {
        for (Topic topic in model.topics) {
          topicsToReturn.add(topic.topicId);
        }
        return topicsToReturn;
      }
    }
    return topicsToReturn;
  }

  /// get all public topics
  List<String> publicTopics() {
    List<String> topicsToReturn = List<String>();
    for (TopicsModel model in _topicsModel ?? []) {
      if (model.audienceId == 'all') {
        for (Topic topic in model.topics) {
          topicsToReturn.add(topic.topicId);
        }
        return topicsToReturn;
      }
    }
    return topicsToReturn;
  }

  ///SIMPLE GETTERS
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  Map<String, bool> get topicSubscriptionState => _topicSubscriptionState;
}
