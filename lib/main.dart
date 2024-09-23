import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/app_router.dart' as campusMobileRouter;
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late bool showOnboardingScreen;

bool isFirstRunFlag = false;
bool executedInitialDeeplinkQuery = false;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AndroidMapRenderer mapRenderer = AndroidMapRenderer.platformDefault;
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    mapRenderer = await mapsImplementation
        .initializeWithRenderer(AndroidMapRenderer.latest);
  }

  // dotenv loading
  await dotenv.load(isOptional: true);

  // Initialize notification plugin
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

  /// Record zoned errors - https://firebase.flutter.dev/docs/crashlytics/usage#zoned-errors
  runZonedGuarded<Future<void>>(() async {
    /// Enable crash analytics - https://firebase.flutter.dev/docs/crashlytics/usage#toggle-crashlytics-collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    /// Record uncaught errors - https://firebase.flutter.dev/docs/crashlytics/usage#handling-uncaught-errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await initializeHive();
    await initializeApp();
    runApp(CampusMobile());
  }, FirebaseCrashlytics.instance.recordError);
}

Future onSelectNotification(String? payload) async {
  if (payload == 'whats_around_me') {
    Get.toNamed('/whats_around_me');
  }
}

initializeHive() async {
  await Hive.initFlutter('.');
  Hive.registerAdapter(AuthenticationModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());
}

initializeApp() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('first_run') ?? true) {
    await clearSecuredStorage();
    await clearHiveStorage();
    prefs.setBool('showOnboardingScreen', true);
    prefs.setBool('first_run', false);
  }

  showOnboardingScreen = prefs.getBool('showOnboardingScreen') ?? true;
  await _checkLocationPermission();
  await showWhatsAroundMeNotification(); // Show notification on app startup
}

Future<void> showWhatsAroundMeNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'UC San Diego',
    'Find a list of interesting nearby places that you didn\'t know existed in our campus.',
    platformChannelSpecifics,
    payload: 'whats_around_me',
  );
}

Future<void> _checkLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  print(position);
}

clearSecuredStorage() async {
  FlutterSecureStorage storage = FlutterSecureStorage();
  await storage.deleteAll();
}

clearHiveStorage() async {
  await (await Hive.openBox(DataPersistence.cardStates)).deleteFromDisk();
  await (await Hive.openBox(DataPersistence.cardOrder)).deleteFromDisk();
  await (await Hive.openBox(DataPersistence.AuthenticationModel))
      .deleteFromDisk();
  await (await Hive.openBox(DataPersistence.UserProfileModel)).deleteFromDisk();
}

class CampusMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primarySwatch: ColorPrimary,
      primaryColor: lightPrimaryColor,
      brightness: Brightness.light,
      backgroundColor: lightButtonColor, // updated
      textTheme: lightThemeText,
      iconTheme: lightIconTheme,
      appBarTheme: lightAppBarTheme,
    );

    final ThemeData darkTheme = ThemeData(
      primarySwatch: ColorPrimary,
      primaryColor: darkPrimaryColor,
      brightness: Brightness.dark,
      backgroundColor: darkButtonColor, // updated
      textTheme: darkThemeText,
      iconTheme: darkIconTheme,
      appBarTheme: darkAppBarTheme,
      unselectedWidgetColor: darkAccentColor,
    );

    return MultiProvider(
      providers: providers,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'UC San Diego',
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(secondary: darkAccentColor),
        ),
        darkTheme: darkTheme.copyWith(
          colorScheme:
          darkTheme.colorScheme.copyWith(secondary: lightAccentColor),
        ),
        initialRoute: showOnboardingScreen
            ? RoutePaths.OnboardingInitial
            : RoutePaths.BottomNavigationBar,
        onGenerateRoute: campusMobileRouter.Router.generateRoute,
        navigatorObservers: [
          observer,
        ],
      ),
    );
  }
}
