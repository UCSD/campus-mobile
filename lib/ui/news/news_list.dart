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
    return Semantics(
      link: true,
      label:
          'News from: ${DateFormat.yMMMMd().format(newsItem.date.toLocal())}. ${newsItem.title}. Click to learn more.',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RoutePaths.NEWS_DETAIL_VIEW,
            arguments: newsItem,
          );
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 8.0),
                  child: ImageLoader(
                    url: newsItem.image,
                    fullSize: true,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        textScaler: MediaQuery.textScalerOf(context),
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: DateFormat.yMMMMd().format(newsItem.date.toLocal()),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                height: 1.42,
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                            TextSpan(
                              text: ' - ',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(height: 1.42, fontSize: 16.0, decoration: TextDecoration.none),
                            ),
                            TextSpan(
                              text: newsItem.title,
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(height: 1.42, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        newsItem.description,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16.0, height: 1.42),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
