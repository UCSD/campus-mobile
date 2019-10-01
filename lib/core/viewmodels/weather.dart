import 'dart:async';
import 'package:campus_mobile/core/services/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../components/card.dart';

const String WEATHER_ICON_BASE_URL =
    'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/';

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  final WeatherService _weatherService = WeatherService();
  Future _data;
  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_weatherService.isLoading) {
      setState(() {
        _data = _weatherService.fetchPost();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: _data,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CardContainer(
            /// TODO: need to hook up hidden to state using provider
            hidden: false,
            reload: () => _updateData(),
            isLoading: _weatherService.isLoading,
            title: buildTitle(snapshot),
            errorText: _weatherService.error,
            child: buildCardContent(snapshot),
            actionButtons: [buildActionButton()],
          ),
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

  Widget buildCardContent(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return Flexible(
        child: Column(children: <Widget>[
          buildCurrentWeather(snapshot),
          buildWeeklyForecast(snapshot),
        ]),
      );
    }
    return Column();
  }

  Widget buildWeeklyForecast(AsyncSnapshot snapshot) {
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

  Widget buildDailyForecast(AsyncSnapshot snapshot, int pos) {
    return Container(
      child: Expanded(
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
      ),
    );
  }

  Widget buildCurrentWeather(AsyncSnapshot snapshot) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (snapshot.data['currently']['temperature']).round().toString() +
                '\u00B0' +
                ' in San Diego',
            textAlign: TextAlign.start,
          ),
        ],
      ),
      subtitle: Text(
        snapshot.data['currently']['summary'],
        textAlign: TextAlign.start,
      ),
      trailing: Image.network(
        WEATHER_ICON_BASE_URL + snapshot.data['currently']['icon'] + '.png',
      ),
    );
  }

  Widget buildTitle(AsyncSnapshot snapshot) {
    return Text(
      "Weather",
      textAlign: TextAlign.left,
    );
  }

  Widget buildActionButton() {
    return FlatButton(
      child: Text(
        'Surf Report',
      ),
      onPressed: () {/*TODO navigate to surf view*/},
    );
  }
}
