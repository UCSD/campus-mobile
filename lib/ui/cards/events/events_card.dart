import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/events_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/events_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/views/events/events_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventsCard extends StatelessWidget {
  Widget buildEventsCard(List<EventModel> data) {
    return EventsList(listSize: 3);
  }

  List<Widget> buildActionButtons(BuildContext context, List<EventModel> data) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
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
      active: Provider.of<CardsDataProvider>(context).cardStates['events'],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard('events'),
      reload: () =>
          Provider.of<EventsDataProvider>(context, listen: false).fetchEvents(),
      isLoading: Provider.of<EventsDataProvider>(context).isLoading,
      titleText: "Events",
      errorText: "No events found.",
      child: () => buildEventsCard(
          Provider.of<EventsDataProvider>(context).eventsModels),
      actionButtons: buildActionButtons(
          context, Provider.of<EventsDataProvider>(context).eventsModels),
    );
  }
}
