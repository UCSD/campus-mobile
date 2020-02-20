import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/ui/views/home/home.dart';
import 'package:campus_mobile_experimental/ui/views/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/views/notifications/notifications.dart';
import 'package:campus_mobile_experimental/ui/views/profile/profile.dart';

class BottomTabBar extends StatefulWidget {
  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  var currentTab = [
    Home(),
    prefix0.Maps(),
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
      body: IndexedStack(index: provider.currentIndex, children: currentTab),
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
