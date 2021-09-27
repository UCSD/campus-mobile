import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:flutter/material.dart';

class AvailabilityDisplay extends StatelessWidget {
  const AvailabilityDisplay({
    Key? key,
    required this.models,
    required this.groupName,
  }) : super(key: key);

  final List<AvailabilityModel> models;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return buildAvailabilityBars(context);
  }

  Widget buildAvailabilityBars(BuildContext context) {
    // initializes locations list and adds the group name to the list
    List<Widget> groupsList = [];
    Widget titleWidget = Container(
      alignment: Alignment.centerLeft,
      child: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      padding: EdgeInsets.only(
        left: 16,
        bottom: 5,
      ),
    );

    // loop through the new map and add each location to the groups ListTile
    for (AvailabilityModel model in models) {
      List<Widget> locations = [];
      locations.add(Container(
        alignment: Alignment.centerLeft,
        child: Text(model.name!),
      ));
      locations.add(Container(
        alignment: Alignment.centerLeft,
        child: Text(
          (100 * percentAvailability(model)).toInt().toString() +
              '% Availability',
          //style: TextStyle(color: Colors.black),
        ),
      ));
      locations.add(Container(
        alignment: Alignment.centerLeft,
        child: SizedBox(
            height: 12,
            width: 325,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: LinearProgressIndicator(
                    value: percentAvailability(model) as double?,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      setIndicatorColor(percentAvailability(model)),
                    )))),
        padding: EdgeInsets.only(bottom: 10),
      ));

      // combines the list into a ListTile
      groupsList.add(ListTile(
        title: Column(
          children: locations,
        ),
      ));
    }

    groupsList =
        ListTile.divideTiles(tiles: groupsList, context: context).toList();

    return Container(
      child: Column(
        children: [
          titleWidget,
          Expanded(
            child: Scrollbar(
              child: ListView(
                shrinkWrap: true,
                children: groupsList,
              ),
            ),
          ),
        ],
      ),
    );
  }

  num percentAvailability(AvailabilityModel location) {
    num percentAvailable = 0.0;
    percentAvailable = 1 - location.percentage!;

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
