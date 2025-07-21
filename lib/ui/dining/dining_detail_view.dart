import 'package:campus_mobile_experimental/core/models/dining.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/models/availability.dart';
import '../../core/providers/availability.dart';
import 'dining_busyness_bar.dart';

class DiningDetailView extends StatefulWidget {
  const DiningDetailView({Key? key, required this.data}) : super(key: key);
  final prefix0.DiningModel data;

  @override
  State<DiningDetailView> createState() => _DiningDetailViewState();
}

class _DiningDetailViewState extends State<DiningDetailView> {
  late AvailabilityDataProvider _availabilityDataProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _availabilityDataProvider = Provider.of<AvailabilityDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final detailWidgets = buildDetailView(context, widget.data);
    return ContainerView(
      child: ListView.separated(
          itemCount: detailWidgets.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => detailWidgets[index],
      ),
    );
  }

  // Contains all the widgets that make up the Dining detail view.
  List<Widget> buildDetailView(BuildContext context, prefix0.DiningModel diningModel) {
    // Get availability for all dining halls
    List<AvailabilityModel?> availabilityModels = _availabilityDataProvider
        .availabilityModels
        .where((m) => m != null && m.name.contains("Dining Halls"))
        .toList();
    var busynessDiningHallModelOne = availabilityModels.firstWhere(
      (m) => m != null && m.name.contains("Dining Halls (1/2)"),
      orElse: () => null,
    );
    var busynessDiningHallModelTwo = availabilityModels.firstWhere(
      (m) => m != null && m.name.contains("Dining Halls (2/2)"),
      orElse: () => null,
    );
    var specials = diningModel.specials;
    return [
      Row(
        children: [
          // Vendor Logo
          diningModel.vendorLogo != null
              ? Container(
                  decoration: Theme.of(context).brightness == Brightness.dark
                      ? BoxDecoration(
                          border: Border.all(
                            color: darkLogoBorderColor, // global dark border color
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkLogoShadowColor.withOpacity(0.5), // global dark shadow color
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Image.network(
                    diningModel.vendorLogo!,
                    width: 80,
                    height: 80,
                  ),
                )
              : Icon(Icons.restaurant,
                  size: 56,
                  color: Theme.of(context).brightness == Brightness.light
                      ? lightPrimaryColor
                      : darkPrimaryColor2),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor Name
                Text(
                  diningModel.name,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 4),
                // Vendor Description
                Text(
                  diningModel.description,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  softWrap: true,
                  textWidthBasis: TextWidthBasis.parent,
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      // Availability Bars if applicable (Canyon Vista, Club Med, Pines, 64 Degrees, Cafe Ventanas)
      if ((busynessDiningHallModelOne != null &&
              busynessDiningHallModelOne.subLocations.any((child) =>
                  child.name.contains(diningModel.name) ||
                  diningModel.name.contains(child.name))) ||
          (busynessDiningHallModelTwo != null &&
              busynessDiningHallModelTwo.subLocations.any((child) =>
                  child.name.contains(diningModel.name) ||
                  diningModel.name.contains(child.name))))
        DiningBusynessBar(
          diningModel: diningModel,
          busynessDiningHallModel: (busynessDiningHallModelOne != null &&
                  busynessDiningHallModelOne.subLocations.any((child) =>
                      child.name.contains(diningModel.name) ||
                      diningModel.name.contains(child.name)))
              ? busynessDiningHallModelOne
              : busynessDiningHallModelTwo!,
        ),
      // Vendor hours
      buildHours(context, diningModel),
      // Vendor Special Hours
      if (diningModel.specialHours != null)
        buildSpecialHours(context, diningModel),
      // Specials Field
      if (specials?.specialTitle?.isNotEmpty == true)
        buildSpecialsField(context, diningModel),
      // Vendor Payment Options
      buildPaymentOptions(context, diningModel),
      // Vendor Location
      Text('Location',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Transform.translate(
        offset: const Offset(0, -15),
        child: buildDirectionsButton(context, diningModel),
      ),
      Transform.translate(
        offset: const Offset(0, -12),
        child: Row(
          children: [
            buildWebsiteButton(context, diningModel),
            SizedBox(width: 15),
            buildMenuButton(context, diningModel),
          ],
        ),
      ),
      // TODO: removed the menu on March 25, 2025
      //SizedBox(height: 20),
      //buildMenu(context, model),
    ];
  }

  ///////////// Hours Section /////////////
  Widget buildHours(BuildContext context, prefix0.DiningModel model) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 14),
      Text("Hours",
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      SizedBox(height: 8),
      ...List.generate(
          7,
          (i) => [
                HoursOfDay(day: i + 1, model: model),
                if (i < 6) buildDivider(context),
              ]).expand((widgetPair) => widgetPair).toList(),
      SizedBox(height: 16),
    ]);
  }

  Widget buildDivider(BuildContext context) {
    return Divider(
      height: 10,
      color: Theme.of(context).brightness == Brightness.dark
          ? listTileDividerColorDark
          : listTileDividerColorLight,
    );
  }

  ///////////// Special Hours Section /////////////
  Widget buildSpecialHours(BuildContext context, prefix0.DiningModel model) {
    var specialHoursDuration = "";
    if (model.specialHours?.specialHoursValidFrom != null &&
        model.specialHours?.specialHoursValidTo != null) {
      specialHoursDuration = model.specialHours!.specialHoursValidFrom! +
          " to " +
          model.specialHours!.specialHoursValidTo! +
          "\n";
    }
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Special Hours",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10),
        Text(
          model.specialHours!.specialHoursEvent,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          model.specialHours!.specialHoursEventDetails,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          specialHoursDuration,
          style: Theme.of(context).textTheme.bodySmall,
        )
      ]),
    );
  }

  ///////////// Specials Field /////////////
  // TODO: Implement the expiration if we decide to go in that direction
  //  (maybe the API updates automatically, and when fetched, the old promotion will be null
  //  so we don't really have to code an expiration. Only time will tell...
  Widget buildSpecialsField(BuildContext context, prefix0.DiningModel model) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Specials",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              model.specials?.specialTitle ?? '',
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).brightness == Brightness.light
                    ? descriptiveTextColorLight
                    : descriptiveTextColorDark,
                fontWeight: FontWeight.w700
              ),
            ),
            SizedBox(height: 4),
            Text(
              model.specials?.specialDescription ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
  }

  ///////////// Payment Options Section /////////////
  Widget buildPaymentOptions(BuildContext context, prefix0.DiningModel model) {
    String options = model.paymentOptions.join(', ');
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Options",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 10),
          Text(
            options,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // TODO: Unused, remove if not needed
  // Widget buildPictures(prefix0.DiningModel model) {
  //   List<ImageLoader> images = [];
  //   if (model.images != null && model.images!.length > 0) {
  //     for (prefix0.Image item in model.images!) {
  //       if (item.small != null) images.add(ImageLoader(url: item.small!));
  //     }
  //     return Center(
  //       child: Container(
  //         height: 100,
  //         child: ListView.separated(
  //           itemCount: images.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             return images[index];
  //           },
  //           separatorBuilder: (BuildContext context, int index) {
  //             return Container(width: 10);
  //           },
  //           scrollDirection: Axis.horizontal,
  //         ),
  //       ),
  //     );
  //   }
  //   return Container(height: 10);
  // }
}

///////////// Location Section /////////////
Widget buildDirectionsButton(BuildContext context, prefix0.DiningModel model) {
  if (model.coordinates != null &&
      model.coordinates!.lat != null &&
      model.coordinates!.lon != null) {
    return TextButton(
      child: Row(
        children: <Widget>[
          Text('Get Directions',
            style: linkTextDark.copyWith(
              fontSize: 18.0,
              color: Theme.of(context).brightness == Brightness.light
                  ? linkColorLight
                  : linkColorDark,
            ),
          ),
          SizedBox(width: 6),
          Row(
            children: <Widget>[
              Icon(
                Icons.directions_walk,
                color: Theme.of(context).brightness == Brightness.light
                    ? linkColorLight
                    : linkColorDark,
                size: 32,
              ),
              model.distance != null
                  ? Text(
                      num.parse(model.distance!.toStringAsFixed(1)).toString() +
                          ' mi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 18.0,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? linkColorLight
                                    : linkColorDark,
                          ))
                  : Text('--', style: TextStyle(color: linkColorLight)),
            ],
          ),
        ],
      ),
      onPressed: () {
        try {
          launch(
              'https://www.google.com/maps/dir/?api=1&destination=${model.coordinates!.lat},${model.coordinates!.lon}&travelmode=walking',
              forceSafariVC: true);
        } catch (e) {
          // an error occurred, do nothing
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0.0),
      ),
    );
  } else {
    return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Text('Directions not available.',
            style: Theme.of(context).textTheme.bodySmall));
  }
}

