import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/views/home/home.dart';
import 'package:campus_mobile_experimental/ui/views/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/views/notifications/notifications.dart';
import 'package:campus_mobile_experimental/ui/views/profile/profile.dart';

class BottomTabBar extends StatefulWidget {
  BottomTabBar(this.observer);

  final FirebaseAnalyticsObserver observer;

  static const String routeName = '/tab';

  final currentTabs = [
    Home(),
    prefix0.Maps(),
    Notifications(),
    Profile(),
  ];

  int selectedIndex = 0;

  final List<String> tabNames = ['home', 'maps', 'notifications', 'profile'];

  @override
  State<StatefulWidget> createState() => _BottomTabBarState(observer);
}

class _BottomTabBarState extends State<BottomTabBar>
    with SingleTickerProviderStateMixin, RouteAware {
  _BottomTabBarState(this.observer);

  final FirebaseAnalyticsObserver observer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    observer.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: IndexedStack(
          index: widget.selectedIndex, children: widget.currentTabs),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            widget.selectedIndex = index;
            _sendCurrentTabToAnalytics();
          });
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

  @override
  void didPush() {
    _sendCurrentTabToAnalytics();
  }

  @override
  void didPopNext() {
    _sendCurrentTabToAnalytics();
  }

  void _sendCurrentTabToAnalytics() {
    observer.analytics.setCurrentScreen(
      screenName:
          '${BottomTabBar.routeName}/${widget.tabNames[widget.selectedIndex]}',
    );
  }
}
