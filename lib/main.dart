import 'dart:async';
import 'dart:io';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/app_router.dart' as campusMobileRouter;
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message_persistent.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

var showOnboardingScreen = true;
var isFirstRunFlag = false;
var executedInitialDeeplinkQuery = false;

void main() async {
  /// Record zoned errors - https://firebase.flutter.dev/docs/crashlytics/usage#zoned-errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    final mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      WidgetsFlutterBinding.ensureInitialized();
      await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
    }

    // dotenv loading
    await dotenv.load(isOptional: true);

    // Uncomment to remove the "Licensed for Developer Use Only" watermark in the ESRI Map
    // final esriApiKey = dotenv.env['ESRI_API_KEY'];
    // if (esriApiKey != null && esriApiKey.isNotEmpty) {
    //   ArcGISEnvironment.apiKey = esriApiKey;
    // }
    //
    // final esriLicenseKey = dotenv.env['ESRI_LICENSE_KEY'];
    // if (esriLicenseKey != null && esriLicenseKey.isNotEmpty) {
    //   ArcGISEnvironment.setLicense(esriLicenseKey);
    // }

    /// Enable crash analytics - https://firebase.flutter.dev/docs/crashlytics/usage#toggle-crashlytics-collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    /// Record uncaught errors - https://firebase.flutter.dev/docs/crashlytics/usage#handling-uncaught-errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await initializeHive();
    await initializeApp();
    runApp(CampusMobile());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

Future<void> initializeHive() async {
  await Hive.initFlutter('.');
  Hive.registerAdapter(AuthenticationModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());
  Hive.registerAdapter(ChatMessagePersistentAdapter());
}

Future<void> initializeApp() async {
  final prefs = await SharedPreferences.getInstance();

  // TODO: fix this. We don't need two different persistent flags... - December 2025
  if (prefs.getBool('first_run') ?? true) {
    await clearSecuredStorage();
    await clearHiveStorage();
    prefs.setBool('showOnboardingScreen', true);
    prefs.setBool('first_run', false);
  }

  showOnboardingScreen = prefs.getBool('showOnboardingScreen') ?? true;
}

Future<void> clearSecuredStorage() async {
  // await StorageService.clearAll();
  FlutterSecureStorage storage = FlutterSecureStorage();
  await storage.deleteAll();
}

// TODO: refactor this to load multiple futures in one statement - December 2025
Future<void> clearHiveStorage() async {
  await (await Hive.openBox(DataPersistence.CARD_STATES)).deleteFromDisk();
  await (await Hive.openBox(DataPersistence.CARD_ORDER)).deleteFromDisk();
  await (await Hive.openBox(DataPersistence.AUTHENTICATION_MODEL)).deleteFromDisk();
  await (await Hive.openBox(DataPersistence.USER_PROFILE_MODEL)).deleteFromDisk();
}

class CampusMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: false,
      primaryColor: lightPrimaryColor,
      textTheme: lightThemeText.copyWith(
        titleLarge: cardTitleStyleLight,
        titleMedium: titleMediumLight,
        titleSmall: titleSmallLight,
        bodyLarge: heading2StyleLight,
        bodyMedium: bodyMediumLight,
        bodySmall: descriptiveTextSmallLight,
        labelLarge: labelLargeStyleLight,
        labelMedium: labelMediumStyleLight,
        headlineMedium: headlineMediumLight,
      ),
      iconTheme: lightIconTheme,
      appBarTheme: lightAppBarTheme,
      listTileTheme: lightListTileTheme,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: ColorPrimary,
      ).copyWith(surface: lightButtonColor, brightness: Brightness.light),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        unselectedItemColor: unselectedIconLightColor,
        selectedItemColor: Colors.white,
        backgroundColor: bottomTabBarColorLight,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: false,
      primaryColor: darkPrimaryColor,
      textTheme: darkThemeText.copyWith(
        titleLarge: cardTitleStyleDark,
        titleMedium: titleMediumDark,
        titleSmall: titleSmallDark,
        bodyLarge: heading2StyleDark,
        bodyMedium: bodyMediumDark,
        bodySmall: descriptiveTextSmallDark,
        labelLarge: labelLargeStyleDark,
        labelMedium: labelMediumStyleDark,
        headlineMedium: headlineMediumDark,
      ),
      iconTheme: darkIconTheme,
      appBarTheme: darkAppBarTheme,
      unselectedWidgetColor: darkAccentColor,
      listTileTheme: darkListTileTheme,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: ColorPrimary,
      ).copyWith(surface: darkButtonColor, brightness: Brightness.dark),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        unselectedItemColor: unselectedIconDarkColor,
        selectedItemColor: bottomTabBarColorDark,
        backgroundColor: bottomTabBarColorDark,
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(color: Colors.white),
        backgroundColor: Color(0xFF323232),
      ),
    );

    return MultiProvider(
      providers: providers,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'UC San Diego',
        theme: lightTheme.copyWith(colorScheme: lightTheme.colorScheme.copyWith(secondary: darkAccentColor)),
        darkTheme: darkTheme.copyWith(colorScheme: darkTheme.colorScheme.copyWith(secondary: lightAccentColor)),
        themeMode: ThemeMode.system,
        initialRoute: showOnboardingScreen ? RoutePaths.ONBOARDING_LOGIN : RoutePaths.BOTTOM_NAVIGATION_BAR,
        onGenerateRoute: campusMobileRouter.Router.generateRoute,
        navigatorObservers: [observer],
        builder: (context, child) {
          return SafeArea(top: false, bottom: Platform.isAndroid, child: child!);
        },
      ),
    );
  }
}
