//import 'dart:html';

import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:campus_mobile_experimental/core/models/availability_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
//import 'package:percent_indicator/percent_indicator.dart';

class AvailabilityDisplay extends StatelessWidget {
  const AvailabilityDisplay({
    Key key,
    @required this.model,
  }) : super(key: key);

  final AvailabilityModel model;

  @override
  Widget build(BuildContext context) {
    return buildAvailabilityBars(context);
  }

  Widget buildLocationTitle() {
    return ListTile(
        title: Text(
          model.locationName,
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontSize: 20,
          ),
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              model.isOpen ? "Open" : "Closed",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: model.isOpen ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ));
  }

  Widget buildAvailabilityBars(BuildContext context) {
    List<Widget> locations = List<Widget>();

    if (model.subLocations.isNotEmpty) {
      for (AvailabilityModel subLocation in model.subLocations) {
        locations.add(
          ListTile(
              title: Text(subLocation.locationName,
                  style: TextStyle(
                    fontSize: 17,
                  )),
              subtitle: Column(children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (100 * percentAvailability(subLocation))
                          .toInt()
                          .toString() +
                          '% Availability',
                      style: TextStyle(color: Colors.black),
                      //textAlign: TextAlign.right,
                    )),
                LinearProgressIndicator(
                  value: percentAvailability(subLocation),

                  // backgroundColor: setIndicatorColor(percent),
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      setIndicatorColor(percentAvailability(subLocation))),
                )
              ])),
        );
      }
    } else {
      locations.add(ListTile(
          title: Text(model.locationName),
          subtitle: Column(children: <Widget>[
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  (100 * percentAvailability(model)).toInt().toString() +
                      '% Availability',
                  style: TextStyle(color: Colors.black),
                  //textAlign: TextAlign.right,
                )),
            LinearProgressIndicator(
                value: percentAvailability(model),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                  setIndicatorColor(percentAvailability(model)),
                ))
          ])));
    }
    locations =
        ListTile.divideTiles(tiles: locations, context: context).toList();
    locations.insert(
        0,
        ListTile(
          title: Row(
            children: [
              Expanded(child: buildLocationTitle()),
            ],
          ),
        ));

    return ListView(children: locations);
  }

  num percentAvailability(AvailabilityModel location) {
    num percentAvailable =
        1 - ((location.busyness) / location.estimated).toDouble();
    if (model.isOpen == false) {
      percentAvailable = 0.0;
    } else if (location.isOpen == false) {
      percentAvailable = 0.0;
    }

    return percentAvailable;
  }

  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Colors.green;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.red;
  }
}
