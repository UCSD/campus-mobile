import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/shuttle_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
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
      reload: () => _shuttleCardDataProvider.fetchStops(),
      isLoading: _shuttleCardDataProvider.isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: _shuttleCardDataProvider.error,
      child: () =>
          buildShuttleCard());
  }


  Widget buildShuttleCard() {
//    print(_shuttleCardDataProvider.stopsToRender);
    print("Seconds to arrival: " + _shuttleCardDataProvider.listToRender[0].secondsToArrival.toString());
    return(
      Column(
        children: <Widget>[
          Text("Hello"),
        ]
      )
    );
  }
}