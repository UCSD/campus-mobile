import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/shuttle_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop_model.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ShuttleDisplay extends StatelessWidget {
  ShuttleDisplay({
    Key key,
    @required this.stop,
    @required this.arrivingShuttles
  }): super(key: key);

  final ShuttleStopModel stop;
  List<ArrivingShuttle> arrivingShuttles;


  @override
  Widget build(BuildContext context) {
    print("Building ${stop.name}");

    //ShuttleDataProvider _shuttleCardDataProvider = Provider.of<ShuttleDataProvider>(context);
    //arrivingShuttles = _shuttleCardDataProvider.arrivalsToRender;

    if (arrivingShuttles == null) {
      return CircularProgressIndicator();
    }
    else {
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
                child: Text("Next Arrivals",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 20
                  ),
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
      return Text("No arrivals found.",
        style: TextStyle(
            color: Colors.grey,
            fontSize: 20
        ),
      );
    } else {
      return Column(
        children: [
          Text(arrivingShuttles[0].route.name,
            style: TextStyle(
                fontSize: 16
            ),
          ),
          buildTimetoArrivalText()
        ],
      );
    }
  }

  Widget buildTimetoArrivalText() {
    int minutesToArrival = arrivingShuttles[0].secondsToArrival ~/ 60;
    return Text("Arriving in: $minutesToArrival minutes",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 20
      ),
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
            backgroundColor: Colors.pinkAccent/*Color(HexColor.getColorFromHex(arrivingShuttles[0].pattern.color))*/,
            foregroundColor: Colors.black,
            child: Text("S",/*arrivingShuttles[0].route.name[0],*/
              style: TextStyle(fontSize: 50),
            ),
          ),
          Text("@",
              style: TextStyle(
                fontSize: 30,
                color: Colors.grey,
              )
          ),
          Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            padding: EdgeInsets.all(5.0),
            decoration: new BoxDecoration(
              border: Border.all(color: Colors.grey),
              shape: BoxShape.circle
            ),
            child: Text(stop.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey
              )
            )
          ),
        ],
      )
    );
  }

  Widget buildArrivalData() {

    List<Widget> arrivalsToRender = List<Widget>();
    for(int index = 1; index < arrivingShuttles.length; index++) {
      arrivalsToRender.add(buildArrivingShuttle(arrivingShuttles[index]));
      /*arrivalsToRender.add(Text("Route: ${arrivingShuttles[index].route.name} "
          "- ${arrivingShuttles[index].secondsToArrival}"));*/
    }

    return Column(
      children: arrivalsToRender
    );
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
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.black,
            child: Text(arrivingShuttles[0].route.name[0],
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        Text(shuttle.route.name,
          style: TextStyle(
              fontSize: 16
          ),
        ),
        Expanded( child: Container(),),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("$minutesToArrival min",
            style: TextStyle(
                fontSize: 16
            ),
          ),
        ),
      ],
    );
  }
/*  Widget buildShuttleDisplay() {
    return Column(
      children: [
        Text("Stop: ${stop.id} - ${stop.name}"),
        Text(_shuttleCardDataProvider.arrivalsToRender != null ? getArrivingShuttles() : "no arriving shuttle")
      ],
    );
  }*/

  String getArrivingShuttles() {
    String str = "";
    arrivingShuttles.forEach((element) {
      str += "Route: ${element.route.id} - ${element.route.name}\n";
    });
    return str;
  }
}
