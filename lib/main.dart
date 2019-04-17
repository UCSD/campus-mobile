//This will be the style guide used for this project
//https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final ucsdBackgroundColor = const Color(0xFF182B49);

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

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UCSD"),
      ),
      body: Container(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}