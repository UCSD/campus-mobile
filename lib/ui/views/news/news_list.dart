import 'package:flutter/material.dart';
import 'package:campus_mobile/ui/widgets/image_loader.dart';
import 'package:campus_mobile/core/models/news_model.dart';
import 'package:campus_mobile/ui/widgets/container_view.dart';

class NewsList extends StatelessWidget {
  const NewsList({Key key, @required this.data, this.listSize})
      : super(key: key);

  final Future<NewsModel> data;
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsModel>(
      future: data,
      builder: (context, snapshot) {
        return buildNewsList(snapshot, context);
      },
    );
  }

  Widget buildNewsList(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.hasData) {
      final List<Item> listOfNews = snapshot.data.items;
      final List<Widget> newsTiles = List<Widget>();

      /// check to see if we want to display only a limited number of elements
      /// if no constraint is given on the size of the list then all elements
      /// are rendered
      var size;
      if (listSize == null)
        size = newsTiles.length;
      else
        size = listSize;

      for (int i = 0; i < size; i++) {
        final Item item = listOfNews[i];
        final tile = buildNewsTile(item.title, item.description, item.image);
        newsTiles.add(tile);
      }
      return listSize != null
          ? Flexible(
              child: Column(
                children:
                    ListTile.divideTiles(tiles: newsTiles, context: context)
                        .toList(),
              ),
            )
          : ContainerView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: newsTiles,
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
