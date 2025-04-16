import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/events/events_view_all.dart';
import 'package:campus_mobile_experimental/ui/events/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventsCardList extends StatelessWidget {
  const EventsCardList({Key? key, this.listSize}) : super(key: key);
  final listSize;

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildEventsList(Provider.of<EventsDataProvider>(context).eventsModels, context);
  }

  Widget buildEventsList(List<EventModel> listOfEvents, BuildContext context) {
    final List<Widget> eventTiles = [const SizedBox(width: 7.5)]; // start off with left spacer

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    var size = listSize ?? 6;

    /// check to see if we have at least 3 events
    if (size > listOfEvents.length) size = listOfEvents.length;

    for (var i = 0; i < size; i++) {
      eventTiles.add(EventTile(data: listOfEvents[i])); // get event model and then create a tile from it
      eventTiles.add(const SizedBox(width: 9)); // spacer between tiles
    }

    if (listSize != null) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: eventTiles,
        ),
      );
    } else {
      return ContainerView(
        child: listOfEvents.isEmpty
            ? const Center(child: const Text('No events found.'))
            : const EventsAll(),
      );
    }
  }
}
