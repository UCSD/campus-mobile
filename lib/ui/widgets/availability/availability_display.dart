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
    return Container(
      height: 275,
      child: Column(
        children: [buildLocationTitle(), buildAvailabilityBars()],
      ),
    );
  }

  Widget buildLocationTitle() {
    return Text(model.locationName);
  }

  Widget buildAvailabilityBars() {
    List<Widget> locations = List<Widget>();
    if (model.subLocations.isNotEmpty) {
      for (AvailabilityModel subLocation in model.subLocations) {
        locations.add(
          ListTile(
              title: Text(subLocation.locationName),
              trailing: LinearProgressIndicator(
                  value: subLocation.busyness.toDouble())),
        );
      }
    } else {
      locations.add(ListTile(
        title: Text(model.locationName),
        trailing: LinearProgressIndicator(
          value: model.busyness.toDouble(),
        ),
      ));
    }
    return Column(children: locations);
  }
}