///////////// Website and Menu Section /////////////
Widget buildWebsiteButton(BuildContext context, prefix0.DiningModel model) {
  if (model.url != null && model.url != '') {
    return TextButton(
      child: Text('Visit Website'),
      onPressed: () {
        try {
          launch(model.url!, forceSafariVC: true);
        } catch (e) {
          // an error occurred, do nothing
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: actionButtonBackgroundColor,
        foregroundColor: lightPrimaryColor,
        padding: EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
      ),
    );
  } else
    return Container();
}

Widget buildMenuButton(BuildContext context, prefix0.DiningModel model) {
  if (model.menuWebsite != null && model.menuWebsite!.isNotEmpty) {
    return TextButton(
      child: Row(
        children: [
          Text('View Menu'),
          SizedBox(width: 5),
          Icon(Icons.open_in_new, size: 16),
        ],
      ),
      onPressed: () {
        try {
          launch(model.menuWebsite!, forceSafariVC: true);
        } catch (e) {
          // an error occurred, do nothing
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: Color(0xFF00629B),
        foregroundColor: Colors.white,
        padding: EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
      ),
    );
  } else {
    return Container();
  }
}

// TODO: Unused, remove if not needed
// Widget buildMenu(BuildContext context, prefix0.DiningModel model) {
//   if (model.meals != null) {
//     return DiningMenuList(
//       model: model,
//     );
//   } else {
//     return Container();
//   }
// }

// Feeds the "Hours" section of the Dining Detail View //
class HoursOfDay extends StatelessWidget {
  const HoursOfDay({Key? key, required this.day, required this.model}) : super(key: key);
  final int day;
  final prefix0.DiningModel model;

  @override
  Widget build(BuildContext context) {
    // Extract the hours for the given day from the model
    var result = extractDayHours(day, model);
    var theDay = result['day'];
    var hoursText = (result['hours'] == "Invalid Date-Invalid Date") ? "Unknown Hours" : result['hours'];
    // Determine the hours' text style
    final TextStyle hoursTextStyle = day == DateTime.now().weekday
        ? TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.light
                ? lightPrimaryColor
                : darkPrimaryColor2)
        : Theme.of(context).textTheme.bodySmall!;

    // Check if this is the current day
    final bool isToday = day == DateTime.now().weekday;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: Row(
              children: [
                // Show the green dot for today
                if (isToday) ...[
                  GreenDot(currHours: hoursText!),
                  SizedBox(width: 5),
                ],
                // "Monday" - Bold if today is Monday.
                Text(
                  '$theDay',
                  style: isToday
                      ? TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w700,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? lightPrimaryColor
                                  : darkPrimaryColor2)
                      : Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Display the hours text i.e. 9:30 AM - 4:30 PM (using the finals above)
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hoursText!,
                  style: hoursTextStyle,
                ),
              ],
            ),
          )
        ],
      ),
    ]);
  }
}

