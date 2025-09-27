import 'package:campus_mobile/app_constants.dart';
import 'package:campus_mobile/core/models/dining.dart';
import 'package:campus_mobile/core/providers/cards.dart';
import 'package:campus_mobile/core/providers/dining.dart';
import 'package:campus_mobile/ui/common/action_button.dart';
import 'package:campus_mobile/ui/common/card_container.dart';
import 'package:campus_mobile/ui/dining/dining_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const cardId = 'dining';

class DiningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => Provider.of<DiningDataProvider>(context, listen: false)
          .fetchDiningLocations(),
      isLoading: Provider.of<DiningDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId]!,
      errorText: Provider.of<DiningDataProvider>(context).error,
      child: () => buildDiningCard(
          Provider.of<DiningDataProvider>(context).diningModels),
      actionButtons: [
        ActionButton(
           buttonText: 'VIEW ALL DINING OPTIONS',
           onPressed: () {
              // Only navigate if not loading and no error
              final provider = Provider.of<DiningDataProvider>(context, listen: false);
              if (!provider.isLoading && provider.error == null) {
                Navigator.pushNamed(context, RoutePaths.DiningViewAllDiningOptions);
              }
            })
      ],
    );
  }

 Widget buildDiningCard(List<DiningModel> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DiningList(listSize: data.length >= 3 ? 3 : data.length),
    );
  }
}
