import 'package:flutter/material.dart';
import 'package:campus_mobile/ui/widgets/image_loader.dart';
import 'package:campus_mobile/core/models/events_model.dart';
import 'package:campus_mobile/ui/widgets/container_view.dart';

class EventsList extends StatelessWidget {
  const EventsList({Key key, @required this.data, this.listSize})
      : super(key: key);

  final Future<List<EventModel>> data;
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: data,
      builder: (context, snapshot) {
        return buildNewsList(snapshot, context);
      },
    );
  }

  Widget buildNewsList(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.hasData) {
      final List<EventModel> listOfEvents = snapshot.data;
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
        final tile =
            buildNewsTile(item.title, item.description, item.imageThumb);
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
    } else {
      return Container();
    }
  }

  Widget buildNewsTile(String title, String subtitle, String imageURL) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: ImageLoader(url: imageURL),
    );
  }
}
