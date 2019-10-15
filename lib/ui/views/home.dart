<<<<<<< HEAD
import 'package:campus_mobile_beta/core/viewmodels/baseline.dart';
import 'package:campus_mobile_beta/core/viewmodels/events_view_model.dart';
import 'package:campus_mobile_beta/core/viewmodels/news_view_model.dart';
import 'package:campus_mobile_beta/core/viewmodels/weather.dart';
import 'package:campus_mobile_beta/core/viewmodels/availability_view_model.dart';
=======
import 'package:campus_mobile/core/viewmodels/availability_view_model.dart';
import 'package:campus_mobile/core/viewmodels/baseline.dart';
import 'package:campus_mobile/core/viewmodels/events_view_model.dart';
import 'package:campus_mobile/core/viewmodels/links_view_model.dart';
import 'package:campus_mobile/core/viewmodels/news_view_model.dart';
import 'package:campus_mobile/core/viewmodels/weather.dart';
>>>>>>> 41519e4... implement links card
import 'package:flutter/material.dart';

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
        NewsCard(),
        EventsViewModel(),
        AvailabilityCard(),
        LinksCard(),
        BaselineCard(),
      ],
    );
  }
}