Map<String, String> extractDayHours(int day, prefix0.DiningModel? model) {
  var theDay;
  var theHours;
  // Extract the hours of the given day
  switch (day) {
    case 1:
      theDay = 'Monday';
      theHours =
          model!.regularHours.mon == null ? 'Closed' : model.regularHours.mon;
      break;
    case 2:
      theDay = 'Tuesday';
      theHours =
          model!.regularHours.tue == null ? 'Closed' : model.regularHours.tue;
      break;
    case 3:
      theDay = 'Wednesday';
      theHours =
          model!.regularHours.wed == null ? 'Closed' : model.regularHours.wed;
      break;
    case 4:
      theDay = 'Thursday';
      theHours =
          model!.regularHours.thu == null ? 'Closed' : model.regularHours.thu;
      break;
    case 5:
      theDay = 'Friday';
      theHours =
          model!.regularHours.fri == null ? 'Closed' : model.regularHours.fri;
      break;
    case 6:
      theDay = 'Saturday';
      theHours =
          model!.regularHours.sat == null ? 'Closed' : model.regularHours.sat;
      break;
    case 7:
      theDay = 'Sunday';
      theHours =
          model!.regularHours.sun == null ? 'Closed' : model.regularHours.sun;
      break;
  }

  /*As of 05/05/2020, API may return 'Closed-Closed' as a value. If it does, correct it to look right.*/
  if (theHours == 'Closed-Closed') theHours = 'Closed';
  // Determine the hours' text
  final String hoursText = (theHours != null && theHours.contains('Closed')) ||
          theHours == 'Open 24/7'
      ? theHours!
      : (formattedTimeRange(theHours) ?? theHours!);

  return {'day': theDay, 'hours': hoursText};
}

