//import 'dart:html';

import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:campus_mobile_experimental/core/models/availability_model.dart';
import 'package:flutter/material.dart';
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
        title: Text(model.locationName),
        subtitle: model.isOpen ?
        Text("Open",
          style: TextStyle(
              color: Colors.black),) :
        Text("Closed",
          style: TextStyle(
              color: Colors.black),)
    );
  }

  Widget buildAvailabilityBars(BuildContext context) {
    List<Widget> locations = List<Widget>();

    if (model.subLocations.isNotEmpty) {
      for (AvailabilityModel subLocation in model.subLocations) {
        num percentage = 1 - ((subLocation.busyness) / 100).toDouble();
        locations.add(
          ListTile(
              title: Text(subLocation.locationName),
              //subtitle: Text(percentage.toString() * 100 + "%"),
              subtitle: LinearProgressIndicator(
                value: percentage,

              // backgroundColor: setIndicatorColor(percent),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(setIndicatorColor(percentage)),
              )
          ),
        );
      }
    } else {
      locations.add(ListTile(
        title: Text(model.locationName),
        subtitle: LinearProgressIndicator(value: 1 - model.busyness.toDouble()),
      ));
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

  setIndicatorColor(num percentage) {
    if(percentage >= .75)
      return Colors.green;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.red;

  }




}
