import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const cardId = 'dining';

class DiningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      cardId: cardId,
      active: context.select((CardsDataProvider p) => p.cardStates[cardId] ?? false),
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () => Provider.of<DiningDataProvider>(context, listen: false).fetchDiningLocations(),
      isLoading: Provider.of<DiningDataProvider>(context).isLoading,
      titleText: CardTitleConstants.TITLE_MAP[cardId]!,
      errorText: Provider.of<DiningDataProvider>(context).error,
      child: () => buildDiningCard(Provider.of<DiningDataProvider>(context).diningModels),
      actionButtons: [
        ActionButton(
            buttonText: 'VIEW ALL DINING OPTIONS',
            onPressed: () {
              analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'view_all'});
              // Only navigate if not loading and no error
              final provider = Provider.of<DiningDataProvider>(context, listen: false);
              final bool isNotLoading = !provider.isLoading;
              final bool hasNoError = provider.error == null;
              if (isNotLoading && hasNoError) Navigator.pushNamed(context, RoutePaths.DINING_VIEW_ALL_DINING_OPTIONS);
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