class GreenDot extends StatelessWidget {
  const GreenDot({Key? key, required this.currHours}) : super(key: key);
  final String currHours;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _determineColor(),
      ),
    );
  }

  Color _determineColor() {
    // Handle special cases like "Closed" or "Open 24/7"
    if (currHours == 'Closed') {
      return Colors.red;
    } else if (currHours == 'Open 24/7') {
      return Colors.green;
    }

    // If this is a time range like "9:00 AM - 5:00 PM"
    if (currHours.contains('-')) {
      try {
        final timeStrings = currHours.split('-');
        if (timeStrings.length != 2) {
          return Colors.grey; // Invalid format
        }

        // Parse the start and end times
        final now = TimeOfDay.now();
        final currentTimeInMinutes = now.hour * 60 + now.minute;

        // Parse start time (e.g. "9:00 AM")
        final startTime = _parseTimeString(timeStrings[0].trim());
        if (startTime == null) return Colors.grey;

        // Parse end time (e.g. "5:00 PM")
        final endTime = _parseTimeString(timeStrings[1].trim());
        if (endTime == null) return Colors.grey;

        // Adjust for overnight hours
        int adjustedEndTime = endTime;
        if (endTime < startTime) {
          adjustedEndTime += 24 * 60; // Add a day in minutes
        }

        // Determine if current time is within the range
        if (currentTimeInMinutes >= startTime &&
            currentTimeInMinutes < adjustedEndTime) {
          return Colors.green;
        } else {
          return Colors.red;
        }
      } catch (e) {
        print('Error parsing time: $e');
        return Colors.grey; // Error in parsing
      }
    }
    return Colors.grey; // Default color for unrecognized format
  }

  // Parse time strings like "9:00 AM" into minutes since midnight
  int? _parseTimeString(String timeString) {
    // Try to extract the hour, minute, and AM/PM parts
    final amPmRegex = RegExp(r'(\d+):(\d+)\s*(AM|PM)');
    final match = amPmRegex.firstMatch(timeString);

    if (match != null && match.groupCount >= 3) {
      int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);
      final String amPm = match.group(3)!.toUpperCase();

      // Convert 12-hour to 24-hour format
      if (amPm == 'PM' && hour < 12) {
        hour += 12;
      } else if (amPm == 'AM' && hour == 12) {
        hour = 0;
      }

      return hour * 60 + minute;
    }

    return null;
  }
}