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
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => Provider.of<ShuttleDataProvider>(context, listen: false)
        .fetchStops(),
      isLoading: Provider.of<ShuttleDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<ShuttleDataProvider>(context).error,
      child: () => buildShuttleCard(
        Provider.of<ShuttleDataProvider>(context).stopsToRender,
      ));
  }


  Widget buildShuttleCard(List<dynamic> stopsToRender) {
//    print(_shuttleCardDataProvider.stopsToRender);
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: stopsToRender.length,
        itemBuilder: (BuildContext context, int index) {
          return Text("${stopsToRender[index].id} - ${stopsToRender[index].name}");
        }
    );
  }
}