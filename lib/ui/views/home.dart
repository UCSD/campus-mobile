import 'package:campus_mobile/ui/widgets/cards/news.dart';
import 'package:flutter/material.dart';

import 'package:campus_mobile/core/viewmodels/weather.dart';
import 'package:campus_mobile/ui/views/map.dart';
import 'package:campus_mobile/ui/views/notifications.dart';
import 'package:campus_mobile/ui/views/profile.dart';
import 'package:campus_mobile/core/viewmodels/baseline.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Weather(),
        //News(),
        BaselineCard(),
      ],
    );
  }
}
