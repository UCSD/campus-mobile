import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/providers/triton_media.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/triton_media/triton_media_view_all.dart';
import 'package:campus_mobile_experimental/ui/triton_media/triton_media_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaList extends StatelessWidget {
  const MediaList({Key? key, this.listSize}) : super(key: key);

  final int? listSize;

  @override
  Widget build(BuildContext context) {
    return Provider.of<MediaDataProvider>(context).isLoading!
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildEventsList(
            Provider.of<MediaDataProvider>(context).eventsModels!, context);
  }

  Widget buildEventsList(List<MediaModel> listOfEvents, BuildContext context) {
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
      final MediaModel item = listOfEvents[i];
      final tile = MediaTile(data: item);
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
            : MediaAll(),
      );
    }
    // ListView(
    //   children:
    //   ListTile.divideTiles(tiles: eventTiles, context: context)
    //       .toList(),
  }
}
