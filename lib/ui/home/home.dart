// ignore_for_file: unused_import
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
import 'package:campus_mobile_experimental/ui/finals/finals_card.dart';
import 'package:campus_mobile_experimental/ui/mystudentchart/mystudentchart_card.dart';
import 'package:campus_mobile_experimental/ui/myucsdchart/myucsdchart_card.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/news/news_card.dart';
import 'package:campus_mobile_experimental/ui/notices/notices_card.dart';
import 'package:campus_mobile_experimental/ui/parking/parking_card.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_card.dart';
import 'package:campus_mobile_experimental/ui/student_id/student_id_card.dart';
import 'package:campus_mobile_experimental/ui/wifi/wifi_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:flutter/rendering.dart';

//--- code to track size changes of dynamic web card widget content ---
typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({Key? key, required this.onChange, required Widget child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

Map<String, double> webViewCardHeights = {};
Map<String, bool> webViewCardNotLoaded = {};

void resetCardHeight(String card) {
  webViewCardHeights[card] = 0.0;
}

void resetAllCardHeights() {
  webViewCardHeights.clear();
}

void resetAllCardLoadedStates() {
  webViewCardNotLoaded.clear();
}

void setNewCardHeight(String card, double height) {
  if (!webViewCardHeights.containsKey(card) || height > webViewCardHeights[card]!) {
    webViewCardNotLoaded[card] = false;
    webViewCardHeights[card] = height;
  }
}
//---------------------------------------------------------------------

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = ScrollController(initialScrollOffset: getHomeScrollOffset());
  InternetConnectivityProvider? _connectivityProvider;

  _HomeState() : super() {
    _controller.addListener(() {
      setHomeScrollOffset(_controller.offset);
    });
  }

  Future<Null> initUniLinks() async {
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
      executeQuery(query);
    }

    // used to handle links while app is in foreground/background
    _sub = linkStream.listen((String? link) async {
      // handling for map query
      if (link!.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query']!;
        // redirect query to maps tab and search with query
        executeQuery(query);
        // received deeplink, cancel stream to prevent memory leaks
        _sub.cancel();
      }
    });
  }

  void executeQuery(String query) {
    context.read<MapsDataProvider>().searchBarController.text = query;
    context.read<MapsDataProvider>().fetchLocations();
    context.read<BottomNavigationBarProvider>().currentIndex = NavigatorConstants.MapTab;
    context.read<CustomAppBar>().changeTitle("Maps");
    executedInitialDeeplinkQuery = true;
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<CustomAppBar>(context).changeTitle(null); // reset title to logo (for dining)
    initUniLinks();
    _connectivityProvider = Provider.of<InternetConnectivityProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: cardMargin, vertical: 0.0),
      child: ListView(
        controller: _controller,
        padding: const EdgeInsets.only(top: 0.0, right: 0.0, bottom: cardMargin + 2.0, left: 0.0),
        children: createList(),
      ),
    );
  }

  List<Widget> createList() {
    final orderedCards = getOrderedCardsList(context.watch<CardsDataProvider>().cardOrder);
    final noticesCards = getNoticesCardsList(context.watch<NoticesDataProvider>().noticesModel);
    return [...noticesCards, ...orderedCards];
  }

  List<Widget> getNoticesCardsList(List<NoticesModel> notices) =>
      notices.map((notice) => NoticesCard(notice: notice)).whereType<NoticesCard>().toList();

  // Constructor tear-offs used below to generate ordered cards list in O(1) time
  static const _cardCtors = {
    'MyStudentChart': MyStudentChartCard.new,
    'dining': DiningCard.new,
    'news': NewsCard.new,
    'events': EventsCard.new,
    'availability': AvailabilityCard.new,
    'schedule': ClassScheduleCard.new,
    'finals': FinalsCard.new,
    'MyUCSDChart': MyUCSDChartCard.new,
    'student_id': StudentIdCard.new,
    'employee_id': EmployeeIdCard.new,
    'parking': ParkingCard.new,
    'speed_test': WiFiCard.new,
    'shuttle': ShuttleCard.new,
  };

  List<Widget> getOrderedCardsList(List<String> order) {
    final orderedCards = <Widget>[];
    final webCards = context.read<CardsDataProvider>().webCards;

    for (String cardName in order) {
      /// TODO: if-branches logic here theoretically could be simplified
      if (!webCards.containsKey(cardName)) {
        final cardCtor = _cardCtors[cardName];
        if (cardCtor != null) orderedCards.add(cardCtor());
      } else {
        // dynamically insert webCards into the list
        orderedCards.add(
          StatefulBuilder(
            builder: (context, setState) {
              var currentCard = cardName;
              if (webViewCardNotLoaded[currentCard] == null) {
                webViewCardNotLoaded[currentCard] = true;
              }
              return Stack(
                children: <Widget>[
                  MeasureSize(
                    onChange: (Size size) {
                      setNewCardHeight(cardName, size.height);
                      webViewCardNotLoaded[cardName] =
                          (size.height != webViewCardHeights[cardName]);
                      setState(() {});
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: WebViewContainer(
                        titleText: webCards[currentCard]!.titleText,
                        initialUrl: webCards[currentCard]!.initialURL,
                        cardId: currentCard,
                        requireAuth: webCards[currentCard]!.requireAuth,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: webViewCardHeights[currentCard] ?? 0.0,
                      minWidth: 400.0,
                    ),
                    child: Builder(
                      builder: (BuildContext context) {
                        final currentCard = cardName;
                        return Visibility(
                          visible: webViewCardNotLoaded[currentCard]!,
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                SizedBox(height: 50),
                                Expanded(
                                  child: Container(
                                    color: Theme.of(context).cardColor,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }
    return orderedCards;
  }
}
