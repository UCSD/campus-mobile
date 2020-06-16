import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/provider_setup.dart';
import 'package:campus_mobile_experimental/core/navigation/router.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool showOnboardingScreen = true;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeStorage();

  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(CampusMobile());
}

void initializeStorage() async {
  /// initialize hive storage
  Hive.initFlutter('.');

  if (await isFirstRun()) {
    FlutterSecureStorage storage = FlutterSecureStorage();

    /// delete any saved data
    await Hive.deleteFromDisk();
    await storage.deleteAll();
    setFirstRun();
  } else {
    showOnboardingScreen = false;
  }
}

Future<bool> isFirstRun() async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getBool('first_run') ?? true);
}

void setFirstRun() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('first_run', false);
  showOnboardingScreen = true;
}

class CampusMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'UC San Diego',
        theme: ThemeData(
          primarySwatch: ColorPrimary,
          primaryColor: lightPrimaryColor,
          accentColor: darkAccentColor,
          brightness: Brightness.light,
          buttonColor: lightButtonColor,
          textTheme: lightThemeText,
          iconTheme: lightIconTheme,
          appBarTheme: lightAppBarTheme,
        ),
        darkTheme: ThemeData(
          primarySwatch: ColorPrimary,
          primaryColor: darkPrimaryColor,
          accentColor: lightAccentColor,
          brightness: Brightness.dark,
          buttonColor: darkButtonColor,
          textTheme: darkThemeText,
          iconTheme: darkIconTheme,
          appBarTheme: darkAppBarTheme,
        ),
        initialRoute: showOnboardingScreen
            ? RoutePaths.Onboarding
            : RoutePaths.BottomNavigationBar,
        onGenerateRoute: Router.generateRoute,
        navigatorObservers: [
          observer,
        ],
      ),
    );
  }
}
