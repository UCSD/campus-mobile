import 'package:flutter/material.dart';

class Weather extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const ListTile(
            leading: Icon(Icons.wb_sunny),
            title: Text('72 in San Diego'),
            subtitle: Text('Clear'),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 70,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text('MON'),
                    Icon(Icons.wb_cloudy),
                    Text('76'),
                    Text('61'),
                  ],
                ),
              ),
              Container(
                width: 70,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text('TUE'),
                    Icon(Icons.wb_sunny),
                    Text('74'),
                    Text('61'),
                  ],
                ),
              ),
              Container(
                width: 70,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text('WED'),
                    Icon(Icons.wb_sunny),
                    Text('74'),
                    Text('61'),
                  ],
                ),
              ),
              Container(
                width: 70,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text('THU'),
                    Icon(Icons.wb_sunny),
                    Text('74'),
                    Text('61'),
                  ],
                ),
              ),
              Container(
                width: 70,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text('FRI'),
                    Icon(Icons.wb_sunny),
                    Text('74'),
                    Text('61'),
                  ],
                ),
              ),
            ],
          ),
          ButtonTheme.bar(
            // make buttons use the appropriate styles for cards
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('Surf Report'),
                  onPressed: () {/* ... */},
                ),
                FlatButton(
                  child: Icon(Icons.more_vert),
                  onPressed: () {/* ... */},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
