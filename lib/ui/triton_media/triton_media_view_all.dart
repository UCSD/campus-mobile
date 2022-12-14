import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/providers/triton_media.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/triton_media/triton_media_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaAll extends StatelessWidget {
  const MediaAll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.of<MediaDataProvider>(context).isLoading!
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildMediaList(
            Provider.of<MediaDataProvider>(context).eventsModels!, context);
  }

  Widget buildMediaList(List<MediaModel> listOfEvents, BuildContext context) {
    final List<Widget> mediaTiles = [];

    for (int i = 0; i < listOfEvents.length; i++) {
      final MediaModel item = listOfEvents[i];
      final tile = MediaTile(data: item);
      mediaTiles.add(tile);
    }

    if (listOfEvents.length > 0) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 1,
        mainAxisSpacing: 8,
        children: mediaTiles,
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
