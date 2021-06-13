import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:flutter/material.dart';
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
      if (value) {
        selectedSpots.add(key!);
      }
    });
    for (String spot in selectedSpots) {
      if (model.availability != null && model.availability![spot] != null) {
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
    print("spot and location data");
    print(locationData);
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
                        child: CircularProgressIndicator(
                          value: (int.parse(locationData['Open']) /
                              int.parse(locationData['Total'])),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(ColorPrimary),
                        ),
                      ),
                      Center(
                        child: Text(((int.parse(locationData['Open']) /
                                        int.parse(locationData['Total'])) *
                                    100)
                                .round()
                                .toString() +
                            "%"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: spotType != null ? CircleAvatar(
                    backgroundColor: colorFromHex(spotType.color!),
                    child: Text(spotType.spotKey!),
                  ) : Container(),
                )
              ],
            ),
          )
        : Container();
  }

  Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor =
          'FF' + hexColor; // FF as the opacity value if you don't add it.
    }
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Widget buildLocationContext(BuildContext context) {
    return Center(
      child: Text(model.locationContext ?? ""),
    );
  }

  Widget buildLocationTitle() {
    return Text(model.locationName ?? "");
  }

  Widget buildSpotsAvailableText(BuildContext context) {
    return Center(
      child: Text("~" +
          Provider.of<ParkingDataProvider>(context)
              .getApproxNumOfOpenSpots(model.locationId)
              .toString() +
          " Spots Available"),
    );
  }
}
