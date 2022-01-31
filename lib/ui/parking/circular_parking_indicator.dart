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

  final ParkingModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildLocationTitle(),
        buildLocationContext(context),
        buildSpotsAvailableText(context),
        buildHistoricInfo(),
        buildAllParkingAvailability(context),
      ],
    );
  }

  Widget buildAllParkingAvailability(BuildContext context) {
    List<Widget> listOfCircularParkingInfo = [];

    List<String> selectedSpots = [];

    Provider.of<ParkingDataProvider>(context)
        .spotTypesState!
        .forEach((key, value) {
      if (value && selectedSpots.length < 4) {
        selectedSpots.add(key!);
      }
    });
    for (String spot in selectedSpots) {
      if (model.availability != null) {
        listOfCircularParkingInfo.add(buildCircularParkingInfo(
            Provider.of<ParkingDataProvider>(context).spotTypeMap![spot],
            model.availability![spot],
            context));
      }
    }
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: listOfCircularParkingInfo,
      ),
    );
  }

  Widget buildCircularParkingInfo(
      Spot? spotType, dynamic locationData, BuildContext context) {
    int open;
    int total;
    if (locationData != null) {
      if (locationData["Open"] is String) {
        open = locationData["Open"] == "" ? 0 : int.parse(locationData["Open"]);
      } else {
        open = locationData["Open"] == null ? 0 : locationData["Open"];
      }
      if (locationData["Total"] is String) {
        total =
            locationData["Total"] == "" ? 0 : int.parse(locationData["Total"]);
      } else {
        total = locationData["Total"] == null ? 0 : locationData["Total"];
      }
    } else {
      open = 0;
      total = 0;
    }

    return locationData != null
        ? Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 75,
                          width: 75,
                          child: CircularPercentIndicator(
                            radius: 75,
                            animation: true,
                            animationDuration: 1000,
                            lineWidth: 7.5,
                            percent: open / total,
                            center: Text(
                                ((open / total) * 100).round().toString() + "%",
                                style: TextStyle(fontSize: 22)),
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
                  padding: EdgeInsets.all(8.0),
                  child: spotType != null
                      ? CircleAvatar(
                          backgroundColor: colorFromHex(spotType.color!),
                          child: spotType.text!.contains("&#x267f;")
                              ? Icon(
                                  Icons.accessible,
                                  size: 25.0,
                                  color: colorFromHex(spotType.textColor!),
                                )
                              : Text(
                                  spotType.spotKey!.contains("SR")
                                      ? "RS"
                                      : spotType.text!,
                                  style: TextStyle(
                                    color: colorFromHex(spotType.textColor!),
                                  ),
                                ),
                        )
                      : Container(),
                )
              ],
            ),
          )
        : Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 75,
                          width: 75,
                          child: CircularPercentIndicator(
                            radius: 75,
                            animation: false,
                            lineWidth: 7.5,
                            percent: 0.0,
                            center: Text("N/A", style: TextStyle(fontSize: 22)),
                            backgroundColor: colorFromHex('#EDECEC'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: spotType != null
                      ? CircleAvatar(
                          backgroundColor: colorFromHex(spotType.color!),
                          child: spotType.text!.contains("&#x267f;")
                              ? Icon(Icons.accessible,
                                  size: 25.0,
                                  color: colorFromHex(spotType.textColor!))
                              : Text(
                                  spotType.spotKey!.contains("SR")
                                      ? "RS"
                                      : spotType.text!,
                                  style: TextStyle(
                                    color: colorFromHex(spotType.textColor!),
                                  ),
                                ),
                        )
                      : Container(),
                )
              ],
            ),
          );
  }

  Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor =
          'FF' + hexColor; // FF as the opacity value if you don't add it.
    }
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Color getColor(double value) {
    if (value > .75) {
      return Colors.green;
    }
    if (value > .25) {
      return Colors.yellow;
    }
    return Colors.red;
  }

  Widget buildLocationContext(BuildContext context) {
    return Center(
      child: Text(model.locationContext ?? "",
          style: TextStyle(
            color: Colors.grey,
          )),
    );
  }

  Widget buildLocationTitle() {
    return Text(
      model.locationName ?? "",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget buildHistoricInfo() {
    if (model.locationProvider == "Historic") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.only(right: 1.0),
          ),
          Text(
            "No Live Data. Estimated availability shown.",
          )
        ],
      );
    } else {
      return Text("");
    }
  }

  Widget buildSpotsAvailableText(BuildContext context) {
    return Center(
      child: Text("~" +
          Provider.of<ParkingDataProvider>(context)
              .getApproxNumOfOpenSpots(model.locationName)["Open"]
              .toString() +
          " of " +
          Provider.of<ParkingDataProvider>(context)
              .getApproxNumOfOpenSpots(model.locationName)["Total"]
              .toString() +
          " Spots Available"),
    );
  }
}
