import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/wrappers/push_notifications.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_list_view.dart';
import 'package:campus_mobile_experimental/ui/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---saved scroll offsets for Home Screen---
var _homeScrollOffset = 0.0;
double getHomeScrollOffset() => _homeScrollOffset;
void setHomeScrollOffset(double currentScrollOffset) =>
    _homeScrollOffset = currentScrollOffset;
void resetHomeScrollOffset() => _homeScrollOffset = 0.0;

// ---saved scroll offsets for Notification Screen---
var _notificationsScrollOffset = 0.0;
double getNotificationsScrollOffset() => _notificationsScrollOffset;
void setNotificationsScrollOffset(double currentScrollOffset) =>
    _notificationsScrollOffset = currentScrollOffset;
void resetNotificationsScrollOffset() => _notificationsScrollOffset = 0.0;

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
    final theme = Theme.of(context);

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      backgroundColor: provider.currentIndex == 0
          ? lightPrimaryColor
          : theme.scaffoldBackgroundColor,
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
              resetAllCardLoadedStates();
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Maps");
              break;
            case NavigatorConstants.NotificationsTab:
              resetAllCardLoadedStates();
              Provider.of<CustomAppBar>(context, listen: false).changeTitle(
                  "Notifications",
                  done: false,
                  notification: true);
              break;
            case NavigatorConstants.ProfileTab:
              resetAllCardLoadedStates();
              Provider.of<CustomAppBar>(context, listen: false)
                  .changeTitle("Profile");
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, provider.currentIndex == 0, theme),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.map, provider.currentIndex == 1, theme),
            label: 'MAP',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
                Icons.notifications, provider.currentIndex == 2, theme),
            label: 'NOTIFICATIONS',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person, provider.currentIndex == 3, theme),
            label: 'PROFILE',
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        elevation: 4,
      ),
    );
  }

// Build bottom navigator icons
  Widget _buildIcon(IconData icon, bool isSelected, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color:
            isSelected ? theme.listTileTheme.selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Icon(
        icon,
        size: 32,
        color: isSelected
            ? theme.bottomNavigationBarTheme.selectedItemColor
            : theme.bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}
