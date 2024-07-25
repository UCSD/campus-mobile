import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/providers/triton_media.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaTile extends StatelessWidget {
  const MediaTile({Key? key, required this.data}) : super(key: key);
  final MediaModel data;
  final double tileWidth = 190;

  @override
  Widget build(BuildContext context) {
    return Provider.of<MediaDataProvider>(context).isLoading? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildMediaTile(context);
  }

  Widget buildMediaTile(BuildContext context) {
    return Container(
      width: tileWidth,
      height: 230,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, RoutePaths.MediaDetailView,
              arguments: data);
        },
        child: Column(
          children: [
            mediaImageLoader(data.imageThumb),
            SizedBox(
              height: 80,
              width: tileWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ], // children
        ),
      ),
    );
  }

  Widget mediaImageLoader(String? url) {
    return url!.isEmpty
        ? Container(
            child: Image(
            image: AssetImage('assets/images/UCSDMobile_sharp.png'),
            height: 150,
            width: tileWidth,
            fit: BoxFit.fill,
          ))
        : Image.network(
            url,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            fit: BoxFit.fill,
            height: 150,
            width: tileWidth,
          );
  }
}
