//This will be the style guide used for this project
//https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final ucsdBackgroundColor = const Color(0x034263);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UCSD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

Widget buildWeatherCard() {
  return Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const ListTile(
          leading: Icon(Icons.wb_sunny),
          title: Text('72 in San Diego'),
          subtitle: Text('Clear'),
        ),
        Row(
          children: <Widget>[
            Container(
              width: 70,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text('MON'),
                  Icon(Icons.wb_cloudy),
                  Text('74'),
                  Text('61'),
                ],
              ),
            ),
            Container(
              width: 70,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text('TUE'),
                  Icon(Icons.wb_sunny),
                  Text('74'),
                  Text('61'),
                ],
              ),
            ),
            Container(
              width: 70,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text('WED'),
                  Icon(Icons.wb_sunny),
                  Text('74'),
                  Text('61'),
                ],
              ),
            ),
            Container(
              width: 70,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text('THU'),
                  Icon(Icons.wb_sunny),
                  Text('74'),
                  Text('61'),
                ],
              ),
            ),
            Container(
              width: 70,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text('FRI'),
                  Icon(Icons.wb_sunny),
                  Text('74'),
                  Text('61'),
                ],
              ),
            ),
          ],
        ),
        ButtonTheme.bar(
          // make buttons use the appropriate styles for cards
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text('Surf Report'),
                onPressed: () {/* ... */},
              ),
              FlatButton(
                child: Icon(Icons.more_vert),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: Profile',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UCSD"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            buildWeatherCard(),
          ],
        ),
      ),
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
