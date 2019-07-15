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
            ],
          ),
        ),
      ],
    ),
  );
}

class HomeState extends State<Home> {
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
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}
