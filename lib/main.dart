import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile/ui/router.dart';
import 'package:campus_mobile/ui/theme/app_theme.dart';

import 'package:campus_mobile/ui/views/home.dart';
import 'package:campus_mobile/ui/views/map.dart';
import 'package:campus_mobile/ui/views/notifications.dart';
import 'package:campus_mobile/ui/views/profile.dart';

void main() => runApp(CampusMobile());

class CampusMobile extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UC San Diego',
      theme: ThemeData(
        primarySwatch: ColorPrimary,
      ),
      home: ChangeNotifierProvider<BottomNavigationBarProvider>(
        child: BottomNavigationBarExample(),
        builder: (BuildContext context) => BottomNavigationBarProvider(),
      ),
      onGenerateRoute: Router.generateRoute,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  @override
  _BottomNavigationBarExampleState createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  var currentTab = [
    Home(),
    Map(),
    Notifications(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/UCSanDiegoLogo-nav.png',
            width: 200,
          ),
        ),
      ),
      body: currentTab[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentIndex,
        onTap: (index) {
          provider.currentIndex = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.map),
            title: new Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.notifications),
            title: new Text('Notifications'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.person),
            title: new Text('User Profile'),
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: ColorPrimary,
        unselectedItemColor: Colors.grey.shade500,
      ),
    );
  }
}




class BottomNavigationBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}








//This will be the style guide used for this project
//https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo

//import 'package:flutter/material.dart';
//
//import 'package:provider/provider.dart';
//import 'package:campus_mobile/provider.dart';
//import 'package:campus_mobile/core/constants/app_constants.dart';
//import 'package:campus_mobile/ui/router.dart';
//import 'package:campus_mobile/ui/theme/app_theme.dart';
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//
//
//  @override
//  Widget build(BuildContext context) {
//      return MaterialApp(
//
//        initialRoute: RoutePaths.Home,
//
//      ),
//    );
//  }
//}
