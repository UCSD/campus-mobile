import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/widgets/image_loader.dart';
import 'package:campus_mobile_experimental/core/models/news_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';

class NewsList extends StatelessWidget {
  const NewsList({Key key, @required this.data, this.listSize})
      : super(key: key);

  final NewsModel data;
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return buildNewsList(context);
  }

  Widget buildNewsList(BuildContext context) {
    final List<Item> listOfNews = data.items;
    final List<Widget> newsTiles = List<Widget>();

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    var size;
    if (listSize == null)
      size = listOfNews.length;
    else
      size = listSize;
    for (int i = 0; i < size; i++) {
      final Item item = listOfNews[i];
      final tile = buildNewsTile(item, context);
      newsTiles.add(tile);
    }

    return listSize != null
        ? Column(
            children: ListTile.divideTiles(tiles: newsTiles, context: context)
                .toList(),
          )
        : ContainerView(
            child: ListView(
              children: ListTile.divideTiles(tiles: newsTiles, context: context)
                  .toList(),
            ),
          );
  }

  Widget buildNewsTile(Item newsItem, BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.NewsDetailView,
            arguments: newsItem);
      },
      title: Text(
        newsItem.title,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        newsItem.description,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ImageLoader(url: newsItem.image),
        ],
      ),
    );
  }
}
