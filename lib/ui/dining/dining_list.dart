import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart' as dining_model;
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/directions_helper.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:campus_mobile_experimental/ui/dining/payment_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiningList extends StatelessWidget {
  const DiningList({
    Key? key,
    this.listSize,
  }) : super(key: key);

  final listSize;

  @override
  Widget build(BuildContext context) {
    // Using Provider's filteredDiningModels so that the list respects the filters
    List<dining_model.DiningModel> data = Provider.of<DiningDataProvider>(context).filteredDiningModels;
    if (data.isEmpty) {
      return ContainerView(
        child: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Text(
              'No dining locations match your filters.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return buildDiningList(data, context);
  }

  Widget buildDiningList(List<dining_model.DiningModel> listOfDiners, BuildContext context) {
    final List<Widget> diningTiles = [];

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    var size = listSize ?? listOfDiners.length;
    for (var i = 0; i < size; i++) {
      final dining_model.DiningModel item = listOfDiners[i];
      final tile = buildDiningTile(item, context);
      diningTiles.add(tile);
    }

    return listSize != null
        ? ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: ListTile.divideTiles(
                    tiles: diningTiles,
                    context: context,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? listTileDividerColorDark
                        : listTileDividerColorLight)
                .toList(),
          )
        : Stack(
            children: [
              ContainerView(
                child: ListView(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  shrinkWrap: true,
                  children: ListTile.divideTiles(
                    tiles: diningTiles,
                    context: context,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? listTileDividerColorDark
                        : listTileDividerColorLight,
                  ).toList(),
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: PaymentFilterButton(),
              ),
            ],
          );
  }

  Widget textClosed(BuildContext context, {String? nextOpenDay, String? nextOpenTime}) {
    String closedText = 'Closed';
    if (nextOpenDay != null && nextOpenTime != null) closedText += '. Opens $nextOpenDay at $nextOpenTime.';
    return Text(closedText, style: Theme.of(context).textTheme.bodySmall);
  }

  Widget getHoursForToday(dining_model.RegularHours hours, BuildContext context) {
    int weekday = DateTime.now().weekday;
    String? dayHours;

    switch (weekday) {
      case 1:
        if (hours.mon != null)
          dayHours = hours.mon;
        else
          return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
        break;
      case 2:
        if (hours.tue != null)
          dayHours = hours.tue;
        else
          return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
        break;
      case 3:
        if (hours.wed != null)
          dayHours = hours.wed;
        else
          return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
        break;
      case 4:
        if (hours.thu != null)
          dayHours = hours.thu;
        else
          return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
        break;
      case 5:
        if (hours.fri != null)
          dayHours = hours.fri;
        else
          return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
        break;
      case 6:
        if (hours.sat != null)
          dayHours = hours.sat;
        else
          return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
        break;
      case 7:
        if (hours.sun != null)
          dayHours = hours.sun;
        else
          return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
        break;
      default:
        return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
    }
    if (RegExp(r"\b[0-9]{2}").allMatches(dayHours!).length != 2) {
      if (dayHours == 'Closed-Closed')
        return textClosed(context, nextOpenDay: findNextOpenDay(hours), nextOpenTime: findNextOpenTime(hours));
      if (dayHours == 'Invalid Date-Invalid Date')
        return Text("Unknown hours", style: Theme.of(context).textTheme.bodySmall);

      return Text(dayHours, style: Theme.of(context).textTheme.bodySmall);
    }

    return Text(
      formattedTimeRange(dayHours) ?? dayHours,
      style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
          color:
              Theme.of(context).brightness == Brightness.light ? descriptiveTextColorLight : descriptiveTextColorDark),
    );
  }

  Widget buildDiningTile(dining_model.DiningModel data, BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      // Vendor Logo
      minLeadingWidth: 0, // Reduce minimum width
      leading: ExcludeSemantics(
        child: SizedBox(
        width: 48,
        height: 48,
        child: data.vendorLogo != null
            ? Container(
                decoration: Theme.of(context).brightness == Brightness.dark
                    ? BoxDecoration(
                        color: lightTextColor,
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Image.network(
                  data.vendorLogo!,
                  width: 48,
                  height: 48,
                ),
              )
            : Icon(Icons.restaurant,
                size: 32,
                color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2),
      ),
      ),
      // Vendor Name
      title: Semantics(
        label: 'Open link. ${data.name}',
        excludeSemantics: true,
        child: Text(
          data.name,
          textAlign: TextAlign.start,
          style: Theme.of(context).brightness == Brightness.dark ? textButtonSmallDark : textButtonSmallLight,
        ),
      ),
      // Vendor Hours
      subtitle: Padding(
        padding: EdgeInsets.only(top: 6),
        child: getHoursForToday(data.regularHours, context),
      ),
      // Vendor's Distance and Directions
      trailing: buildIconWithDistance(data, context),
      onTap: () {
        // if (data.id != null) Provider.of<DiningDataProvider>(context, listen: false).fetchDiningMenu(data.id!);
        Navigator.pushNamed(context, RoutePaths.DINING_OPTION_DETAIL_VIEW, arguments: data);
      },
    );
  }

  // Builds the Right side of the ListTile containing the icon and distance
  Widget buildIconWithDistance(dining_model.DiningModel data, BuildContext context) {
    String distanceText = data.distance != null ? '${num.parse(data.distance!.toStringAsFixed(1))} miles' : '';
    return Semantics(
      label: distanceText,
      button: true,
      excludeSemantics: true,
      child: TextButton(
      style: TextButton.styleFrom(
        foregroundColor: linkColorLight,
      ),
      onPressed: () async {
        try {
          await DirectionsHelper.openDirections(data.coordinates!.lat!, data.coordinates!.lon!);
        } catch (e) {
          // an error occurred, do nothing
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk,
              size: 28, color: Theme.of(context).brightness == Brightness.light ? linkColorLight : linkColorDark),
          Text(
            data.distance != null ? (num.parse(data.distance!.toStringAsFixed(1)).toString() + ' mi') : '--',
            style: TextStyle(
                fontSize: 13, color: Theme.of(context).brightness == Brightness.light ? linkColorLight : linkColorDark),
          ),
        ],
      ),
    ),
    );
  }
}

String? findNextOpenDay(dining_model.RegularHours hours) {
  final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final now = DateTime.now();
  for (int i = 1; i <= 7; i++) {
    int nextDay = (now.weekday + i - 1) % 7;
    String? value;
    switch (nextDay + 1) {
      case 1:
        value = hours.mon;
        break;
      case 2:
        value = hours.tue;
        break;
      case 3:
        value = hours.wed;
        break;
      case 4:
        value = hours.thu;
        break;
      case 5:
        value = hours.fri;
        break;
      case 6:
        value = hours.sat;
        break;
      case 7:
        value = hours.sun;
        break;
    }
    if (value != null && value != 'Closed-Closed') return days[nextDay][0].toUpperCase() + days[nextDay].substring(1);
  }
  return null;
}

String? findNextOpenTime(dining_model.RegularHours hours) {
  final days = [hours.mon, hours.tue, hours.wed, hours.thu, hours.fri, hours.sat, hours.sun];
  final now = DateTime.now();
  for (int i = 1; i <= 7; i++) {
    int nextDay = (now.weekday + i - 1) % 7;
    String? range = days[nextDay];
    if (range != null && range != 'Closed-Closed') return formattedTimeRange(range)?.split('-').first.trim();
  }
  return null;
}
