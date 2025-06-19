import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:flutter/material.dart';
import '../../core/models/dining.dart';

class DiningBusynessBar extends StatelessWidget {
  const DiningBusynessBar({
    Key? key,
    required this.diningModel,
    required this.busynessDiningHallModel,
  }) : super(key: key);

  final DiningModel diningModel;
  final AvailabilityModel busynessDiningHallModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildAvailabilityBars(context),
      ],
    );
  }

  Widget buildAvailabilityBars(BuildContext context) {
    if (busynessDiningHallModel.subLocations.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: DATA_UNAVAILABLE_TOP_PADDING),
        child: Text(
          "Data Unavailable",
          style: TextStyle(fontSize: LOCATION_FONT_SIZE),
        ),
      );
    }

    // Only display the subLocation where subLocation.name == diningModel.name
    final matchingSubLocation = busynessDiningHallModel.subLocations
        .where((subLocation) => subLocation.name.contains(diningModel.name))
        .toList();

    if (matchingSubLocation.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: DATA_UNAVAILABLE_TOP_PADDING),
        child: Text(
          "Busyness data not available for ${diningModel.name}",
          style: TextStyle(fontSize: LOCATION_FONT_SIZE),
        ),
      );
    }

    List<Widget> locations = matchingSubLocation.map((subLocation) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${(100 * percentAvailability(subLocation)).toInt()}% Busy',
            style: Theme.of(context).brightness == Brightness.light
                ? textSmallMoreInfoLight
                : textSmallMoreInfoDark,
          ),
          SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
                child: LinearProgressIndicator(
                  value: (percentAvailability(subLocation) <= 0.01)
                      ? 0.01
                      : percentAvailability(subLocation).toDouble(),
                  backgroundColor: Colors.grey[BACKGROUND_GREY_SHADE],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    setIndicatorColor(percentAvailability(subLocation)),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();

    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: ListTile.divideTiles(
          tiles: locations,
          context: context,
          color: Theme.of(context).brightness == Brightness.dark
              ? listTileDividerColorDark
              : listTileDividerColorLight,
        ).toList(),
      ),
    );
  }

  num percentAvailability(SubLocations location) => location.percentage;

  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Color(0xFFBD1900);
    else if (percentage >= .25)
      return Color(0xFFFC8900);
    else
      return Color(0xFF109B00);
  }
}