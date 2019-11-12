import 'package:campus_mobile_beta/provider_setup.dart' as prefix0;
import 'package:campus_mobile_beta/ui/router.dart';
import 'package:campus_mobile_beta/ui/theme/app_theme.dart';
import 'package:campus_mobile_beta/ui/views/home.dart';
import 'package:campus_mobile_beta/ui/views/map.dart';
import 'package:campus_mobile_beta/ui/views/notifications.dart';
import 'package:campus_mobile_beta/ui/views/profile.dart';
import 'package:campus_mobile_beta/core/services/availability_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(CampusMobile());

class CampusMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AvailabilityService>(
      builder: (context) => AvailabilityService(),
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
        home: ChangeNotifierProvider<BottomNavigationBarProvider>(
          child: BottomNavigationBarExample(),
          builder: (BuildContext context) => BottomNavigationBarProvider(),
        ),
        onGenerateRoute: Router.generateRoute,
      ),
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          primary: true,
          centerTitle: true,
          title: Image.asset(
            'assets/images/UCSanDiegoLogo-nav.png',
            fit: BoxFit.contain,
            height: 28,
          ),
        ),
      ),
      body: currentTab[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
        selectedItemColor: IconTheme.of(context).color,
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
