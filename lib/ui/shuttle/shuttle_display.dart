import 'package:campus_mobile_experimental/core/models/shuttle.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:flutter/material.dart';

import '../../app_styles.dart';

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
          buildInfoRow(context),
          SizedBox(height: 12),
          buildNextArrival(context),
          /// fix
          Divider(),
          whetherNextArrivals(),
          buildArrivalData()
        ],
      );
    }
  }

  Row buildInfoRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                final Color textColor = luminance > 0.5 ? Colors.black : Colors.white;
                return Text(
                  arrivingShuttles!.isEmpty ? "?" : arrivingShuttles![0].routeName[0],
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

  Widget buildNextArrival(BuildContext context) {
    if (arrivingShuttles!.isEmpty || arrivingShuttles == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 16),
          Text("No arrivals found.",
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
              Text(
                arrivingShuttles![0].routeName,
                style: TextStyle(
                  fontSize: 23.0,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).brightness == Brightness.light
                      ? descriptiveTextColorLight
                      : descriptiveTextColorDark,
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

  Widget whetherNextArrivals() {
    if (arrivingShuttles!.length <= 1) return Text("");
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "Next Arrivals",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget buildArrivalData() {
    List<Widget> arrivalsToRender = [];
    for (var index = 1;
        index < arrivingShuttles!.length && index <= 2;
        index++) {
      arrivalsToRender.add(buildArrivingShuttle(arrivingShuttles![index]));
    }
    return Column(children: arrivalsToRender);
  }

  Widget buildArrivingShuttle(ArrivingShuttle shuttle) {
    var minutesToArrival = shuttle.secondsToArrival ~/ 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
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
        Text(
          shuttle.routeName,
          style: TextStyle(fontSize: 16),
        ),
        Expanded(
          child: Container(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$minutesToArrival min",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  String getArrivingShuttles() {
    String str = "";
    arrivingShuttles!.forEach((element) {
      str += "Route: ${element.routeId} - ${element.routeName}\n";
    });
    return str;
  }
}
