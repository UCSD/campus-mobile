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

  /// MODELS
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
      margin: EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        model.name.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.normal,
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
          SizedBox(
            height: 79,
            child: Center(
              child: ListTile(
                horizontalTitleGap: 0,
                contentPadding: EdgeInsets.all(0),
                onTap: () => subLocation.floors.length > 0
                    ? Navigator.pushNamed(
                        context, RoutePaths.AvailabilityDetailedView,
                        arguments: subLocation)
                    : print('_handleIconClick: no subLocations'),
                visualDensity: VisualDensity.compact,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subLocation.name,
                        style: Theme.of(context).brightness == Brightness.dark
                          ? textButtonSmallDark.copyWith(
                            color: descriptiveTextColorDark,
                            decoration: TextDecoration.none
                          )
                          : textButtonSmallLight.copyWith(
                            color: descriptiveTextColorLight,
                            decoration: TextDecoration.none
                          ),
                        )
                    ),
                    if (subLocation.floors.length > 0)
                      Icon(Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                          ? linkColorLight : linkColorDark
                      )
                  ]
                ),
                subtitle: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 3,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          (100 * percentAvailability(subLocation))
                                  .toInt()
                                  .toString() +
                              '% Busy',
                          style: Theme.of(context).brightness == Brightness.dark
                              ? textSmallMoreInfoDark
                              : textSmallMoreInfoLight,
                        )),
                    SizedBox(
                      height: 3,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 12,
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
    locations = ListTile.divideTiles(
            tiles: locations,
            context: context,
            color: Theme.of(context).brightness == Brightness.dark
                ? listTileDividerColorDark
                : listTileDividerColorLight)
        .toList();

    return Flexible(
      child: Scrollbar(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: locations,
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
