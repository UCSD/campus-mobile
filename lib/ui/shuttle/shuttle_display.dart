import 'package:campus_mobile_experimental/core/models/shuttle.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class ShuttleDisplay extends StatelessWidget {
  ShuttleDisplay({Key? key, required this.stop, required this.arrivingShuttles})
      : super(key: key);

  /// STATES
  final List<ArrivingShuttle>? arrivingShuttles;

  /// MODELS
  final ShuttleStopModel stop;

  @override
  Widget build(BuildContext context) {
    if (arrivingShuttles == null) {
      return Container(
        width: double.infinity,
        height: 200.0,
        child: Center(
          child: Container(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary)),
        ),
      );
    } else {
      return Column(
        children: [
          buildCircleStopRow(context),
          SizedBox(height: 16),
          buildUpcomingArrivalInfo(context),
          SizedBox(height: 16),
          buildNextArrivalsText(context),
          SizedBox(height: 16),
          buildNextArrivalsList(context),
        ],
      );
    }
  }

  Row buildCircleStopRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 6), // shadow only at the bottom
              ),
            ],
          ),
          child: CircleAvatar(
            minRadius: 40,
            backgroundColor: HexColor(arrivingShuttles!.isEmpty
                ? noArrivalsFoundColor
                : arrivingShuttles![0].routeColor),
            foregroundColor: Colors.black,
            child: Builder(
              builder: (context) {
                Color circleColor = HexColor(arrivingShuttles!.isEmpty
                    ? noArrivalsFoundColor
                    : arrivingShuttles![0].routeColor);
                // Calculate luminance to determine the color of "?"
                final double luminance = circleColor.computeLuminance();
                final Color textColor =
                    luminance > 0.5 ? Colors.black : Colors.white;
                return Text(
                  arrivingShuttles!.isEmpty
                      ? "?"
                      : arrivingShuttles![0].routeName[0],
                  style: TextStyle(
                    fontSize: 50,
                    color: textColor,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 16),
        Text("@",
            style: Theme.of(context).brightness == Brightness.light
                ? titleMediumLight
                : titleMediumDark),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            stop.name,
            textAlign: TextAlign.start,
            style: Theme.of(context).brightness == Brightness.light
                ? titleMediumLight
                : titleMediumDark,
            overflow: TextOverflow.visible, // optional, default wraps
            softWrap: true, // optional, default true
          ),
        ),
        SizedBox(width: 16)
      ],
    );
  }

  Widget buildUpcomingArrivalInfo(BuildContext context) {
    if (arrivingShuttles?.isEmpty ?? true) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 16),
          Text(
            "No arrivals found.",
            style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.light
                    ? descriptiveTextColorLight
                    : descriptiveTextColorDark),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  arrivingShuttles![0].routeName,
                  style: TextStyle(
                    fontSize: 23.0,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).brightness == Brightness.light
                        ? descriptiveTextColorLight
                        : descriptiveTextColorDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(width: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 16),
              Text(
                "Arriving in: ",
                style: TextStyle(
                  fontSize: 23.0,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).brightness == Brightness.light
                      ? descriptiveTextColorLight
                      : descriptiveTextColorDark,
                ),
              ),
              buildTimeToArrivalText(context),
            ],
          )
        ],
      );
    }
  }

  Widget buildTimeToArrivalText(BuildContext context) {
    var minutesToArrival = arrivingShuttles![0].secondsToArrival ~/ 60;
    return Text(
      "$minutesToArrival minutes",
      style: Theme.of(context).brightness == Brightness.light
          ? titleMediumLight
          : titleMediumDark,
    );
  }

  ////////////////////////// Next Arrivals Section //////////////////////////
  Widget buildNextArrivalsText(BuildContext context) {
    if (arrivingShuttles!.length <= 1) return SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "Next Arrivals",
            textAlign: TextAlign.left,
            style: Theme.of(context).brightness == Brightness.light
                ? titleMediumLight
                : titleMediumDark,
          ),
        ),
      ],
    );
  }

  Widget buildNextArrivalsList(BuildContext context) {
    List<Widget> arrivalsToRender = [];
    int count = (arrivingShuttles!.length - 1).clamp(0, 2);
    for (var index = 1; index <= count; index++) {
      arrivalsToRender.add(buildArrivalTime(context, arrivingShuttles![index]));
      if (index != count) arrivalsToRender.add(Divider());
    }
    return Column(children: arrivalsToRender);
  }

  Widget buildArrivalTime(BuildContext context, ArrivingShuttle shuttle) {
    var minutesToArrival = shuttle.secondsToArrival ~/ 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
          child: CircleAvatar(
            minRadius: 20,
            backgroundColor: HexColor(shuttle.routeColor),
            foregroundColor: Colors.black,
            child: Text(
              shuttle.routeName[0],
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            shuttle.routeName,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Expanded(flex: 1, child: Container()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$minutesToArrival min",
            style: Theme.of(context).brightness == Brightness.light
                ? titleMediumLight
                : titleMediumDark,
          ),
        ),
      ],
    );
  }

  // String getArrivingShuttles() {
  //   String str = "";
  //   arrivingShuttles!.forEach((element) {
  //     str += "Route: ${element.routeId} - ${element.routeName}\n";
  //   });
  //   return str;
  // }
}
