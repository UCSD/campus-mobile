import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/events/events_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'events';

//edit these files
class EventsCard extends StatelessWidget {
  Widget buildEventsCard(List<EventModel>? data) {
    return EventsList(listSize: 3);
  }

  List<Widget> buildActionButtons(
      BuildContext context, List<EventModel>? data) {
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
        Navigator.pushNamed(context, RoutePaths.EventsViewAll, arguments: data);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () =>
          Provider.of<EventsDataProvider>(context, listen: false).fetchEvents(),
      isLoading: Provider.of<EventsDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<EventsDataProvider>(context).error,
      child: () => buildEventsCard(
          Provider.of<EventsDataProvider>(context).eventsModels),
      actionButtons: buildActionButtons(
          context, Provider.of<EventsDataProvider>(context).eventsModels),
    );
  }
}
