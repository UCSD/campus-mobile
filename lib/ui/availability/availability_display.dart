import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:flutter/material.dart';

import 'availability_constants.dart';

class AvailabilityDisplay extends StatelessWidget {
  const AvailabilityDisplay({
    Key? key,
    required this.model,
  }) : super(key: key);

  /// Models
  final AvailabilityModel model;

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
      margin: EdgeInsets.only(
        left: TITLE_SIDE_PADDINGS,
        right: TITLE_SIDE_PADDINGS,
        bottom: TITLE_BOTTOM_PADDING,
      ),
      child: Text(
        model.name!,
        style: TextStyle(
          fontSize: LOCATION_FONT_SIZE,
          fontWeight: FontWeight.bold,
        ),
      ),
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
            title: Text(
              subLocation.name!,
              style: TextStyle(
                fontSize: LOCATION_FONT_SIZE,
              ),
            ),
            subtitle: Column(
              children: <Widget>[
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
                      borderRadius: BorderRadius.circular(BORDER_RADIUS),
                      child: LinearProgressIndicator(
                        value: percentAvailability(subLocation) as double?,
                        backgroundColor: Colors.grey[BACKGROUND_GREY_SHADE],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          setIndicatorColor(
                            percentAvailability(subLocation),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // if no children, show an error ListTile
    else {
      locations.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            "Data Unavailable",
            style: TextStyle(fontSize: LOCATION_FONT_SIZE),
          ),
          padding: EdgeInsets.only(
            top: DATA_UNAVAILABLE_TOP_PADDING,
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

  num percentAvailability(ChildCount location) => 1 - location.percentage!;

  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Colors.green;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.red;
  }
}
