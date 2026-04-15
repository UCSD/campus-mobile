import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:flutter/material.dart';

class AvailabilityDisplay extends StatelessWidget {
  const AvailabilityDisplay({
    Key? key,
    required this.model,
  }) : super(key: key);

  final AvailabilityModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildLocationTitle(context),
        buildAvailabilityBars(context),
      ],
    );
  }

  Widget buildLocationTitle(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 8),
      child: Semantics(
        label: '${model.name.toUpperCase()}. Swipe left or right to view other areas',
        excludeSemantics: true,
        child: Text(
          model.name.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget buildAvailabilityBars(BuildContext context) {
    if (model.subLocations.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: DATA_UNAVAILABLE_TOP_PADDING),
        child: Text(
          "Data Unavailable",
          style: TextStyle(fontSize: LOCATION_FONT_SIZE),
        ),
      );
    }

    List<Widget> locations = model.subLocations.map((subLocation) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Semantics(
          button: subLocation.floors.isNotEmpty,
          label: subLocation.floors.isNotEmpty
              ? '${subLocation.name}. ${(100 * percentAvailability(subLocation)).toInt()}% Busy. View details for ${subLocation.name}'
              : '${subLocation.name}. ${(100 * percentAvailability(subLocation)).toInt()}% Busy',
          excludeSemantics: true,
          child: GestureDetector(
          onTap: () {
            if (subLocation.floors.isNotEmpty) {
              Navigator.pushNamed(
                context,
                RoutePaths.AVAILABILITY_DETAILED_VIEW,
                arguments: subLocation,
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subLocation.name,
                          style: subLocation.floors.isNotEmpty
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? textButtonSmallDark
                                  : textButtonSmallLight)
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? descriptiveTextSmallDark.copyWith(fontSize: 22.0)
                                  : descriptiveTextSmallLight.copyWith(fontSize: 22.0)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${(100 * percentAvailability(subLocation)).toInt()}% Busy',
                          style: Theme.of(context).brightness == Brightness.dark
                              ? textSmallMoreInfoDark
                              : textSmallMoreInfoLight,
                        ),
                      ],
                    ),
                  ),
                  if (subLocation.floors.isNotEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 35,
                          color: Theme.of(context).brightness == Brightness.dark ? linkColorLight : linkColorDark,
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(
                height: 6,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(BORDER_RADIUS),
                  child: LinearProgressIndicator(
                    value:
                        (percentAvailability(subLocation) <= 0.01) ? 0.01 : percentAvailability(subLocation).toDouble(),
                    backgroundColor: Colors.grey[BACKGROUND_GREY_SHADE],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      setIndicatorColor(percentAvailability(subLocation)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }).toList();

    return Expanded(
      child: Scrollbar(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: ListTile.divideTiles(
            tiles: locations,
            context: context,
            color:
                Theme.of(context).brightness == Brightness.dark ? listTileDividerColorDark : listTileDividerColorLight,
          ).toList(),
        ),
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
