import 'package:campus_mobile_experimental/core/viewmodels/baseline.dart';
import 'package:campus_mobile_experimental/core/viewmodels/dining_view_model.dart';
import 'package:campus_mobile_experimental/core/viewmodels/events_view_model.dart';
import 'package:campus_mobile_experimental/core/viewmodels/news_view_model.dart';
import 'package:campus_mobile_experimental/core/viewmodels/weather.dart';
import 'package:campus_mobile_experimental/core/viewmodels/availability_view_model.dart';
import 'package:campus_mobile_experimental/core/viewmodels/links_view_model.dart';
import 'package:campus_mobile_experimental/core/viewmodels/parking_view_model.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/banner_view_model.dart';
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
        BannerCard(),
        Weather(),
        NewsCard(),
        EventsViewModel(),
        AvailabilityCard(),
        ParkingCard(),
        LinksCard(),
        DiningCard(),
        /// BaselineCard(),
      ],
    );
  }
}
