import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class EventTile extends StatelessWidget {
  const EventTile({Key? key, required this.data}) : super(key: key);

  /// LAYOUT CONSTANTS
  static const double TILE_WIDTH = 190;
  static const CORNER_RADIUS = Radius.circular(5.0);
  static const SIDE_BORDER = BorderSide(width: 0.3);

  /// MODELS
  final EventModel data;

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is loading
    if (Provider.of<EventsDataProvider>(context).isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
    return _buildEventTile(context);
  }

  Widget _buildEventTile(BuildContext context) {
    return Container(
      width: TILE_WIDTH,
      // height: 300,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            RoutePaths.EVENT_DETAIL_VIEW,
            arguments: data,
          );
        },
        child: Column(
          children: [
            _eventDetailsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _eventDetailsCard(BuildContext context) {
    final df = DateFormat("MMM d y");

    final localStart = data.startDate.toLocal();
    final localEnd = data.endDate.toLocal();

    final startDate = df.format(localStart);
    final endDate = df.format(localEnd);
    final dateDisplay = startDate == endDate ? startDate : '$startDate - $endDate';
    final startTime = DateFormat.jm().format(localStart);
    final endTime = DateFormat.jm().format(localEnd);

    final isAllDay = (localStart.hour == 0) && (localEnd.hour == 23);

    final hasTime = startTime != endTime;
    return SizedBox(
      width: TILE_WIDTH,
      height: 300,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 0.3),
          borderRadius: BorderRadius.all(CORNER_RADIUS),
        ),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          elevation: 4.0,
          child: Column(
            children: [
              _eventImageLoader(data.imageThumb),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: hasTime ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: StartEndDateContainer(date: dateDisplay),
                      ),
                    ),
                    if (hasTime)
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: isAllDay
                              ? Text('All day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? lightPrimaryColor
                                        : Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ))
                              : TileTime(
                                  time: '$startTime - $endTime',
                                ),
                        ),
                      ),
                  ],
                ),
              ),

              // title & spacer remain the same
              TileTitle(title: data.title),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _eventImageLoader(String? url) {
  return url?.isEmpty ?? true
      ? ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: EventTile.CORNER_RADIUS,
            topRight: EventTile.CORNER_RADIUS,
          ),
          child: Image.asset(
            'assets/images/UCSDMobile_sharp.png',
            height: 150,
            width: EventTile.TILE_WIDTH,
            fit: BoxFit.cover,
          ))
      : ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: EventTile.CORNER_RADIUS,
            topRight: EventTile.CORNER_RADIUS,
          ),
          child: Image.network(
            url!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            height: 150,
            width: EventTile.TILE_WIDTH,
            fit: BoxFit.cover,
          ));
}

class TileTitle extends StatelessWidget {
  final String title;
  const TileTitle({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 5.0, right: 16.0), // Keep padding
      child: Center(
        // Centers the Text
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light ? linkTextColorLight : Colors.white,
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline, // Underlines the text
          ),
        ),
      ),
    );
  }
}

class TileTime extends StatelessWidget {
  final String time;
  const TileTime({Key? key, required this.time}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final splitTimes = time.split(' - ');

    // Extract start and end times from the time string
    final startTime = splitTimes[0];
    final endTime = splitTimes[1];

    final style = TextStyle(
      fontSize: 14,
      color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
      fontWeight: FontWeight.w400,
    );

    return Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (startTime != endTime)
              Row(
                children: [
                  // Start Time
                  Text(
                    startTime,
                    textAlign: TextAlign.right,
                    style: style,
                  ),
                  Text(" - ", style: style), // Separator
                ],
              ),
            Text(
              endTime, // End Time
              textAlign: TextAlign.right,
              style: style,
            ),
          ],
        ));
  }
}

class StartEndDateContainer extends StatelessWidget {
  final String date;
  const StartEndDateContainer({Key? key, required this.date}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 2.0, right: 4.0, top: 5.0),
      child: Row(
        children: [
          // Mar 24 2025 - May 2 2025
          //  0   1   2  3  4  5  6
          if (date.contains(' - ')) ...[
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    children: [
                      // Start Date Month
                      Text(
                        date.split(' ')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Start Date Day
                      Text(
                        date.split(' ')[1].toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              // "-"
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                date.split(' ')[3].toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8), // Adjust padding as needed
                  child: Column(
                    children: [
                      // End Date Day
                      Text(
                        date.split(' ')[4].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // End Date Year
                      Text(
                        date.split(' ')[5].toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ]
          // If it's a single date, display it normally
          else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust the padding as needed
              child: Column(
                children: [
                  // Month
                  Text(
                    date.split(' ')[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Day
                  Text(
                    date.split(' ')[1].toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ],
      ),
    );
  }
}
