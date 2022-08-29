import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:flutter/material.dart';

class AvailabilityDetailedView extends StatelessWidget {
  final SubLocations subLocation;
  const AvailabilityDetailedView({required this.subLocation});

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildLocationsList(context, subLocation),
    );
  }

  Widget buildLocationsList(BuildContext context, subLocation) {
    // Add a tile for the subLocation name
    List<Widget> list = [];
    list.add(ListTile(
      title: Text(
        "${subLocation.name}",
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
    ));

    // Add a tile for every floor in the subLocation list
    for (int i = 0; i < subLocation.floors.length; i++) {
      list.add(
        ListTile(
          title: Text(
            "${subLocation.floors[i].name}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: LOCATION_FONT_SIZE),
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
    return ListView(
      physics: BouncingScrollPhysics(),
      children: list,
    );
  }

  // Calculate the percent available
  num percentAvailability(SubLocations subLocation) =>
      1 - subLocation.percentage!;

  // Color options
  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Colors.green;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.red;
  }
}
