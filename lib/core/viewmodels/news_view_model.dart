import 'package:campus_mobile/core/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/services/news_service.dart';
import 'package:campus_mobile/ui/widgets/cards/card_container.dart';

class NewsCard extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<NewsCard> {
  final NewsService _newsService = NewsService();
  Future<List<NewsModel>> _data;

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
    if (snapshot.hasData) {
      final List<NewsModel> data = snapshot.data;
      final List<Widget> newsTiles = List<Widget>();
      //data.length instead of 3
      for (int i = 0; i < 3; i++) {
        final NewsModel item = data[i];
        final tile = buildNewsTile(
            item.shortDescription, item.description, item.imageThumb);
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
      trailing: Image.network(
        imageURL,
        width: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsModel>>(
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
        );
      },
    );
  }
}
