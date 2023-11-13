import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/hooks/dining_query.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import '../../core/hooks/location_query.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';

const cardId = 'dining';

class DiningCard extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Coordinates coordinates = context.read<Coordinates>();
    final coordinates = useFetchLocation();
    final diningHook = useFetchDiningModels();
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        diningHook.refetch();
        coordinates.refetch();
      },
      isLoading: (diningHook.isFetching || diningHook.isLoading) &&
          (coordinates.isFetching || coordinates.isLoading),
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: (diningHook.isError || coordinates.isError) ? "" : null,
      child: () => buildDiningCard(
          makeLocationsList(diningHook.data!, coordinates.data)),
      // need to pass in coordinates here
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
        foregroundColor: Theme.of(context).backgroundColor,
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
