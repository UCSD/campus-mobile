import 'package:campus_mobile/core/models/availability_model.dart';
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
                  value: subLocation.busyness.toDouble())),
        );
      }
    } else {
      locations.add(ListTile(
        title: Text(model.locationName),
        subtitle: LinearProgressIndicator(value: model.busyness.toDouble()),
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
