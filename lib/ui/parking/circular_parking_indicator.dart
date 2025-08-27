import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class CircularParkingIndicators extends StatelessWidget {
  const CircularParkingIndicators({
    Key? key,
    required this.model,
  }) : super(key: key);

  /// MODELS
  final ParkingModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildLocationTitle(context),
        buildLocationContext(context),
        buildSpotsAvailableText(context),
        buildHistoricInfo(context),
        buildAllParkingAvailability(context),
      ],
    );
  }

  Widget buildAllParkingAvailability(BuildContext context) {
    List<Widget> listOfCircularParkingInfo = [];
    List<String> selectedSpots = [];

    Provider.of<ParkingDataProvider>(context)
        .spotTypesState
        .forEach((key, value) {
      if (value && selectedSpots.length < 4) selectedSpots.add(key);
    });
    for (String spot in selectedSpots) {
      listOfCircularParkingInfo.add(buildCircularParkingInfo(
          Provider.of<ParkingDataProvider>(context).spotTypeMap[spot],
          model.availability[spot],
          context));
    }
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: listOfCircularParkingInfo,
      ),
    );
  }

  Widget buildCircularParkingInfo(
      Spot? spotType, dynamic locationData, BuildContext context) {
    int open, total;
    if (locationData != null) {
      open = locationData["Open"] is String
          ? (locationData["Open"] == "" ? 0 : int.parse(locationData["Open"]))
          : (locationData["Open"] ?? 0);

      total = locationData["Total"] is String
          ? (locationData["Total"] == "" ? 0 : int.parse(locationData["Total"]))
          : (locationData["Total"] ?? 0);
    } else {
      open = total = 0;
    }

    return locationData != null
        ? Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 90,
                          width: 90,
                          child: CircularPercentIndicator(
                            radius: 45,
                            animation: true,
                            animationDuration: 1000,
                            lineWidth: 9,
                            percent: (open / total).isNaN ? 0.0 : open / total,
                            center: Text(
                              (open / total).isNaN
                                  ? "N/A"
                                  : ((open / total) * 100).round().toString() +
                                      "%",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: colorFromHex('#EDECEC'),
                            progressColor: getColor(open / total),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: spotType != null
                      ? CircleAvatar(
                          backgroundColor:
                              colorFromHex(spotType.logoBackgroundColor),
                          child: spotType.logoText == 'icon - e486'
                              ? Icon(
                                  IconData(0xe486, fontFamily: 'MaterialIcons'),
                                  size: 25.0,
                                  color: colorFromHex(spotType.logoTextColor))
                              : spotType.logoText == 'icon - e03e'
                                  ? Icon(
                                      IconData(0xe03e, fontFamily: 'MaterialIcons'),
                                      size: 25.0,
                                      color: colorFromHex(spotType.logoTextColor))
                                  : spotType.logoText.startsWith('icon - ')
                                      ? Icon(
                                          IconData(
                                              int.parse(
                                                  spotType.logoText
                                                      .replaceFirst('icon - ', ''),
                                                  radix: 16),
                                          fontFamily: 'MaterialIcons'),
                                          size: 25.0,
                                          color: colorFromHex(spotType.logoTextColor))
                                      : (spotType.logoText.isNotEmpty
                                          ? Text(
                                              spotType.logoText,
                                              style: TextStyle(
                                                color: colorFromHex(
                                                    spotType.logoTextColor),
                                                fontFamily: 'Brix Sans',
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          : Text(
                                              '?',
                                              style: TextStyle(
                                                color: colorFromHex(
                                                    spotType.logoTextColor),
                                                fontFamily: 'Brix Sans',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 28,
                                              ),
                                            )),
                        )
                      : Container(),
                )
              ],
            ),
          )
        : Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 90,
                          width: 90,
                          child: CircularPercentIndicator(
                            radius: 45,
                            animation: false,
                            lineWidth: 9,
                            percent: 0.0,
                            center: Text(
                              "N/A",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            backgroundColor: colorFromHex('#EDECEC'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: spotType != null
                      ? CircleAvatar(
                          backgroundColor:
                              colorFromHex(spotType.logoBackgroundColor),
                          child: spotType.logoText == 'icon - e486'
                              ? Icon(
                                  IconData(0xe486, fontFamily: 'MaterialIcons'),
                                  size: 25.0,
                                  color: colorFromHex(spotType.logoTextColor))
                              : spotType.logoText == 'icon - e03e'
                                  ? Icon(
                                      IconData(0xe03e, fontFamily: 'MaterialIcons'),
                                      size: 25.0,
                                      color: colorFromHex(spotType.logoTextColor))
                                  : spotType.logoText.startsWith('icon - ')
                                      ? Icon(
                                          IconData(
                                              int.parse(
                                                  spotType.logoText
                                                      .replaceFirst('icon - ', ''),
                                                  radix: 16),
                                          fontFamily: 'MaterialIcons'),
                                          size: 25.0,
                                          color: colorFromHex(spotType.logoTextColor))
                                      : (spotType.logoText.isNotEmpty
                                          ? Text(
                                              spotType.logoText,
                                              style: TextStyle(
                                                color: colorFromHex(
                                                    spotType.logoTextColor),
                                                fontFamily: 'Brix Sans',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 28,
                                              ),
                                            )
                                          : Text(
                                              '?',
                                              style: TextStyle(
                                                color: colorFromHex(
                                                    spotType.logoTextColor),
                                                fontFamily: 'Brix Sans',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 28,
                                              ),
                                            )),
                        )
                      : Container(),
                )
              ],
            ),
          );
  }

  static Color getColor(double value) {
    if (value > .75) return Color(0xFF109B00);
    if (value > .25) return Color(0xFFFC8900);
    return Color(0xFFBD1900);
  }

  Widget buildLocationTitle(BuildContext context) {
    return Text(
      model.locationName.toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget buildLocationContext(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(
        model.locationContext.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget buildSpotsAvailableText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Text(
          "~" +
              Provider.of<ParkingDataProvider>(context)
                  .getApproxNumOfOpenSpots(model.locationName)["Open"]
                  .toString() +
              " of " +
              Provider.of<ParkingDataProvider>(context)
                  .getApproxNumOfOpenSpots(model.locationName)["Total"]
                  .toString() +
              " Spots Available",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget buildHistoricInfo(BuildContext context) {
    if (model.locationProvider == "Historic") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.black,
            ),
            SizedBox(
              width: 4,
            ),
            Text("No Live Data. Estimated availability shown.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                    ))
          ],
        ),
      );
    } else {
      return Text("");
    }
  }
}

Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
