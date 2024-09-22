import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/weather.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/weather.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'weather';
const String WEATHER_ICON_BASE_URL =
    'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/';

class WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CardContainer(
          active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
          hide: () => Provider.of<CardsDataProvider>(context, listen: false)
              .toggleCard(cardId),
          reload: () => Provider.of<WeatherDataProvider>(context, listen: false)
              .fetchWeather(),
          isLoading: Provider.of<WeatherDataProvider>(context).isLoading,
          titleText: CardTitleConstants.titleMap[cardId],
          errorText: Provider.of<WeatherDataProvider>(context).error,
          child: () => buildCardContent(
              Provider.of<WeatherDataProvider>(context).weatherModel!),
          footer: buildFooter(),
        ),
      ],
    );
  }

  Widget buildFooter() {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => openLink(
                  'https://developer.apple.com/weatherkit/data-source-attribution/'),
              child: Text(
                "Weather Attribution",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Row(
              children: [
                Image.asset(
                  'assets/images/apple-logo.png',
                  fit: BoxFit.contain,
                  height: 15,
                  color: Colors.black,
                ),
                SizedBox(width: 4),
                Text("Weather")
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getDayOfWeek(int epoch) {
    DateTime dt = new DateTime.fromMillisecondsSinceEpoch(epoch * 1000);

    switch (dt.weekday) {
      case 1:
        return 'MON';
      case 2:
        return 'TUE';
      case 3:
        return 'WED';
      case 4:
        return 'THU';
      case 5:
        return 'FRI';
      case 6:
        return 'SAT';
      case 7:
        return 'SUN';
      default:
        return '';
    }
  }

  Widget buildCardContent(WeatherModel data) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2, // Number of items you want to display
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildCurrentWeather(data.currentWeather!);
        } else if (index == 1) {
          return buildWeeklyForecast(data.weeklyForecast!);
        }
        return SizedBox.shrink(); // Return an empty widget for safety
      },
    );
  }

  Widget buildWeeklyForecast(WeeklyForecast weeklyForecast) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: <Widget>[
          buildDailyForecast(weeklyForecast.data![0]),
          buildDailyForecast(weeklyForecast.data![1]),
          buildDailyForecast(weeklyForecast.data![2]),
          buildDailyForecast(weeklyForecast.data![3]),
          buildDailyForecast(weeklyForecast.data![4]),
        ],
      ),
    );
  }

  Widget buildDailyForecast(Forecast data) {
    return Container(
      child: Expanded(
        child: Column(
          children: <Widget>[
            Text(getDayOfWeek(data.time!)),
            CachedNetworkImage(
                imageUrl: WEATHER_ICON_BASE_URL + data.icon! + '.png',
                width: 35,
                height: 35,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                      value: downloadProgress.progress,
                    ),
                  );
                },
                errorWidget: (context, url, error) => Icon(Icons.error)),
            Text(data.temperatureHigh!.round().toString() + '\u00B0'),
            Text(data.temperatureLow!.round().toString() + '\u00B0'),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentWeather(Weather data) {
    return Container(
      child: Row(
        children: <Widget>[
          CachedNetworkImage(
              imageUrl: WEATHER_ICON_BASE_URL + data.icon! + '.png',
              width: 110,
              height: 110,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                    value: downloadProgress.progress,
                  ),
                );
              },
              errorWidget: (context, url, error) => Icon(Icons.error)),
          Expanded(
            child: ListTile(
              title: Text(
                data.temperature!.round().toString() +
                    '\u00B0' +
                    ' in San Diego',
                textAlign: TextAlign.start,
              ),
              subtitle: Text(
                data.summary!,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
