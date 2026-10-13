import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';

class AvailabilityDetailedView extends StatelessWidget {
  final SubLocations subLocation;
  const AvailabilityDetailedView({required this.subLocation});

  @override
  Widget build(BuildContext context) => ContainerView(child: buildLocationsList(context, subLocation));

  Widget buildLocationsList(BuildContext context, SubLocations subLocation) {
    List<Widget> list = [];
    list.add(
      ListTile(
        title: Text(
          "${subLocation.name}",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );

    List<Widget> floorTiles = [];
    for (int i = 0; i < subLocation.floors.length; i++) {
      Floor floor = subLocation.floors[i];
      floorTiles.add(
        ListTile(
          title: Semantics(
            container: true,
            child: Text(
              "${floor.name}",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: LOCATION_FONT_SIZE),
            ),
          ),
          subtitle: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  container: true,
                  child: Text((100 * percentAvailability(floor)).toInt().toString() + '% Busy'),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: PROGRESS_BAR_HEIGHT,
                  width: PROGRESS_BAR_WIDTH,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(BORDER_RADIUS),
                    child: ExcludeSemantics(
                      child: LinearProgressIndicator(
                        value: percentAvailability(floor) as double?,
                        backgroundColor: Colors.grey[BACKGROUND_GREY_SHADE],
                        valueColor: AlwaysStoppedAnimation<Color>(setIndicatorColor(percentAvailability(floor))),
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

    final dividedFloorTiles = ListTile.divideTiles(
      context: context,
      tiles: floorTiles,
      color: Theme.of(context).brightness == Brightness.dark ? listTileDividerColorDark : listTileDividerColorLight,
    ).toList();

    list.addAll(dividedFloorTiles);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(physics: BouncingScrollPhysics(), children: list),
    );
  }

  num percentAvailability(Floor subLocationFloor) => subLocationFloor.percentage;

  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Colors.red;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.green;
  }
}
