import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/notices.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/providers/wayfinding.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_card.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_card.dart';
import 'package:campus_mobile_experimental/ui/common/webview_container.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_card.dart';
import 'package:campus_mobile_experimental/ui/events/events_card.dart';
import 'package:campus_mobile_experimental/ui/finals/finals_card.dart';
import 'package:campus_mobile_experimental/ui/my_chart/my_chart_card.dart';
import 'package:campus_mobile_experimental/ui/myucsdchart/myucsdchart.dart';
import 'package:campus_mobile_experimental/ui/news/news_card.dart';
import 'package:campus_mobile_experimental/ui/notices/notices_card.dart';
import 'package:campus_mobile_experimental/ui/parking/parking_card.dart';
import 'package:campus_mobile_experimental/ui/scanner/native_scanner_card.dart';
import 'package:campus_mobile_experimental/ui/scanner/web_scanner_card.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_card.dart';
import 'package:campus_mobile_experimental/ui/student_id/student_id_card.dart';
import 'package:campus_mobile_experimental/ui/survey/survey_card.dart';
import 'package:campus_mobile_experimental/ui/weather/weather_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    checkToResumeBluetooth(context);
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
    Map<String, CardsModel> webCards =
        Provider.of<CardsDataProvider>(context, listen: false).webCards;

    for (String card in order) {
      if (!webCards.containsKey(card)) {
        switch (card) {
          case 'QRScanner':
            orderedCards.insert(0, ScannerCard());
            break;
          case 'NativeScanner':
            orderedCards.insert(0, NativeScannerCard());
            break;
          case 'MyStudentChart':
            orderedCards.add(MyStudentChartCard());
            break;
          case 'student_survey':
            orderedCards.add(SurveyCard());
            break;
          case 'dining':
            orderedCards.add(DiningCard());
            break;
          case 'news':
            orderedCards.add(NewsCard());
            break;
          case 'events':
            orderedCards.add(EventsCard());
            break;
          case 'weather':
            orderedCards.add(WeatherCard());
            break;
          case 'availability':
            orderedCards.add(AvailabilityCard());
            break;
          case 'schedule':
            orderedCards.add(ClassScheduleCard());
            break;
          case 'finals':
            orderedCards.add(FinalsCard());
            break;
          case 'MyUCSDChart':
            orderedCards.add(MyUCSDChartCard());
            break;
          case 'student_id':
            orderedCards.add(StudentIdCard());
            break;
          case 'parking':
            orderedCards.add(ParkingCard());
            break;
          case 'shuttle':
            orderedCards.add(ShuttleCard());
            break;
        }
      } else {
        // dynamically insert webCards into the list
        orderedCards.add(WebViewContainer(
          titleText: webCards[card].titleText,
          initialUrl: webCards[card].initialURL,
          cardId: card,
          requireAuth: webCards[card].requireAuth,
        ));
      }
    }
    return orderedCards;
  }

  void checkToResumeBluetooth(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("advancedWayfindingEnabled") &&
        prefs.getBool("advancedWayfindingEnabled")) {
      AdvancedWayfindingSingleton bluetoothSingleton =
          AdvancedWayfindingSingleton();
      bluetoothSingleton.advancedWayfindingEnabled =
          prefs.getBool("advancedWayfindingEnabled");
      if (bluetoothSingleton.firstInstance) {
        bluetoothSingleton.firstInstance = false;
        if (bluetoothSingleton.userDataProvider == null) {
          bluetoothSingleton.userDataProvider =
              Provider.of<UserDataProvider>(context, listen: false);
        }
        if (bluetoothSingleton.advancedWayfindingEnabled) {
          bluetoothSingleton.init();
        }
      }
    }
  }
}
