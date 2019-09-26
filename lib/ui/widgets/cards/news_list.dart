import 'package:campus_mobile/ui/theme/text_styles.dart';
import 'package:flutter/material.dart';

class NewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'News',
                style: headerStyle,
              ),
            ),
            alignment: Alignment.centerLeft,
          ),
          buildNewsCard(),
          buildNewsCard(),
          buildNewsCard(),
        ],
      ),
    );
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
