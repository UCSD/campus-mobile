

import 'package:flutter/material.dart';

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
        : Image.network(
            url!,
            width: fullSize ? null : width,
            height: fullSize ? null : height,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          );
  }
}
