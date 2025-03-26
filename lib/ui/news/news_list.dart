import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/core/providers/news.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewsList extends StatelessWidget {
  const NewsList({Key? key, this.listSize}) : super(key: key);
  /// STATES
  final listSize;

  @override
  Widget build(BuildContext context) {
    if (Provider.of<NewsDataProvider>(context).isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
    return buildNewsList(
      context,
      Provider.of<NewsDataProvider>(context).newsModels,
    );
  }

  Widget buildNewsList(BuildContext context, NewsModel data) {
    final List<Item> listOfNews = data.items;
    final List<Widget> newsTiles = [];

    /// Check to see if we want to display only a limited number of elements.
    /// If no constraint is given on the size of the list, then all elements are rendered.
    var size = listSize ?? listOfNews.length;
    for (var i = 0; i < size; i++) {
      final Item item = listOfNews[i];
      final tile = buildNewsTile(item, context);
      newsTiles.add(tile);
    }

    // Wrap the ListView in Padding to add horizontal margins.
    return listSize != null
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: ListTile.divideTiles(
          tiles: newsTiles,
          context: context,
          color: Theme.of(context).brightness == Brightness.dark
              ? listTileDividerColorDark
              : listTileDividerColorLight,
        ).toList(),
      ),
    )
        : ContainerView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: ListTile.divideTiles(
            tiles: newsTiles,
            context: context,
            color: Theme.of(context).brightness == Brightness.dark
                ? listTileDividerColorDark
                : listTileDividerColorLight,
          ).toList(),
        ),
      ),
    );
  }

  Widget buildNewsTile(Item newsItem, BuildContext context) {
    try {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RoutePaths.NewsDetailView,
            arguments: newsItem,
          );
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: IntrinsicHeight( // Ensures both sides have the same height
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
              children: [
                // Image on the left
                Container(
                  width: 120, // Fixed width for the image
                  margin: EdgeInsets.only(right: 8.0),
                  child: ImageLoader(
                    url: newsItem.image,
                    fullSize: true,
                    fit: BoxFit.cover, // Ensures the image fills the container
                  ),
                ),
                // Text content on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date and Title in one line
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0, // Reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: DateFormat.yMMMMd()
                                  .format(newsItem.date.toLocal()),
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' - '),
                            TextSpan(text: newsItem.title, style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge!.color,),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Subtitle below
                      Text(
                        newsItem.description,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14.0, // Reduced font size
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (err) {
      return Container();
    }
  }

  Widget subtitle(Item data) {
    return Container(
      height: 84,
      child: Row(
        children: <Widget>[
          ImageLoader(
            url: data.image,
            fullSize: true,
          ),
          SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.description,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 8),
                Text(DateFormat.yMMMMd().format(data.date.toLocal())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
