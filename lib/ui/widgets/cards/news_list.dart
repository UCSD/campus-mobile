import 'dart:convert';

import 'package:campus_mobile/core/models/news_model.dart';
import 'package:campus_mobile/ui/theme/text_styles.dart';
import 'package:flutter/material.dart';

class NewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getNews(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            // loop thru list
            for (var i in snapshot.data) {
              try {
                var json = jsonEncode(i.toString());

                var jsonDecoded = jsonDecode(json);
//                print(jsonDecoded);
//                print('****************************************');
              } catch (e) {
                print(e);
              }
            }
            return new Container(
              child: Text('Here'),
            );
          } else {
            return new Container(
              child: Text('Connection state not done'),
            );
          }
        });
//    return Card(
//      child: Column(
//        children: <Widget>[
//          Container(
//            child: Padding(
//              padding: const EdgeInsets.all(15.0),
//              child: Text(
//                'News',
//                style: headerStyle,
//              ),
//            ),
//            alignment: Alignment.centerLeft,
//          ),
//          buildNewsCard(),
//        ],
//      ),
//    );
  }

  Future<List<dynamic>> getNews() async {
    var newsModel = await NewsModel().getNews();

    return newsModel;
  }

  Future<Container> buildNewsList() async {
    var news = await getNews();
    print(news);
  }

  Container buildNewsCard() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: <Widget>[
          Container(
            child: Text(
              'Ah-Mason Jars - Revelle Residents  Ah-Mason Jars',
              style: subHeaderStyle,
            ),
            alignment: Alignment.centerLeft,
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                      'Revelle Hall Association invites Revelle Residents to come out and decorate a mason jar!! A nice way to add a personal touch to your bedroom decor.'),
                  flex: 3),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                      'https://studentevents.ucsd.edu/article_images/190925409555925.png'),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
