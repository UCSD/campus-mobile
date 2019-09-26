import 'package:campus_mobile/ui/widgets/cards/news_list.dart';
import 'package:flutter/material.dart';

import 'package:campus_mobile/core/viewmodels/weather.dart';
import 'package:campus_mobile/ui/views/map.dart';
import 'package:campus_mobile/ui/views/notifications.dart';
import 'package:campus_mobile/ui/views/profile.dart';

class HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);

  final List<Widget> _children = <Widget>[
    ListView(
      children: <Widget>[
        Weather(),
        NewsList(),
      ],
    ),
    Map(Colors.deepOrange), // map
    Notifications(Colors.blue), // notifications
    Profile(), // profile
  ];

  Weather weatherCard;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/UCSanDiegoLogo-nav.png',
            width: 200,
          ),
        ),
      ),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            title: Text('Messages'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey[500],
        onTap: _onItemTapped,
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}
