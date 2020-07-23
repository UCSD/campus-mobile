import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/navigation/push_notification_wrapper.dart';
import 'package:campus_mobile_experimental/core/navigation/top_navigation_bar/app_bar.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/ui/views/home/home.dart';
import 'package:campus_mobile_experimental/ui/views/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/views/notifications/notifications_list_view.dart';
import 'package:campus_mobile_experimental/ui/views/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/navigation/top_navigation_bar/app_bar.dart';

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
            case NavigationConstants.HomeTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle(null);
              break;
            case NavigationConstants.MapTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Maps");
              break;
            case NavigationConstants.NotificationsTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Notifications");
              break;
            case NavigationConstants.ProfileTab:
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Profile");
              break;
          }
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
