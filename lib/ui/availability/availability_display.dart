import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:flutter/material.dart';

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
        model.name,
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
    if (model.subLocations.isNotEmpty) {
      for (SubLocations subLocation in model.subLocations) {
        locations.add(
          ListTile(
            onTap: () => subLocation.floors.length > 0
                ? Navigator.pushNamed(
                    context, RoutePaths.AvailabilityDetailedView,
                    arguments: subLocation)
                : print('_handleIconClick: no subLocations'),
            visualDensity: VisualDensity.compact,
            trailing: subLocation.floors.length > 0
                ? Icon(Icons.arrow_forward_ios_rounded)
                : null,
            title: Text(
              subLocation.name,
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
                          '% Busy',
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

    // if no children, return an error container
    else {
      return Container(
        alignment: Alignment.center,
        child: Text(
          "Data Unavailable",
          style: TextStyle(fontSize: LOCATION_FONT_SIZE),
        ),
        padding: EdgeInsets.only(
          top: DATA_UNAVAILABLE_TOP_PADDING,
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

  num percentAvailability(SubLocations location) => location.percentage;

  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Colors.red;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.green;
  }
}
