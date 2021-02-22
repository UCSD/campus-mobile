import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/app_router.dart'
    as campusMobileRouter;
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'core/providers/bottom_nav.dart';
import 'core/providers/map.dart';
import 'core/providers/messages.dart';

bool isFirstRunFlag = false;
bool executedInitialDeeplinkQuery = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeStorage();
  runApp(CampusMobile());
}

void initializeStorage() async {
  /// initialize hive storage
  await Hive.initFlutter('.');

  //register appropriate hive boxes
  await Hive.registerAdapter(AuthenticationModelAdapter());
  await Hive.registerAdapter(UserProfileModelAdapter());

  isFirstRunFlag = await isFirstRun();

  if (isFirstRunFlag) {
    FlutterSecureStorage storage = FlutterSecureStorage();

    /// open all boxes
    await (await Hive.openBox(DataPersistence.cardStates)).deleteFromDisk();
    await (await Hive.openBox(DataPersistence.cardOrder)).deleteFromDisk();
    await (await Hive.openBox(DataPersistence.AuthenticationModel))
        .deleteFromDisk();
    await (await Hive.openBox(DataPersistence.UserProfileModel))
        .deleteFromDisk();

    /// delete all saved data
    await storage.deleteAll();

    setFirstRun();
  }
}

Future<bool> isFirstRun() async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getBool('first_run') ?? true);
}

void setFirstRun() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('first_run', false);
  isFirstRunFlag = true;
}

class CampusMobile extends StatelessWidget {

  StreamSubscription _sub;

  Future<Null> initUniLinks(BuildContext context) async {
    // deep links are received by this method
    // the specific host needs to be added in AndroidManifest.xml and Info.plist
    // currently, this method handles executing custom map query
    _sub = getLinksStream().listen((String link) async {
      // handling for map query
      String initialLink = await getInitialLink();
      if(initialLink != null) {
        if(initialLink.contains("deeplinking.searchmap")) {
          var uri = Uri.dataFromString(initialLink);
          var query = uri.queryParameters['query'];
          // redirect query to maps tab and search with query
          Provider.of<MapsDataProvider>(context, listen: false)
              .searchBarController
              .text = query;
          Provider.of<MapsDataProvider>(context, listen: false)
              .fetchLocations();
          Provider.of<BottomNavigationBarProvider>(context, listen: false)
              .currentIndex = NavigatorConstants.MapTab;
        }
    }
    });
  }

  @override
  Widget build(BuildContext context) {
//    initUniLinks(context);
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
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
          unselectedWidgetColor: darkAccentColor,
        ),
        initialRoute: isFirstRunFlag
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
