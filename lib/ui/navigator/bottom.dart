import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/wrappers/push_notifications.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_list_view.dart';
import 'package:campus_mobile_experimental/ui/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomTabBar extends StatefulWidget {
  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  var currentTab = [
    Home(),
    prefix0.Maps(),
    NotificationsListView(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: Provider.of<CustomAppBar>(context).appBar),
      body: PushNotificationWrapper(child: currentTab[provider.currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: provider.currentIndex,
        onTap: (index) {
          provider.currentIndex = index;
          switch (index) {
            case NavigatorConstants.HomeTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle(null);
              break;
            case NavigatorConstants.MapTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Maps");
              break;
            case NavigatorConstants.NotificationsTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Notifications");
              break;
            case NavigatorConstants.ProfileTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Profile");
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.person),
            label: 'User Profile',
          ),
        ],
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        selectedItemColor: IconTheme.of(context).color,
        unselectedItemColor: Colors.grey.shade500,
      ),
    );
  }
}
