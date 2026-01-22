import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/events/events_card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const cardId = 'events';

// edit these files
class EventsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: context.select((CardsDataProvider p) => p.cardStates[cardId] ?? false),
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () => Provider.of<EventsDataProvider>(context, listen: false).fetchEvents(),
      isLoading: Provider.of<EventsDataProvider>(context).isLoading,
      titleText: CardTitleConstants.TITLE_MAP[cardId]!,
      errorText: Provider.of<EventsDataProvider>(context).error,
      child: () => buildEventsCardList(Provider.of<EventsDataProvider>(context).eventsModels),
      actionButtons: [
        ActionButton(
            buttonText: "VIEW ALL EVENTS", onPressed: () => Navigator.pushNamed(context, RoutePaths.EVENTS_VIEW_ALL))
      ],
    );
  }

  Widget buildEventsCardList(List<EventModel>? data) => EventsCardList(listSize: 6);
}
