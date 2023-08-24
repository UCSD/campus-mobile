import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/events/events_view_all.dart';
import 'package:campus_mobile_experimental/ui/events/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/hooks/events_query.dart';

class EventsList extends HookWidget {
  const EventsList({Key? key, this.listSize}) : super(key: key);

  final int? listSize;

  @override
  Widget build(BuildContext context) {
    final events = useFetchEventsModels();
    return events.isFetching
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildEventsList(events.data!, context);
  }

  Widget buildEventsList(List<EventModel> listOfEvents, BuildContext context) {
    final List<Widget> eventTiles = [];

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    var size;
    if (listSize == null) {
      size = 3;
    } else
      size = listSize;

    /// check to see if we have at least 3 events
    if (size > listOfEvents.length) {
      size = listOfEvents.length;
    }

    for (int i = 0; i < size; i++) {
      final EventModel item = listOfEvents[i];
      final tile = EventTile(data: item);
      final spacer = SizedBox(
        width: 5,
      );
      eventTiles.add(tile);
      eventTiles.add(spacer);
    }

    if (listSize != null) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: eventTiles,
        ),
      );
    } else {
      return ContainerView(
        child: listOfEvents.isEmpty
            ? Center(child: Text('No events found.'))
            : EventsAll(),
      );
    }
    // ListView(
    //   children:
    //   ListTile.divideTiles(tiles: eventTiles, context: context)
    //       .toList(),
  }
}
