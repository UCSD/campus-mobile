import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/events/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventsAll extends StatelessWidget {
  const EventsAll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildEventsList(
            Provider.of<EventsDataProvider>(context).eventsModels, context);
  }

  Widget buildEventsList(List<EventModel> listOfEvents, BuildContext context) {
    final List<Widget> eventTiles = [];

    for (int i = 0; i < listOfEvents.length; i++) {
      final EventModel item = listOfEvents[i];
      final tile = EventTile(data: item);
      eventTiles.add(tile);
    }

    if (listOfEvents.length > 0) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 1,
        mainAxisSpacing: 8,
        children: eventTiles,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.4),
      );
    } else {
      return ContainerView(
        child: Center(
          child: Text('No events found.'),
        ),
      );
    }
  }
}
