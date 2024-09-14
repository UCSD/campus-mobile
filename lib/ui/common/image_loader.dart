import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageLoader extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final bool fullSize;
  ImageLoader(
      {required this.url,
      this.width = 100.0,
      this.height = 100.0,
      this.fullSize = false});
  @override
  Widget build(BuildContext context) {
    return url!.isEmpty
        ? Container(
            width: 0,
            height: 0,
          )
        : CachedNetworkImage(
            imageUrl: url!,
            width: fullSize ? null : width,
            height: fullSize ? null : height,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
  }
}
