import 'package:flutter/material.dart';
import 'package:campus_mobile/ui/widgets/image_loader.dart';
import 'package:campus_mobile/core/models/events_model.dart';
import 'package:campus_mobile/ui/widgets/container_view.dart';
import 'package:campus_mobile/core/constants/app_constants.dart';

class EventsList extends StatelessWidget {
  const EventsList({Key key, @required this.data, this.listSize})
      : super(key: key);

  final List<EventModel> data;
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return buildEventsList(data, context);
  }

  Widget buildEventsList(List<EventModel> listOfEvents, BuildContext context) {
    final List<Widget> eventTiles = List<Widget>();

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    var size;
    if (listSize == null)
      size = listOfEvents.length;
    else
      size = listSize;
    for (int i = 0; i < size; i++) {
      final EventModel item = listOfEvents[i];
      final tile = buildEventTile(item, context);
      eventTiles.add(tile);
    }

    return listSize != null
        ? Flexible(
            child: Column(
              children:
                  ListTile.divideTiles(tiles: eventTiles, context: context)
                      .toList(),
            ),
          )
        : ContainerView(
            child: ListView(
              children:
                  ListTile.divideTiles(tiles: eventTiles, context: context)
                      .toList(),
            ),
          );
  }

  Widget buildEventTile(EventModel data, BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.EventDetailView,
            arguments: data);
      },
      title: Text(
        data.title,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        data.description,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: ImageLoader(url: data.imageThumb),
    );
  }
}
