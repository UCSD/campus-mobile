import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:get/get.dart';

class CircularParkingIndicators extends StatelessWidget {
  CircularParkingIndicators({
    Key? key,
    required this.model,
  }) : super(key: key);

  final ParkingModel model;
  final ParkingGetX parkingController = Get.find();

  @override
  Widget build(BuildContext context) {
    // Build the circular parking indicators widget
    return Column(
      children: [
        // Title of the parking location
        buildLocationTitle(),
        // Context of the parking location
        buildLocationContext(context),
        // Text showing spots available
        buildSpotsAvailableText(context),
        // Additional information for historic data
        buildHistoricInfo(),
        // Circular indicators for each spot type
        buildAllParkingAvailability(context),
      ],
    );
  }

  // Build circular indicators for each spot type
  Widget buildAllParkingAvailability(BuildContext context) {
    List<Widget> listOfCircularParkingInfo = [];
    List<String> selectedSpots = [];

    parkingController.selectedSpotTypesState!.forEach((key, value) {
      if (value && selectedSpots.length < 4) {
        selectedSpots.add(key!);
      }
    });
    for (String spot in selectedSpots) {
      if (model.availability != null) {
        listOfCircularParkingInfo.add(buildCircularParkingInfo(
            parkingController.spotTypeMap![spot],
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

  // Build circular parking indicator for a specific spot type
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
                            radius: 37,
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
                            radius: 37,
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

  // Convert hex color code to Color object
  Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor =
          'FF' + hexColor; // FF as the opacity value if you don't add it.
    }
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // Determine color based on availability percentage
  Color getColor(double value) {
    if (value > .75) {
      return Colors.green;
    }
    if (value > .25) {
      return Colors.yellow;
    }
    return Colors.red;
  }

  // Build context of the parking location
  Widget buildLocationContext(BuildContext context) {
    return Center(
      child: Text(model.locationContext ?? "",
          style: TextStyle(
            color: Colors.grey,
          )),
    );
  }

  // Build title of the parking location
  Widget buildLocationTitle() {
    return Text(
      model.locationName ?? "",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  // Build additional information for historic data
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

  // Build text showing spots available
  Widget buildSpotsAvailableText(BuildContext context) {
    return Center(
      child: Text("~" +
          parkingController
              .getApproxNumOfOpenSpots(model.locationName)["Open"]
              .toString() +
          " of " +
          parkingController
              .getApproxNumOfOpenSpots(model.locationName)["Total"]
              .toString() +
          " Spots Available"),
    );
  }
}
