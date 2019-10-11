import 'package:campus_mobile_beta/core/models/availability_model.dart';
import 'package:campus_mobile_beta/ui/theme/app_theme.dart';
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
                value: 1 - ((subLocation.busyness) / 100).toDouble(),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(ColorPrimary),
              )),
=======
                  value: subLocation.busyness.toDouble())),
>>>>>>> ec52d45... build out basics of availability card and tie in data
        );
      }
    } else {
      locations.add(ListTile(
        title: Text(model.locationName),
<<<<<<< HEAD
        subtitle: LinearProgressIndicator(value: 1 - model.busyness.toDouble()),
=======
        subtitle: LinearProgressIndicator(value: model.busyness.toDouble()),
>>>>>>> ec52d45... build out basics of availability card and tie in data
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
