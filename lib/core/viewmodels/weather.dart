import 'dart:async';
import 'dart:convert';

import 'package:campus_mobile/core/services/weather.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../components/card.dart';

const String WEATHER_ICON_BASE_URL =
    'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/';

class Weather extends StatefulWidget {
  WeatherService weatherService = _WeatherState()._weatherService;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WeatherState();
  }
}

class _WeatherState extends State<Weather> {
  WeatherService _weatherService = WeatherService();
  Future<Map> data;

  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_weatherService.isLoading) {
      setState(() {
        data = _weatherService.fetchPost();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: data,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        return CardContainer(
          reload: null,
          isLoading: _weatherService.isLoading,
          title: buildTitle(snapshot),
          errorText: _weatherService.error,
          children: <Widget>[
            buildWeeklyForcast(snapshot),
          ],
        );
      },
    );
  }

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
      default:
        return '';
    }
  }

  Widget buildWeeklyForcast(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return Container(
        child: Row(
          children: <Widget>[
            buildDailyForecast(snapshot, 0),
            buildDailyForecast(snapshot, 1),
            buildDailyForecast(snapshot, 2),
            buildDailyForecast(snapshot, 3),
            buildDailyForecast(snapshot, 4),
          ],
        ),
      );
    }
  }

  Widget buildDailyForecast(AsyncSnapshot snapshot, int pos) {
    return Container(
      width: 80,
      child: Column(
        children: <Widget>[
          Text(getDayOfWeek(snapshot.data['daily']['data'][pos]['time'])),
          Image.network(WEATHER_ICON_BASE_URL +
              snapshot.data['daily']['data'][pos]['icon'] +
              '.png'),
          Text(snapshot.data['daily']['data'][pos]['temperatureHigh']
                  .round()
                  .toString() +
              '\u00B0'),
          Text(snapshot.data['daily']['data'][pos]['temperatureLow']
                  .round()
                  .toString() +
              '\u00B0'),
        ],
      ),
    );
  }

  Widget buildTitle(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return ListTile(
        title: Text(
            (snapshot.data['currently']['temperature']).round().toString() +
                '\u00B0'),
        subtitle: Text(snapshot.data['currently']['summary']),
        trailing: Image.network(WEATHER_ICON_BASE_URL +
            snapshot.data['currently']['icon'] +
            '.png'),
      );
    }
  }
}
//class Weather extends StatelessWidget {
//  final Future<Map> post;
//
//  Weather({Key key, this.post}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    final Future<Map> post = fetchPost();
//
//    return FutureBuilder<Map>(
//        future: post,
//        builder: (context, snapshot) {
//          if (snapshot.hasData) {
//            return Card(
//              child: CardContainer(
//                title: buildTitle(snapshot),
//                isLoading: //google how to do asyn fetch or look back at tutorial,
//                child: Column(
//                  children: <Widget>[
//                    buildTitle(snapshot),
//                    Row(
//                      children: <Widget>[
//                        buildDailyForecast(snapshot, 0),
//                        buildDailyForecast(snapshot, 1),
//                        buildDailyForecast(snapshot, 2),
//                        buildDailyForecast(snapshot, 3),
//                        buildDailyForecast(snapshot, 4),
//                      ],
//                    ),
//                    ButtonTheme.bar(
//                      // make buttons use the appropriate styles for cards
//                      child: ButtonBar(
//                        children: <Widget>[
//                          FlatButton(
//                            child: const Text('Surf Report'),
//                            onPressed: () {/* ... */},
//                          ),
//                          FlatButton(
//                            child: Icon(Icons.more_vert),
//                            onPressed: () {/* ... */},
//                          ),
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            );
//          } else if (snapshot.hasError) {
//            return Text("${snapshot.error}");
//          }
//
//          // By default, show a loading spinner.
//          return Center(child: CircularProgressIndicator());
//        });
//  }
//}
