import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/notices.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_card.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_card.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_card.dart';
import 'package:campus_mobile_experimental/ui/events/events_card.dart';
import 'package:campus_mobile_experimental/ui/finals/finals_card.dart';
import 'package:campus_mobile_experimental/ui/my_chart/my_chart_card.dart';
import 'package:campus_mobile_experimental/ui/news/news_card.dart';
import 'package:campus_mobile_experimental/ui/notices/notices_card.dart';
import 'package:campus_mobile_experimental/ui/scanner/scanner_card.dart';
import 'package:campus_mobile_experimental/ui/student_id/student_id_card.dart';
import 'package:campus_mobile_experimental/ui/weather/weather_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardMargin, vertical: 0.0),
      child: ListView(
        padding: EdgeInsets.only(
            top: cardMargin + 2.0, right: 0.0, bottom: 0.0, left: 0.0),
        children: createList(context),
      ),
    );
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> orderedCards =
        getOrderedCardsList(Provider.of<CardsDataProvider>(context).cardOrder);
    List<Widget> noticesCards = getNoticesCardsList(
        Provider.of<NoticesDataProvider>(context).noticesModel);

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

    for (String card in order) {
      switch (card) {
        case 'QRScanner':
          orderedCards.add(ScannerCard());
          break;
        case 'MyStudentChart':
          orderedCards.add(MyChartCard());
          break;
        case 'finals':
          orderedCards.add(FinalsCard());
          break;
        case 'schedule':
          orderedCards.add(ClassScheduleCard());
          break;
        case 'dining':
          orderedCards.add(DiningCard());
          break;
        case 'events':
          orderedCards.add(EventsCard());
          break;
        case 'news':
          orderedCards.add(NewsCard());
          break;
        case 'student_id':
          orderedCards.add(StudentIdCard());
          break;
        case 'weather':
          orderedCards.add(WeatherCard());
          break;
        case 'availability':
          orderedCards.add(AvailabilityCard());
          break;
      }
    }
    return orderedCards;
  }
}
