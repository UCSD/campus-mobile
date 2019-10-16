import 'package:campus_mobile/core/models/parking_model.dart';
import 'package:campus_mobile/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ParkingDisplay extends StatelessWidget {
  const ParkingDisplay({
    Key key,
    @required this.model,
  }) : super(key: key);

  final ParkingModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildLocationTitle(),
        buildLocationContext(),
        buildSpotsAvailableText(),
        buildAllParkingAvailabilty(),
      ],
    );
  }

  Widget buildAllParkingAvailabilty() {
    List<Widget> listOfCircularParkingInfo = List<Widget>();
    listOfCircularParkingInfo
        .add(buildCircularParkingInfo(model.availability.a));
    listOfCircularParkingInfo
        .add(buildCircularParkingInfo(model.availability.b));
    listOfCircularParkingInfo
        .add(buildCircularParkingInfo(model.availability.s));
    listOfCircularParkingInfo
        .add(buildCircularParkingInfo(model.availability.accessible));
    listOfCircularParkingInfo
        .add(buildCircularParkingInfo(model.availability.v));
    return Row(
      children: listOfCircularParkingInfo,
    );
  }

  Widget buildCircularParkingInfo(SpotType spot) {
    return spot != null
        ? Expanded(
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (spot.open / spot.total),
                      valueColor: AlwaysStoppedAnimation<Color>(ColorPrimary),
                    ),
                    Center(
                      child: Text(
                          ((spot.open / spot.total) * 100).round().toString() +
                              "%"),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: spot.color,
                  child: spot.type,
                )
              ],
            ),
          )
        : Container();
  }

  Widget buildLocationContext() {
    return Center(
      child: Text(model.locationContext),
    );
  }

  Widget buildLocationTitle() {
    return Text(model.locationName);
  }

  Widget buildSpotsAvailableText() {
    return Center(
      child: Text("~" +
          model.availability.totalSpotsOpen.toString() +
          " Spots Available"),
    );
  }
}
