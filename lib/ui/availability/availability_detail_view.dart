import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
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
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: subLocation.floors.length + 1, // +1 to include the subLocation name tile
      itemBuilder: (context, index) {
        if (index == 0) {
          // Add the subLocation name as the first ListTile
          return ListTile(
            title: Text(
              "${subLocation.name}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          // Add tiles for each floor in the subLocation
          Floor floor = subLocation.floors[index - 1]; // Adjust index for floors
          return ListTile(
            title: Text(
              "${floor.name}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: LOCATION_FONT_SIZE,
              ),
            ),
            subtitle: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (100 * percentAvailability(floor)).toInt().toString() + '% Busy',
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: PROGRESS_BAR_HEIGHT,
                    width: PROGRESS_BAR_WIDTH,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(BORDER_RADIUS),
                      child: LinearProgressIndicator(
                        value: percentAvailability(floor) as double?,
                        backgroundColor: Colors.grey[BACKGROUND_GREY_SHADE],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          setIndicatorColor(percentAvailability(floor)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Calculate the percent available
  num percentAvailability(Floor subLocationFloor) =>
      subLocationFloor.percentage!;

  // Color options
  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Colors.red;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.green;
  }
}
