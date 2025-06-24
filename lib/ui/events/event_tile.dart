import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app_styles.dart';

class EventTile extends StatelessWidget {
  const EventTile({Key? key, required this.data}) : super(key: key);

  /// LAYOUT CONSTANTS
  static const double tileWidth = 220; 
  static const cornerRadius = Radius.circular(5.0);
  static const sideBorder = BorderSide(width: 0.3);

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
      width: tileWidth,
      //height: 300,
      child: InkWell(
        onTap: (){
          Navigator.pushNamed(
            context,
            RoutePaths.EventDetailView,
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
    return SizedBox(
      height: 300,
      width: 240,       
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 0.3),
          borderRadius: BorderRadius.all(cornerRadius),
        ),
        child: Card(        
          margin: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          elevation: 4.0,
            // Tile Contents
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _eventImageLoader(data.imageThumb),                
                Row(
                  children: [
                    const SizedBox(width: 2),
                    StartEndDateContainer(
                      date: (data.endDate != null && data.startDate.day != data.endDate!.day)
                        ? DateFormat("MMM d y").format(data.startDate) + ' - ' + DateFormat("MMM d y").format(data.endDate!)
                        : DateFormat("MMM d y").format(data.startDate),
                    ),
                    const Spacer(),
                    TileTime(
                      time: data.endDate != null
                        ? DateFormat.jm().format(data.startDate) + ' - ' + DateFormat.jm().format(data.endDate!)
                        : DateFormat.jm().format(data.startDate),
                      isRange: data.endDate != null && data.startDate.day != data.endDate!.day,
                    ),
                    const SizedBox(width: 2),
                  ],
                ),
                TileTitle(title: data.title),
                SizedBox(height: 4),
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
            topLeft: EventTile.cornerRadius,
            topRight: EventTile.cornerRadius,
          ),
          child: Image.asset(
            'assets/images/UCSDMobile_sharp.png',
            height: 150,
            width: EventTile.tileWidth,
            fit: BoxFit.fitHeight
          ))
        : ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: EventTile.cornerRadius,
              topRight: EventTile.cornerRadius,
            ),
            child: Image.network(
              url!,
              loadingBuilder: (context, child, loadingProgress) {
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
              height: 150,
              width: EventTile.tileWidth,
              fit: BoxFit.fitHeight,
            )
          );    
}

class TileTitle extends StatelessWidget {
  final String title;
  const TileTitle({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 5.0, right: 16.0), 
      child: Center( 
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? linkTextColorLight
                : Colors.white,
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,  
          ),
        ),
      ),
    );
  }
}

class TileTime extends StatelessWidget {
  final String time;
  final bool isRange;
  const TileTime({Key? key, required this.time, this.isRange = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final splitTimes = time.split(' - ');
    final startTime = splitTimes[0];
    final endTime = splitTimes.length > 1 ? splitTimes[1] : '';
    final style = TextStyle(
      fontSize: 14,
      color: Theme.of(context).brightness == Brightness.light
          ? lightPrimaryColor
          : Colors.white,
      fontWeight: FontWeight.w400,
    );
    if (isRange) {
      return Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(startTime, textAlign: TextAlign.right, style: style),
                Text(' - ', style: style),
              ],
            ),
            Text(endTime, textAlign: TextAlign.right, style: style),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: Center(
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: style,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    }
  }
}

class StartEndDateContainer extends StatelessWidget {
  final String date;
  const StartEndDateContainer ({Key? key, required this.date}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 2.0, right: 4.0, top: 5.0),
      child: Row(
        children: [ // Mar 24 2025 - May 2 2025
                    //  0   1   2  3  4  5  6
          if (date.contains(' - '))
            ...[
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
                            color: Theme.of(context).brightness == Brightness.light
                                ? lightPrimaryColor
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                        // Start Date Day
                        Text(
                          date.split(' ')[1].toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).brightness == Brightness.light
                                ? lightPrimaryColor
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Padding( // "-"
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  date.split(' ')[3].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.light
                        ? lightPrimaryColor
                        : Colors.white,
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
                            color: Theme.of(context).brightness == Brightness.light
                                ? lightPrimaryColor
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                        // End Date Year
                        Text(
                          date.split(' ')[5].toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).brightness == Brightness.light
                                ? lightPrimaryColor
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ]
          // If it's a single date, display it normally
          else
            ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust the padding as needed
                child: Column(
                  children: [
                    // Month
                    Text(
                      date.split(' ')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.light
                            ? lightPrimaryColor
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                    ),
                    // Day
                    Text(
                      date.split(' ')[1].toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).brightness == Brightness.light
                            ? lightPrimaryColor
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
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
