import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/links_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/views/links/links_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'links';

class LinksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      titleText: CardTitleConstants.titleMap[cardId],
      isLoading: Provider.of<LinksDataProvider>(context).isLoading,
      reload: () =>
          Provider.of<LinksDataProvider>(context, listen: false).fetchLinks(),
      errorText: Provider.of<LinksDataProvider>(context).error,
      child: () => buildLinksCard(),
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildLinksCard() {
    return LinksList(
      listSize: 4,
    );
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.LinksViewAll);
      },
    ));
    return actionButtons;
  }
}
