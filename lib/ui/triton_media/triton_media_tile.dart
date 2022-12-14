import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/providers/triton_media.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventTile extends StatelessWidget {
  const EventTile({Key? key, required this.data}) : super(key: key);
  final EventModel data;
  final double tileWidth = 190;

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading!
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildEventTile(context);
  }

  Widget buildEventTile(BuildContext context) {
    return Container(
      width: tileWidth,
      height: 300,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, RoutePaths.EventDetailView,
              arguments: data);
        },
        child: Column(
          children: [
            eventImageLoader(data.imageThumb),
            SizedBox(
              height: 145,
              width: tileWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.title!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 5),
                        ),
                        eventsDateTime(data),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ], // children
        ),
      ),
    );
  }

  Widget eventImageLoader(String? url) {
    return url!.isEmpty
        ? Container(
            child: Image(
            image: AssetImage('assets/images/UCSDMobile_sharp.png'),
            height: 150,
            width: tileWidth,
            fit: BoxFit.fill,
          ))
        : Image.network(
            url,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            fit: BoxFit.fill,
            height: 150,
            width: tileWidth,
          );
  }

  Widget eventsDateTime(EventModel data) {
    try {
      // Separate dates from times
      String startMonthDayYear =
          DateFormat.yMMMMd('en_US').format(data.startDate!.toLocal());
      String endMonthDayYear =
          DateFormat.yMMMMd('en_US').format(data.endDate!.toLocal());
      String startTime = DateFormat.jm().format(data.startDate!.toLocal());
      String endTime = DateFormat.jm().format(data.endDate!.toLocal());

      // Mark any special types of events
      bool sameDay = (startMonthDayYear == endMonthDayYear);
      bool unspecifiedTime = (startTime == '12:00 AM' && endTime == '12:00 AM');
      Widget date;
      Widget time;
      if (sameDay) {
        date = Text(
          startMonthDayYear,
          style: TextStyle(fontSize: 12),
        ); // Ex. June 11, 2021
      } else {
        // if not the same date, check if the same year
        String startYear = startMonthDayYear.substring(
            startMonthDayYear.indexOf(',') + 2, startMonthDayYear.length);
        String endYear = endMonthDayYear.substring(
            endMonthDayYear.indexOf(',') + 2, endMonthDayYear.length);
        if (startYear == endYear) {
          // if the same year, check if the same month
          String startMonth =
              startMonthDayYear.substring(0, startMonthDayYear.indexOf(' '));
          String endMonth =
              endMonthDayYear.substring(0, endMonthDayYear.indexOf(' '));
          if (startMonth == endMonth) {
            // if different date in the same month and year
            String startDay = startMonthDayYear.substring(
                startMonthDayYear.indexOf(' ') + 1,
                startMonthDayYear.indexOf(','));
            String endDay = endMonthDayYear.substring(
                endMonthDayYear.indexOf(' ') + 1, endMonthDayYear.indexOf(','));
            date = Text(
              startMonth + ' ' + startDay + ' - ' + endDay + ', ' + startYear,
              style: TextStyle(fontSize: 12),
            ); // Ex. September 11 - 26, 2021
          } else {
            // if different month in the same year
            String startMonthDay =
                startMonthDayYear.substring(0, startMonthDayYear.indexOf(','));
            String endMonthDay =
                endMonthDayYear.substring(0, endMonthDayYear.indexOf(','));
            date = Text(
              startMonthDay + ' - ' + endMonthDay + ', ' + startYear,
              style: TextStyle(fontSize: 12),
            ); // Ex. September 11 - October 26, 2021
          }
        } else {
          date = Text(
            startMonthDayYear + ' - ' + endMonthDayYear,
            style: TextStyle(fontSize: 12),
          ); // Ex. June 11, 2021 - May 12, 2023
        }
      }

      if (unspecifiedTime) {
        time = Text(
          '',
          style: TextStyle(fontSize: 12),
        );
      } else {
        time = Text(
          startTime + ' - ' + endTime,
          style: TextStyle(fontSize: 12),
        );
      }

      return Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          date,
          Padding(
            padding: EdgeInsets.only(bottom: 5),
          ),
          time
        ],
      );
    } catch (e) {
      print(e);
      return Container();
    }
  }
}
