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
import 'package:campus_mobile_experimental/ui/tgpt/tgpt.dart';

// ---saved scroll offsets for Home Screen---
var _homeScrollOffset = 0.0;
double getHomeScrollOffset() => _homeScrollOffset;
void setHomeScrollOffset(double currentScrollOffset) => _homeScrollOffset = currentScrollOffset;
void resetHomeScrollOffset() => _homeScrollOffset = 0.0;

// ---saved scroll offsets for Notification Screen---
var _notificationsScrollOffset = 0.0;
double getNotificationsScrollOffset() => _notificationsScrollOffset;
void setNotificationsScrollOffset(double currentScrollOffset) => _notificationsScrollOffset = currentScrollOffset;
void resetNotificationsScrollOffset() => _notificationsScrollOffset = 0.0;

class BottomTabBar extends StatefulWidget {
  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  var currentTab = [
    Home(),
    prefix0.Maps(),
    ChatPage(),
    NotificationsListView(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      backgroundColor: provider.currentIndex == 0 ? lightPrimaryColor : theme.scaffoldBackgroundColor,
      appBar: provider.currentIndex == 2
          ? null
          : PreferredSize(preferredSize: Size.fromHeight(50), child: Provider.of<CustomAppBar>(context).appBar),
      body: PushNotificationWrapper(child: currentTab[provider.currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, -2),
            ),
          ],
        ),
        height: 73,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: provider.currentIndex,
          onTap: (index) {
            provider.currentIndex = index;
            switch (index) {
              case NavigatorConstants.HOME_TAB:
                Provider.of<CustomAppBar>(context, listen: false).changeTitle(null);
                break;
              case NavigatorConstants.MAP_TAB:
                resetAllCardLoadedStates();
                Provider.of<CustomAppBar>(context, listen: false).changeTitle("Maps");
                break;
              case NavigatorConstants.CHAT_TAB:
                resetAllCardLoadedStates();
                Provider.of<CustomAppBar>(context, listen: false).changeTitle("AI Assistant");
                break;
              case NavigatorConstants.NOTIFICATIONS_TAB:
                resetAllCardLoadedStates();
                Provider.of<CustomAppBar>(context, listen: false)
                    .changeTitle("Notifications", done: false, notification: true);
                break;
              case NavigatorConstants.PROFILE_TAB:
                resetAllCardLoadedStates();
                Provider.of<CustomAppBar>(context, listen: false).changeTitle("Profile");
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
                'assets/images/tgpt/center-icon.png',
                provider.currentIndex == 2,
                theme,
                isImage: true,
                size: 30,
              ),
              label: 'AI Assistant',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.notifications, provider.currentIndex == 3, theme),
              label: 'NOTIFICATIONS',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.person, provider.currentIndex == 4, theme, size: 38),
              label: 'PROFILE',
            ),
          ],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          elevation: 4,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 34,
        ),
      ),
    );
  }

// Build bottom navigator icons
  Widget _buildIcon(dynamic icon, bool isSelected, ThemeData theme, {double size = 34, bool isImage = false}) {
    final isStandardSize = size == 34;
    final isIOS = theme.platform == TargetPlatform.iOS;
    final containerHeight = isIOS ? 36.0 : 42.0;
    final topMargin = isIOS ? (isStandardSize ? 2.0 : 0.0) : (isStandardSize ? 8.0 : 6.0);
    final verticalPadding = isIOS ? 1.0 : 3.0;
    final containerShift = isIOS ? 3.5 : 0.0;
    return Transform.translate(
      offset: Offset(0, containerShift),
      child: Container(
        height: containerHeight,
        margin: EdgeInsets.only(top: topMargin),
        padding: EdgeInsets.only(left: 16, right: 16, top: verticalPadding, bottom: verticalPadding),
        decoration: BoxDecoration(
          color: isSelected ? theme.listTileTheme.selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(34),
        ),
        child: isImage
            ? Image.asset(
                icon as String,
                width: size,
                height: size,
                color: isSelected
                    ? theme.bottomNavigationBarTheme.selectedItemColor
                    : theme.bottomNavigationBarTheme.unselectedItemColor,
              )
            : Icon(
                icon as IconData,
                size: size,
                color: isSelected
                    ? theme.bottomNavigationBarTheme.selectedItemColor
                    : theme.bottomNavigationBarTheme.unselectedItemColor,
              ),
      ),
    );
  }
}
