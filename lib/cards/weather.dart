import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String WEATHER_ICON_BASE_URL =
    'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/';

String getDayOfWeek(int epoch) {
  // Monday == 1
  DateTime dt = new DateTime.fromMillisecondsSinceEpoch(epoch * 1000);

  switch (dt.weekday) {
    case 1:
      return 'MON';
      break;
    case 2:
      return 'TUE';
      break;
    case 3:
      return 'WED';
      break;
    case 4:
      return 'THU';
      break;
    case 5:
      return 'FRI';
      break;
    case 6:
      return 'SAT';
      break;
    case 7:
      return 'SUN';
      break;
  }
}

Future<Map> fetchPost() async {
  final response = await http.get(
      'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return jsonDecode(response.body);
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

Widget buildDailyForecast(AsyncSnapshot snapshot, int pos) {
  return Container(
    width: 70,
    padding: EdgeInsets.all(10.0),
    child: Column(
      children: <Widget>[
        Text(getDayOfWeek(snapshot.data['daily']['data'][pos]['time'])),
        Image.network(WEATHER_ICON_BASE_URL +
            snapshot.data['daily']['data'][pos]['icon'] +
            '.png'),
        Text(snapshot.data['daily']['data'][pos]['temperatureHigh']
            .round()
            .toString()),
        Text(snapshot.data['daily']['data'][pos]['temperatureLow']
            .round()
            .toString()),
      ],
    ),
  );
}

// TODO: convert epoch time to human readable, https://stackoverflow.com/questions/45357520/dart-converting-milliseconds-since-epoch-unix-timestamp-into-human-readable
// go through each array for "daily" - no need to write loop function

class Weather extends StatelessWidget {
  final Future<Map> post;

  Weather({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<Map> post = fetchPost();

    return FutureBuilder<Map>(
        future: post,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.wb_sunny),
                    title: Text(snapshot.data['currently']['summary']),
                    subtitle: Text((snapshot.data['currently']['temperature'])
                        .round()
                        .toString()),
                  ),
                  Row(
                    children: <Widget>[
                      buildDailyForecast(snapshot, 0),
                      buildDailyForecast(snapshot, 1),
                      buildDailyForecast(snapshot, 2),
                      buildDailyForecast(snapshot, 3),
                      buildDailyForecast(snapshot, 4),
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
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        });
  }
}
