import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/shuttle_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop_model.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/cards/shuttle/shuttle_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';


const String cardId = 'shuttle';

class ShuttleCard extends StatefulWidget {
  @override
  _ShuttleCardState createState() => _ShuttleCardState();
}

class _ShuttleCardState extends State<ShuttleCard> {
  ShuttleDataProvider _shuttleCardDataProvider = ShuttleDataProvider();
  PageController _controller = PageController();
  int currentStopID = -1;
  List<ArrivingShuttle> arrivals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shuttleCardDataProvider = Provider.of<ShuttleDataProvider>(context);
  }

  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => Provider.of<ShuttleDataProvider>(context, listen: false)
        .fetchStops(),
      isLoading: _shuttleCardDataProvider.isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: _shuttleCardDataProvider.error,
      child: () => buildShuttleCard(
        _shuttleCardDataProvider.stopsToRender,
      ));
  }


  Widget buildShuttleCard(List<ShuttleStopModel> stopsToRender) {
//    print(_shuttleCardDataProvider.stopsToRender);


    List<Widget> renderList = List<Widget>();
    for (ShuttleStopModel stop in stopsToRender) {
      if (stop != null) {
        ShuttleDisplay stopPage;

        if (stop.id == currentStopID) {
          stopPage = ShuttleDisplay(stop: stop,
              arrivingShuttles: arrivals);
        } else {
          stopPage = ShuttleDisplay(stop: stop);
        }
        renderList.add(stopPage);
      }
    }

    return Column(
      children: <Widget>[
        Flexible(
          child: PageView(
            controller: _controller,
            children: renderList,
            onPageChanged: (index) async {
              await _shuttleCardDataProvider.getStopInformation(stopsToRender[index]);
              arrivals = _shuttleCardDataProvider.arrivalsToRender;
              setState(() {
                currentStopID = stopsToRender[index].id;
              });
            },
          ),
        ),
        /*DotsIndicator(
          controller: _controller,
          itemCount: renderList.length,
          onPageSelected: (int index) {
            _controller.animateToPage(index,
                duration: Duration(seconds: 1), curve: Curves.ease);
          },*//*
        ),*/
      ],
    );
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: stopsToRender.length,
        itemBuilder: (BuildContext context, int index) {
          return Text("${stopsToRender[index].id} - ${stopsToRender[index].name}");
        }
    );
  }
}