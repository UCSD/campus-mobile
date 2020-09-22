import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/notices_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/advanced_wayfinding_singleton.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/notices_model.dart';
import 'package:campus_mobile_experimental/ui/cards/availability/availability_card.dart';
import 'package:campus_mobile_experimental/ui/cards/campus_info/campus_info_card.dart';
import 'package:campus_mobile_experimental/ui/cards/class_schedule/class_schedule_card.dart';
import 'package:campus_mobile_experimental/ui/cards/dining/dining_card.dart';
import 'package:campus_mobile_experimental/ui/cards/events/events_card.dart';
import 'package:campus_mobile_experimental/ui/cards/finals/finals_card.dart';
import 'package:campus_mobile_experimental/ui/cards/mystudentchart/mystudentchart.dart';
import 'package:campus_mobile_experimental/ui/cards/myucsdchart/myucsdchart.dart';
import 'package:campus_mobile_experimental/ui/cards/native_scanner/native_scanner_card.dart';
import 'package:campus_mobile_experimental/ui/cards/news/news_card.dart';
import 'package:campus_mobile_experimental/ui/cards/notices/notices_card.dart';
import 'package:campus_mobile_experimental/ui/cards/scanner/scanner_card.dart';
import 'package:campus_mobile_experimental/ui/cards/staff_id/staff_id_card.dart';
import 'package:campus_mobile_experimental/ui/cards/staff_info/staff_info_card.dart';
import 'package:campus_mobile_experimental/ui/cards/student_id/student_id_card.dart';
import 'package:campus_mobile_experimental/ui/cards/student_info/student_info_card.dart';
import 'package:campus_mobile_experimental/ui/cards/weather/weather_card.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
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

    for (String card in order) {
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
        case 'MyUCSDChart':
          orderedCards.add(MyUCSDChartCard());
          break;
        case 'staff_info':
          orderedCards.add(StaffInfoCard());
          break;
        case 'campus_info':
          orderedCards.add(CampusInfoCard());
          break;
        case 'student_info':
          orderedCards.add(StudentInfoCard());
          break;
        case 'student_id':
          orderedCards.add(StudentIdCard());
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
        case 'staff_id':
          orderedCards.add(StaffIdCard());
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

  void checkToResumeBluetooth(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("advancedWayfindingEnabled") &&
        prefs.getBool('advancedWayfindingEnabled')) {
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
        bluetoothSingleton.init();
      }
    }
  }
}
