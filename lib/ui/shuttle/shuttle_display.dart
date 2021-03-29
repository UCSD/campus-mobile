import 'package:campus_mobile_experimental/core/models/shuttle.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ShuttleDisplay extends StatelessWidget {
  ShuttleDisplay(
      {Key key, @required this.stop, @required this.arrivingShuttles})
      : super(key: key);

  final ShuttleStopModel stop;
  final List<ArrivingShuttle> arrivingShuttles;

  @override
  Widget build(BuildContext context) {
    // print("Building ${stop.name}");
    print(arrivingShuttles);
    if (arrivingShuttles == null) {
      return Container(
        width: double.infinity,
        height: 200.0,
        child: Center(
          child: Container(
              height: 32, width: 32, child: CircularProgressIndicator()),
        ),
      );
    } else {
      return Column(
        children: [
          buildInfoRow(),
          buildNextArrival(),
          Divider(),
          Row(
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
          ),
          buildArrivalData()
        ],
      );
    }
  }

  Widget buildNextArrival() {
    if (arrivingShuttles.isEmpty || arrivingShuttles == null) {
      return Text(
        "No arrivals found.",
        style: TextStyle(color: Colors.grey, fontSize: 20),
      );
    } else {
      return Column(
        children: [
          Text(
            arrivingShuttles[0].route.name,
            style: TextStyle(fontSize: 16),
          ),
          buildTimetoArrivalText()
        ],
      );
    }
  }

  Widget buildTimetoArrivalText() {
    int minutesToArrival = arrivingShuttles[0].secondsToArrival ~/ 60;
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
              backgroundColor: HexColor(arrivingShuttles.isEmpty
                  ? "#B74093"
                  : arrivingShuttles[0].route.color),
              foregroundColor: Colors.black,
              child: Text(
                arrivingShuttles.isEmpty
                    ? "S"
                    : arrivingShuttles[0].route.name[0],
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
                child: Text(stop.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey))),
          ],
        ));
  }

  Widget buildArrivalData() {
    List<Widget> arrivalsToRender = List<Widget>();
    for (int index = 1;
        index < arrivingShuttles.length && index <= 2;
        index++) {
      arrivalsToRender.add(buildArrivingShuttle(arrivingShuttles[index]));
    }

    return Column(children: arrivalsToRender);
  }

  Widget buildArrivingShuttle(ArrivingShuttle shuttle) {
    int minutesToArrival = shuttle.secondsToArrival ~/ 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            minRadius: 20,
            backgroundColor: HexColor(shuttle.route.color),
            foregroundColor: Colors.black,
            child: Text(
              shuttle.route.name[0],
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        Text(
          shuttle.route.name,
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
    arrivingShuttles.forEach((element) {
      str += "Route: ${element.route.id} - ${element.route.name}\n";
    });
    return str;
  }
}
