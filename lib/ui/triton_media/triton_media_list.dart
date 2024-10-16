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
        : buildMediaList(
        Provider.of<MediaDataProvider>(context).mediaModels!, context);
  }

  Widget buildMediaList(List<MediaModel> listOfMedia, BuildContext context) {
    // Determine the number of items to show
    int size = listSize ?? 3; // If listSize is null, default to 3

    // check to see if we want to display only a limited number of elements
    // if no constraint is given on the size of the list then all elements are rendered
    size = size > listOfMedia.length ? listOfMedia.length : size; // Handle case where size exceeds list length

    if (listSize != null) {
      // check to see if we have at least 3 events
      return SizedBox(
        height: 250, // Set an appropriate height for the horizontal list
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: size,
          itemBuilder: (context, index) {
            final MediaModel item = listOfMedia[index];
            return Row(
              children: [
                MediaTile(data: item),
                SizedBox(width: 5), // Spacer between tiles
              ],
            );
          },
        ),
      );
    } else {
      return ContainerView(
        child: listOfMedia.isEmpty
            ? Center(child: Text('No media found.'))
            : MediaAll(),
      );
    }
  }
}
