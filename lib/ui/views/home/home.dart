import 'package:campus_mobile_experimental/core/data_providers/notices_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/notices_model.dart';
import 'package:campus_mobile_experimental/ui/cards/class_schedule/class_schedule_card.dart';
import 'package:campus_mobile_experimental/ui/cards/events/events_card.dart';
import 'package:campus_mobile_experimental/ui/cards/finals/finals_card.dart';
import 'package:campus_mobile_experimental/ui/cards/my_chart/my_chart_card.dart';
import 'package:campus_mobile_experimental/ui/cards/news/news_card.dart';
import 'package:campus_mobile_experimental/ui/cards/notices/notices_card.dart';
import 'package:campus_mobile_experimental/ui/cards/scanner/scanner_card.dart';
import 'package:campus_mobile_experimental/ui/cards/weather/weather_card.dart';
import 'package:campus_mobile_experimental/ui/cards/availability/availability_card.dart';
import 'package:campus_mobile_experimental/ui/cards/links/links_card.dart';
import 'package:campus_mobile_experimental/ui/cards/dining/dining_card.dart';
import 'package:campus_mobile_experimental/ui/cards/parking/parking_card.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/banner_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: createList(context),
    );
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> orderedCards = getOrderedCardsList(Provider.of<UserDataProvider>(context).cardOrder);
    List<Widget> noticesCards = getNoticesCardsList(Provider.of<NoticesDataProvider>(context).noticesModel);

    return noticesCards + orderedCards;
  }

  List<Widget> getNoticesCardsList(List<NoticesModel> notices) {
    List<Widget> noticesCards = List<Widget>();
    for (NoticesModel notice in notices) {
      noticesCards.add(NoticesCard(notice: notice));
    }
    return noticesCards;
  }

  List<Widget> getOrderedCardsList(List<String> order) {
    List<Widget> orderedCards = List<Widget>();

    orderedCards.add(ScannerCard()); // not hideable and not reorderable

    for (String card in order) {
      switch (card) {
        case 'special_events':
          orderedCards.add(BannerCard());
          break;
//        case 'weather':
//          orderedCards.add(WeatherCard());
//          break;
//        case 'availability':
//          orderedCards.add(AvailabilityCard());
//          break;
//        case 'parking':
//          orderedCards.add(ParkingCard());
//          break;
//        case 'dining':
//          orderedCards.add(DiningCard());
//          break;
//        case 'news':
//          orderedCards.add(NewsCard());
//          break;
//        case 'events':
//          orderedCards.add(EventsCard());
//          break;
//        case 'links':
//          orderedCards.add(LinksCard());
//          break;
        case 'schedule':
          orderedCards.add(ClassScheduleCard());
          break;
        case 'finals':
          orderedCards.add(FinalsCard());
          break;
        case 'my_chart':
          orderedCards.add(MyChartCard());
          break;
      }
    }
    return orderedCards;
  }
}
