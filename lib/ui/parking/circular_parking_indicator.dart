import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_constants.dart';

class CircularParkingIndicators extends StatelessWidget {
  const CircularParkingIndicators({Key? key, required this.model}) : super(key: key);

  static const double baseGaugeSize = 90;
  static const double gaugeHorizontalPadding = 16;
  static const double phoneBodyReferenceHeight = 320;
  static const double minScale = 0.5;
  static const double maxScale = 2.5;

  /// MODELS
  final ParkingModel model;

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingDataProvider>(context);
    final selectedSpots = <String>[];
    parkingProvider.spotTypesState.forEach((key, value) {
      if (value && selectedSpots.length < 4) selectedSpots.add(key);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = computeScale(
          constraints.maxWidth,
          selectedSpots.length,
          allowGrowth: MediaQuery.of(context).size.width > 600,
        );
        return Column(
          children: [
            buildLocationTitle(context, scale),
            buildLocationContext(context, scale),
            buildSpotsAvailableText(context, scale),
            buildAllParkingAvailability(context, parkingProvider, selectedSpots, scale),
          ],
        );
      },
    );
  }

  Widget buildAllParkingAvailability(
    BuildContext context,
    ParkingDataProvider parkingProvider,
    List<String> selectedSpots,
    double scale,
  ) {
    return Expanded(
      child: Column(
        children: [
          buildHistoricInfo(context, scale),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (String spot in selectedSpots)
                  buildCircularParkingInfo(parkingProvider.spotTypeMap[spot], model.availability[spot], context, scale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Phones stay at or below the 90px baseline; tablets grow until one gauge
  /// cell runs out of width. The 600px gate matches CardContainer's tablet
  /// body so one breakpoint decides both.
  static double computeScale(double maxWidth, int spotCount, {required bool allowGrowth}) {
    if (spotCount <= 0) return 1.0;
    final widthScale = (maxWidth / spotCount) / (baseGaugeSize + 2 * gaugeHorizontalPadding);
    if (!allowGrowth) return widthScale.clamp(minScale, 1.0).toDouble();
    return widthScale.clamp(1.0, maxScale).toDouble();
  }

  static double computeEmptyStateScale(BoxConstraints constraints) =>
      (constraints.maxHeight / phoneBodyReferenceHeight).clamp(1.0, maxScale).toDouble();

  Widget buildCircularParkingInfo(Spot? spotType, dynamic locationData, BuildContext context, double scale) {
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

    final availability = open / total;
    return buildGauge(
      context: context,
      spotType: spotType,
      open: open,
      total: total,
      scale: scale,
      animate: locationData != null,
      semanticLabel: locationData != null
          ? 'For ${spotType?.name ?? "Unknown"} parking spots, ${(availability.isNaN ? "Not applicable" : (availability * 100).round().toString() + "% available")}'
          : 'For ${spotType?.name ?? "Unknown"} parking, Not applicable',
    );
  }

  Widget buildGauge({
    required BuildContext context,
    required Spot? spotType,
    required int open,
    required int total,
    required double scale,
    required bool animate,
    required String semanticLabel,
  }) {
    final availability = open / total;
    final percentStyle = Theme.of(context).textTheme.titleMedium;
    return Expanded(
      child: Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: ClipRect(
          child: Column(
            mainAxisAlignment: scale > 1.0 ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gaugeHorizontalPadding * scale),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: baseGaugeSize * scale,
                        width: baseGaugeSize * scale,
                        child: CircularPercentIndicator(
                          radius: baseGaugeSize / 2 * scale,
                          animation: animate,
                          animationDuration: 1000,
                          lineWidth: baseGaugeSize / 10 * scale,
                          percent: availability.isNaN ? 0.0 : availability,
                          center: Text(
                            availability.isNaN ? "N/A" : (availability * 100).round().toString() + "%",
                            style: percentStyle?.copyWith(fontSize: (percentStyle.fontSize ?? 16) * scale),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: colorFromHex('#EDECEC'),
                          progressColor: getColor(availability),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0 * scale),
                child: spotType != null
                    ? CircleAvatar(
                        radius: 20 * scale,
                        backgroundColor: colorFromHex(spotType.logoBackgroundColor),
                        child: spotType.logoText.startsWith('icon - ')
                            ? Icon(
                                ParkingConstants.STRING_TO_ICON_DATA[spotType.logoText] ?? Icons.error,
                                size: 25.0 * scale,
                                color: colorFromHex(spotType.logoTextColor),
                              )
                            : (spotType.logoText.isNotEmpty
                                  ? Text(
                                      spotType.logoText,
                                      style: TextStyle(
                                        color: colorFromHex(spotType.logoTextColor),
                                        fontFamily: 'Brix Sans',
                                        fontSize: 28 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : SizedBox.shrink()),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color getColor(double value) {
    if (value > .75) return Color(0xFF109B00);
    if (value > .25) return Color(0xFFFC8900);
    return Color(0xFFBD1900);
  }

  Widget buildLocationTitle(BuildContext context, double scale) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal);
    return Semantics(
      label: 'Parking Name: ${model.locationName.toUpperCase()}',
      excludeSemantics: true,
      child: Text(model.locationName.toUpperCase(), style: style?.copyWith(fontSize: (style.fontSize ?? 16) * scale)),
    );
  }

  Widget buildLocationContext(BuildContext context, double scale) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Padding(
      padding: EdgeInsets.only(top: 6.0 * scale),
      child: Text(
        model.locationContext.toUpperCase(),
        semanticsLabel: 'Located at: ${model.locationContext}',
        style: style?.copyWith(fontSize: (style.fontSize ?? 14) * scale),
      ),
    );
  }

  Widget buildSpotsAvailableText(BuildContext context, double scale) {
    final openSpots = Provider.of<ParkingDataProvider>(
      context,
    ).getApproxNumOfOpenSpots(model.locationName)["Open"].toString();
    final totalSpots = Provider.of<ParkingDataProvider>(
      context,
    ).getApproxNumOfOpenSpots(model.locationName)["Total"].toString();
    final visualText = "~$openSpots of $totalSpots Spots Available";
    final semanticText = "Approximately $openSpots of $totalSpots Spots Available";
    final style = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: EdgeInsets.only(top: 8.0 * scale),
      child: Center(
        child: Text(
          visualText,
          semanticsLabel: semanticText,
          style: style?.copyWith(fontSize: (style.fontSize ?? 14) * scale),
        ),
      ),
    );
  }

  Widget buildHistoricInfo(BuildContext context, double scale) {
    if (model.locationProvider == "Historic") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.black, size: 24 * scale),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                "No Live Data. Estimated availability shown.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16 * scale),
              ),
            ),
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
