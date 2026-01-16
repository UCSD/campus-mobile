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
import 'package:campus_mobile_experimental/core/providers/user.dart'; // ai assistant
import 'package:campus_mobile_experimental/ui/ai_assistant/assistant.dart'; // ai assistant

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
    ChatPage(), // index 2 -> AI Assistant Center
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
      appBar: PreferredSize(preferredSize: Size.fromHeight(50), child: Provider.of<CustomAppBar>(context).appBar),
      body: PushNotificationWrapper(child: currentTab[provider.currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
            // Disable AI Assistant tab if not logged in
            if (index == 2 && !Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please log in to use the AI Assistant.')),
              );
              return;
            } // Prevents access to chatbot unless user is logged in
            provider.currentIndex = index;
            // When switching tabs, assistant.dart's chat history is cleared (RAM only)
            // To persist chat history, you would need to implement local storage or backend fetch
            switch (index) {
              case NavigatorConstants.HOME_TAB:
                Provider.of<CustomAppBar>(context, listen: false).changeTitle(null);
                break;
              case NavigatorConstants.MAP_TAB:
                resetAllCardLoadedStates();
                Provider.of<CustomAppBar>(context, listen: false).changeTitle("Maps");
                break;
              case NavigatorConstants.CHAT_TAB: // AI Assistant center index
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
              // AI Assistant center index
              icon: _buildIcon(Icons.smart_toy, provider.currentIndex == 2, theme),
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
  Widget _buildIcon(IconData icon, bool isSelected, ThemeData theme, {double size = 34}) {
    return Container(
      height: 34,
      margin: EdgeInsets.only(top: size == 34 ? 4 : 2),
      padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
      decoration: BoxDecoration(
        color: isSelected ? theme.listTileTheme.selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Icon(
        icon,
        size: size,
        color: isSelected
            ? theme.bottomNavigationBarTheme.selectedItemColor
            : theme.bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}
