import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const cardId = 'dining';

class DiningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => Provider.of<DiningDataProvider>(context, listen: false)
          .fetchDiningLocations(),
      isLoading: Provider.of<DiningDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<DiningDataProvider>(context).error,
      child: () => buildDiningCard(
          Provider.of<DiningDataProvider>(context).diningModels),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildDiningCard(List<DiningModel> data) {
    return DiningList(
      listSize: 3,
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
    );
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.DiningViewAll);
      },
    ));
    return actionButtons;
  }
}
