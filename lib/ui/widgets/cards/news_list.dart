import 'package:flutter/material.dart';

class NewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
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
          Text('Ah-Mason Jars - Revelle Residents  Ah-Mason Jars'),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                    'Revelle Hall Association invites Revelle Residents to come out and decorate a mason jar!! A nice way to add a personal touch to your bedroom decor.'),
              ),
              Image.network(
                  'https://studentevents.ucsd.edu/article_images/190925409555925.png'),
            ],
          ),
        ]),
      ),
    );
  }
}
