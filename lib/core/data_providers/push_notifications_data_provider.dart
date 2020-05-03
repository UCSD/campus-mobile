import 'dart:io';
import 'package:campus_mobile_experimental/core/services/notification_service.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class PushNotificationDataProvider {
  PushNotificationDataProvider() {
    ///INITIALIZE SERVICES
    _notificationService = NotificationService();
    initPlatformState();
  }

  ///Models
  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  ///STATES
  DateTime _lastUpdated;
  String _error;

  ///SERVICES
  NotificationService _notificationService;

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        _fcm.requestNotificationPermissions(const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
        _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
          print("Settings registered: $settings");
        });
      }
      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
        },
        //onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          //_navigateToItemDetail(message);
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          //_navigateToItemDetail(message);
        },
      );
    } on PlatformException {
      _error = 'Failed to get platform info.';
    }
  }

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

  Future<bool> registerDevice(String accessToken) async {
    if (_error == null) {
      String deviceId = _deviceData['deviceId'];
      if (deviceId == null) {
        _error = 'Failed to get device ID';
        return false;
      } else {
        // Get the token for this device
        String fcmToken = await _fcm.getToken();
        print('token is: ' + fcmToken);
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
    } else {
      return false;
    }
  }

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

  ///SIMPLE GETTERS
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
}
