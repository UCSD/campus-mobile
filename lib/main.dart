//This will be the style guide used for this project
//https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo
import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:campus_mobile/provider.dart';
import 'package:campus_mobile/ui/router.dart';
import 'package:campus_mobile/ui/theme/app_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'UC San Diego',
        theme: ThemeData(
          primarySwatch: ColorPrimary,
          accentColor: Color(0xFFFFFFFF),
          brightness: Brightness.light,
          buttonColor: Color(0xFF034263),
          iconTheme: IconThemeData(
            color: Colors.blue[900],
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: ColorPrimary,
          accentColor: ColorPrimary,
          brightness: Brightness.dark,
          buttonColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
            color: Color(0xFFFFFFFF),
          ),
        ),
        initialRoute: RoutePaths.Home,
        onGenerateRoute: Router.generateRoute,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }
}
