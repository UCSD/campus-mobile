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
      child: () => buildShuttleCard(_shuttleCardDataProvider.stopsToRender,
        _shuttleCardDataProvider.arrivalsToRender
      ));
  }


  Widget buildShuttleCard(List<ShuttleStopModel> stopsToRender,
      List<List<ArrivingShuttle>> arrivalsToRender) {

    print(stopsToRender.length);
    print(arrivalsToRender.length);

    List<Widget> renderList = List<Widget>();
    for (int i = 0; i < arrivalsToRender.length; i++) {
        renderList.add(ShuttleDisplay(stop: stopsToRender[i],
          arrivingShuttles: arrivalsToRender[i]));
    }

    // Initialize first shuttle display with arrival information
    if (renderList == null || renderList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 42.0),
        child: Text('No finals found.'),
      );
    }


    //_shuttleCardDataProvider.fetchArrivalInformation(stopsToRender[0]);

    return Column(
      children: <Widget>[
        Flexible(
          child: PageView(
            controller: _controller,
            children: renderList,
            onPageChanged: (index) async {
              //await _shuttleCardDataProvider.fetchArrivalInformation(stopsToRender[index]);
              print(index);
            },
          ),
        ),
        DotsIndicator(
          controller: _controller,
          itemCount: renderList.length,
          onPageSelected: (int index) {
            _controller.animateToPage(index,
                duration: Duration(seconds: 1), curve: Curves.ease);
          },
        ),
      ],
    );
  }
}