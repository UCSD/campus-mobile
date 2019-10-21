import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageLoader extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final bool fullSize;
  ImageLoader(
      {@required this.url,
      this.width = 100.0,
      this.height = 100.0,
      this.fullSize = false});
  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container();
    }
    Widget image;
    try {
      image = CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } catch (e) {
      image = Icon(Icons.error);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [image],
    );
  }
}
