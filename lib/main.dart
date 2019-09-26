//This will be the style guide used for this project
//https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo

import 'package:flutter/material.dart';

import 'core/viewmodels/weather.dart';
import 'placeholder_widget.dart';
import 'profile_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MaterialColor ucsdPrimaryBlue = MaterialColor(
    0xFF034263,
    <int, Color>{
      50: Color(0xFF034263),
      100: Color(0xFF034263),
      200: Color(0xFF034263),
      300: Color(0xFF034263),
      400: Color(0xFF034263),
      500: Color(0xFF034263),
      600: Color(0xFF034263),
      700: Color(0xFF034263),
      800: Color(0xFF034263),
      900: Color(0xFF034263),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UC San Diego',
      theme: ThemeData(
        primarySwatch: ucsdPrimaryBlue,
      ),
      home: Home(),
    );
  }
}

class HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);

  final List<Widget> _children = <Widget>[
    Weather(),
    PlaceholderWidget(Colors.deepOrange), // map
    PlaceholderWidget(Colors.blue), // messages
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
