import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:flutter/material.dart';

class AvailabilityDisplay extends StatelessWidget {
  const AvailabilityDisplay({
    Key? key,
    required this.model,
  }) : super(key: key);

  /// Models
  final AvailabilityModel model;

  /// Constant Values
  static const double SUB_LOCATION_FONT_SIZE = 17;
  static const double PROGRESS_BAR_HEIGHT = 12;
  static const double PROGRESS_BAR_WIDTH = 325;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildLocationTitle(),
        buildAvailabilityBars(context),
      ],
    );
  }

  Widget buildLocationTitle() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(16, 0, 16, 5),
      child: Text(
        model.name!,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      // subtitle: Row(
      //   children: <Widget>[
      //     Text(
      //       model.isOpen! ? "Open" : "Closed",
      //     ),
      //     Container(
      //       width: 12,
      //       height: 12,
      //       margin: EdgeInsets.all(5),
      //       decoration: BoxDecoration(
      //         color: model.isOpen! ? Colors.green : Colors.red,
      //         shape: BoxShape.circle,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget buildAvailabilityBars(BuildContext context) {
    List<Widget> locations = [];

    // add any children the model contains to the listview
    if (model.childCounts!.isNotEmpty) {
      for (ChildCount subLocation in model.childCounts!) {
        locations.add(
          ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(subLocation.name!,
                  style: TextStyle(
                    fontSize: SUB_LOCATION_FONT_SIZE,
                  )),
              subtitle: Column(children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (100 * percentAvailability(subLocation))
                              .toInt()
                              .toString() +
                          '% Availability',
                      // style: TextStyle(color: Colors.black),
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                      height: PROGRESS_BAR_HEIGHT,
                      width: PROGRESS_BAR_WIDTH,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: LinearProgressIndicator(
                            value: percentAvailability(subLocation) as double?,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                setIndicatorColor(
                                    percentAvailability(subLocation))),
                          ))),
                )
              ])),
        );
      }
    }

    // if no children, show an error ListTile
    else {
      locations.add(
        ListTile(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Data Unavailable",
              style: TextStyle(fontSize: SUB_LOCATION_FONT_SIZE),
            ),
          ),
        ),
      );
    }
    locations =
        ListTile.divideTiles(tiles: locations, context: context).toList();

    return Flexible(
      child: Scrollbar(
        child: ListView(
          children: locations,
        ),
      ),
    );
  }

  num percentAvailability(ChildCount location) {
    // num percentAvailable = 0.0;

    // if (location.isOpen!) {
    //   percentAvailable = 1 - location.percentage!;
    // }

    return 1 - location.percentage!;
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
