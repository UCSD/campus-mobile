import 'package:campus_mobile/core/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/services/news_service.dart';
import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:campus_mobile/ui/widgets/image_loader.dart';

class NewsCard extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<NewsCard> {
  final NewsService _newsService = NewsService();
  Future<NewsModel> _data;

  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_newsService.isLoading) {
      setState(() {
        _data = _newsService.fetchData();
      });
    }
  }

  Widget buildNewsCard(AsyncSnapshot snapshot) {
    return buildNewsList(snapshot, 3);
  }

  Widget buildNewsList(AsyncSnapshot snapshot, int listSize) {
    if (snapshot.hasData) {
      final NewsModel data = snapshot.data;
      final List<Item> listOfNews = data.items;
      final List<Widget> newsTiles = List<Widget>();
      for (int i = 0; i < listSize; i++) {
        final Item item = listOfNews[i];
        final tile = buildNewsTile(item.title, item.description, item.image);
        newsTiles.add(tile);
      }
      return Flexible(
        child: Column(
          children:
              ListTile.divideTiles(tiles: newsTiles, context: context).toList(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
    );
  }

  Widget buildNewsTile(String title, String subtitle, String imageURL) {
    if (imageURL.isEmpty) print('was empty');
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

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {/*TODO navigate to view with full news list*/},
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsModel>(
      future: _data,
      builder: (context, snapshot) {
        return CardContainer(
          /// TODO: need to hook up hidden to state using provider
          hidden: false,
          reload: () => _updateData(),
          isLoading: _newsService.isLoading,
          title: buildTitle("News"),
          errorText: _newsService.error,
          child: buildNewsCard(snapshot),
          actionButtons: buildActionButtons(),
        );
      },
    );
  }
}
