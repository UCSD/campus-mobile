<<<<<<< HEAD
import 'package:campus_mobile_beta/core/viewmodels/baseline.dart';
import 'package:campus_mobile_beta/core/viewmodels/events_view_model.dart';
import 'package:campus_mobile_beta/core/viewmodels/news_view_model.dart';
import 'package:campus_mobile_beta/core/viewmodels/weather.dart';
import 'package:campus_mobile_beta/core/viewmodels/availability_view_model.dart';
import 'package:campus_mobile_beta/core/viewmodels/links_view_model.dart';
=======
import 'package:campus_mobile/core/viewmodels/baseline.dart';
import 'package:campus_mobile/core/viewmodels/events_view_model.dart';
import 'package:campus_mobile/core/viewmodels/news_view_model.dart';
import 'package:campus_mobile/core/viewmodels/parking_view_model.dart';
import 'package:campus_mobile/core/viewmodels/weather.dart';
import 'package:campus_mobile/core/viewmodels/availability_view_model.dart';
>>>>>>> 6f67848... create parking card and add to home view
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
<<<<<<< HEAD
        LinksCard(),
=======
        ParkingCard(),
>>>>>>> 6f67848... create parking card and add to home view
        BaselineCard(),
      ],
    );
  }
}
