import 'package:campus_mobile_experimental/core/navigation/router.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:campus_mobile_experimental/core/navigation/bottom_tab_bar/bottom_navigation_bar_model.dart';
import 'package:campus_mobile_experimental/core/data_providers/provider_setup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// initialize hive storage
  Hive.initFlutter('.');

  /// this will clear out any old signed in users
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('first_run') ?? true) {
    FlutterSecureStorage storage = FlutterSecureStorage();

    /// delete any saved data
    await Hive.deleteFromDisk();
    await storage.deleteAll();
    prefs.setBool('first_run', false);
  }

  runApp(CampusMobile());
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
          accentColor: lightAccentColor,
          brightness: Brightness.light,
          buttonColor: lightButtonColor,
          textTheme: lightThemeText,
          iconTheme: lightIconTheme,
          appBarTheme: lightAppBarTheme,
        ),
        darkTheme: ThemeData(
          primarySwatch: ColorPrimary,
          accentColor: darkAccentColor,
          brightness: Brightness.dark,
          buttonColor: darkButtonColor,
          textTheme: darkThemeText,
          iconTheme: darkIconTheme,
          appBarTheme: darkAppBarTheme,
        ),
        home: BottomTabBar(),
        onGenerateRoute: Router.generateRoute,
        navigatorObservers: [
          observer,
        ],
      ),
    );
  }
}
