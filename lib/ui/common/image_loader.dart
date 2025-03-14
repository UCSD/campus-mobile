import 'package:flutter/material.dart';

class ImageLoader extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final bool fullSize;

  ImageLoader({
    required this.url,
    this.width = 100.0,
    this.height = 100.0,
    this.fullSize = false
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty)
      return Container(
        width: 0,
        height: 0,
      );
    
    return Image.network(
      url,
      width: fullSize ? null : width,
      height: fullSize ? null : height,
      loadingBuilder: (context, child, loadingProgress) {
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
      errorBuilder: (context, object, stacktrace) {
        print("Unable to fetch DiningImage. Error: ${object.toString()}");
        return Container(
          width: 0,
          height: 0,
        );
      },
    );
  }
}
