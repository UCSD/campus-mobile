import 'package:campus_mobile_experimental/core/models/shuttle.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:flutter/material.dart';

class ShuttleDisplay extends StatelessWidget {
  ShuttleDisplay({Key? key, required this.stop, required this.arrivingShuttles})
      : super(key: key);

  final ShuttleStopModel? stop;
  final List<ArrivingShuttle>? arrivingShuttles;

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
          buildInfoRow(),
          buildNextArrival(),
          Divider(),
          whetherNextArrivals(),
          buildArrivalData()
        ],
      );
    }
  }

  Widget buildNextArrival() {
    if (arrivingShuttles!.isEmpty || arrivingShuttles == null) {
      return Text(
        "No arrivals found.",
        style: TextStyle(color: Colors.grey, fontSize: 20),
      );
    } else {
      return Column(
        children: [
          Text(
            arrivingShuttles![0].routeName!,
            style: TextStyle(fontSize: 16),
          ),
          buildTimetoArrivalText()
        ],
      );
    }
  }

  Widget buildTimetoArrivalText() {
    int minutesToArrival = arrivingShuttles![0].secondsToArrival! ~/ 60;
    return Text(
      "Arriving in: $minutesToArrival minutes",
      style: TextStyle(color: Colors.grey, fontSize: 20),
    );
  }

  Padding buildInfoRow() {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              minRadius: 40,
              backgroundColor: HexColor(arrivingShuttles!.isEmpty
                  ? "#CCCCCC"
                  : arrivingShuttles![0].routeColor!),
              foregroundColor: Colors.black,
              child: Text(
                arrivingShuttles!.isEmpty
                    ? "?"
                    : arrivingShuttles![0].routeName![0],
                style: TextStyle(fontSize: 50),
              ),
            ),
            Text("@",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey,
                )),
            Container(
                alignment: Alignment.center,
                width: 80.0,
                height: 80.0,
                padding: EdgeInsets.all(5.0),
                decoration: new BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    shape: BoxShape.circle),
                child: Text(stop!.name!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey))),
          ],
        ));
  }

  Widget buildArrivalData() {
    List<Widget> arrivalsToRender = [];
    for (int index = 1;
        index < arrivingShuttles!.length && index <= 2;
        index++) {
      arrivalsToRender.add(buildArrivingShuttle(arrivingShuttles![index]));
    }

    return Column(children: arrivalsToRender);
  }

  Widget buildArrivingShuttle(ArrivingShuttle shuttle) {
    int minutesToArrival = shuttle.secondsToArrival! ~/ 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            minRadius: 20,
            backgroundColor: HexColor(shuttle.routeColor!),
            foregroundColor: Colors.black,
            child: Text(
              shuttle.routeName![0],
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        Text(
          shuttle.routeName!,
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
      str += "Route: ${element.routeId!} - ${element.routeName!}\n";
    });
    return str;
  }

  Widget whetherNextArrivals() {
    if (arrivingShuttles!.length <= 1) {
      return Text("");
    } else {
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
  }
}
