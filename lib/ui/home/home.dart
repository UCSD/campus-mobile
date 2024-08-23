import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/models/notices.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/connectivity.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/notices.dart';
import 'package:campus_mobile_experimental/main.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_card.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_card.dart';
import 'package:campus_mobile_experimental/ui/common/webview_container.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_card.dart';
import 'package:campus_mobile_experimental/ui/employee_id/employee_id_card.dart';
import 'package:campus_mobile_experimental/ui/events/events_card.dart';
import 'package:campus_mobile_experimental/ui/triton_media/triton_media_card.dart';
import 'package:campus_mobile_experimental/ui/finals/finals_card.dart';
import 'package:campus_mobile_experimental/ui/my_chart/my_chart_card.dart';
import 'package:campus_mobile_experimental/ui/myucsdchart/myucsdchart.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/news/news_card.dart';
import 'package:campus_mobile_experimental/ui/notices/notices_card.dart';
import 'package:campus_mobile_experimental/ui/parking/parking_card.dart';
import 'package:campus_mobile_experimental/ui/scanner/native_scanner_card.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_card.dart';
import 'package:campus_mobile_experimental/ui/student_id/student_id_card.dart';
import 'package:campus_mobile_experimental/ui/weather/weather_card.dart';
import 'package:campus_mobile_experimental/ui/wifi/wifi_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  InternetConnectivityProvider? _connectivityProvider;
  Future<Null> initUniLinks(BuildContext context) async {
    // deep links are received by this method
    // the specific host needs to be added in AndroidManifest.xml and Info.plist
    // currently, this method handles executing custom map query
    late StreamSubscription _sub;

    // Used to handle links on cold app start
    String? initialLink = await getInitialLink();
    if (!executedInitialDeeplinkQuery &&
        initialLink != null &&
        initialLink.contains("deeplinking.searchmap")) {
      var uri = Uri.dataFromString(initialLink);
      var query = uri.queryParameters['query']!;
      // redirect query to maps tab and search with query
      executeQuery(context, query);
    }

    // used to handle links while app is in foreground/background
    _sub = linkStream.listen((String? link) async {
      // handling for map query
      if (link!.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query']!;
        // redirect query to maps tab and search with query
        executeQuery(context, query);
        // received deeplink, cancel stream to prevent memory leaks
        _sub.cancel();
      }
    });
  }

  void executeQuery(BuildContext context, String query) {
    Provider.of<MapsDataProvider>(context, listen: false)
        .searchBarController
        .text = query;
    Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
    Provider.of<BottomNavigationBarProvider>(context, listen: false)
        .currentIndex = NavigatorConstants.MapTab;
    Provider.of<CustomAppBar>(context, listen: false).changeTitle("Maps");
    executedInitialDeeplinkQuery = true;
  }

  @override
  Widget build(BuildContext context) {
    initUniLinks(context);
    _connectivityProvider = Provider.of<InternetConnectivityProvider>(context);
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
        getOrderedCardsList(Provider.of<CardsDataProvider>(context).cardOrder!);
    List<Widget> noticesCards = getNoticesCardsList(
        Provider.of<NoticesDataProvider>(context).noticesModel!);

    return noticesCards + orderedCards;
  }

  List<Widget> getNoticesCardsList(List<NoticesModel> notices) {
    List<Widget> noticesCards = [];
    for (NoticesModel notice in notices) {
      noticesCards.add(NoticesCard(notice: notice));
    }
    return noticesCards;
  }

  // Constructor tear-offs used below to generate ordered cards list in O(1) time
  static const _cardCtors = {
    'NativeScanner': NativeScannerCard.new,
    'MyStudentChart': MyStudentChartCard.new,
    'dining': DiningCard.new,
    'news': NewsCard.new,
    'events': EventsCard.new,
    'triton_media': MediaCard.new,
    'weather': WeatherCard.new,
    'availability': AvailabilityCard.new,
    'schedule': ClassScheduleCard.new,
    'finals': FinalsCard.new,
    'MyUCSDChart': MyUCSDChartCard.new,
    'student_id': StudentIdCard.new,
    'employee_id': EmployeeIdCard.new,
    'parking': ParkingCard.new,
    'speed_test': WiFiCard.new,
    'shuttle': ShuttleCard.new
  };

  List<Widget> getOrderedCardsList(List<String> order) {
    List<Widget> orderedCards = [];
    Map<String, CardsModel?>? webCards =
        Provider.of<CardsDataProvider>(context, listen: false).webCards;

    for (String cardName in order) {
      if (!webCards!.containsKey(cardName)) {
        final cardCtor = _cardCtors[cardName];
        if (cardCtor == null) continue;
        orderedCards.add(cardCtor());
      } else {
        // dynamically insert webCards into the list
        orderedCards.add(WebViewContainer(
          titleText: webCards[cardName]!.titleText,
          initialUrl: webCards[cardName]!.initialURL,
          cardId: cardName,
          requireAuth: webCards[cardName]!.requireAuth,
        ));
      }
    }
    return orderedCards;
  }
}
