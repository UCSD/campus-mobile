import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/core/providers/news.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewsList extends StatelessWidget {
  const NewsList({Key? key, this.listSize}) : super(key: key);

  final int? listSize;

  @override
  Widget build(BuildContext context) {
    if (Provider.of<NewsDataProvider>(context).isLoading!) {
      return Center(
          child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary));
    }
    return buildNewsList(
      context,
      Provider.of<NewsDataProvider>(context).newsModels!,
    );
  }

  Widget buildNewsList(BuildContext context, NewsModel data) {
    final List<Item>? listOfNews = data.items;

    /// Check to see if we want to display only a limited number of elements
    /// If no constraint is given on the size of the list, all elements are rendered
    var size;
    if (listSize == null)
      size = listOfNews!.length;
    else size = listSize;

    return listSize != null
        ? ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: size,
            itemBuilder: (context, index) {
              final Item item = listOfNews![index];
              return buildNewsTile(item, context);
            },
          )
        : ContainerView(
            child: ListView.builder(
              itemCount: size,
              itemBuilder: (context, index) {
                final Item item = listOfNews![index];
                return buildNewsTile(item, context);
              },
            ),
          );
  }

  Widget buildNewsTile(Item newsItem, BuildContext context) {
    try {
      return ListTile(
        isThreeLine: true,
        onTap: () {
          Navigator.pushNamed(context, RoutePaths.NewsDetailView,
              arguments: newsItem);
        },
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            newsItem.title!,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        subtitle: subtitle(newsItem),
      );
    } catch (err) {
      return Container();
    }
  }

  Widget subtitle(Item data) {
    return Container(
      height: 64,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.description!,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat.yMMMMd().format(data.date!.toLocal()),
                ),
              ],
            ),
          ),
          SizedBox(width: 4),
          ImageLoader(
            url: data.image,
            fullSize: true,
          ),
        ],
      ),
    );
  }
}
