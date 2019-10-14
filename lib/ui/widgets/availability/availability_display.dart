<<<<<<< HEAD
import 'package:campus_mobile_beta/core/models/availability_model.dart';
import 'package:campus_mobile_beta/ui/theme/app_theme.dart';
=======
import 'package:campus_mobile/core/models/availability_model.dart';
import 'package:campus_mobile/ui/theme/app_theme.dart';
>>>>>>> 9fd3b7b... add manage location view for availability card and adjust colors
import 'package:flutter/material.dart';

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
    return Text(model.locationName);
  }

  Widget buildAvailabilityBars(BuildContext context) {
    List<Widget> locations = List<Widget>();
    if (model.subLocations.isNotEmpty) {
      for (AvailabilityModel subLocation in model.subLocations) {
        locations.add(
          ListTile(
              title: Text(subLocation.locationName),
              subtitle: LinearProgressIndicator(
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 9fd3b7b... add manage location view for availability card and adjust colors
                value: 1 - ((subLocation.busyness) / 100).toDouble(),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(ColorPrimary),
              )),
<<<<<<< HEAD
=======
                  value: subLocation.busyness.toDouble())),
>>>>>>> ec52d45... build out basics of availability card and tie in data
=======
>>>>>>> 9fd3b7b... add manage location view for availability card and adjust colors
        );
      }
    } else {
      locations.add(ListTile(
        title: Text(model.locationName),
<<<<<<< HEAD
<<<<<<< HEAD
        subtitle: LinearProgressIndicator(value: 1 - model.busyness.toDouble()),
=======
        subtitle: LinearProgressIndicator(value: model.busyness.toDouble()),
>>>>>>> ec52d45... build out basics of availability card and tie in data
=======
        subtitle: LinearProgressIndicator(value: 1 - model.busyness.toDouble()),
>>>>>>> 9fd3b7b... add manage location view for availability card and adjust colors
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
}
