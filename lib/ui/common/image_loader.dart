import 'package:flutter/material.dart';

class ImageLoader extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final bool fullSize;
  final BoxFit fit;

  ImageLoader({
    required this.url,
    this.width = 100.0,
    this.height = 100.0,
    this.fullSize = false,
    this.fit = BoxFit.scaleDown,
  });

  @override
  Widget build(BuildContext context) {
    return url.isEmpty
        ? Container(width: 0, height: 0)
        : Image.network(
            url,
            width: fullSize ? null : width,
            height: fullSize ? null : height,
            fit: fit,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(width: 0, height: 0);
            },
          );
  }
}
