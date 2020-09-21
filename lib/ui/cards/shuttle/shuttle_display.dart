import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/shuttle_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop_model.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ShuttleDisplay extends StatelessWidget {
  ShuttleDisplay({
    Key key,
    @required this.stop,
    this.arrivingShuttles
  }): super(key: key);

  final ShuttleStopModel stop;
  final List<ArrivingShuttle> arrivingShuttles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Stop: ${stop.id} - ${stop.name}"),
        Text(arrivingShuttles != null ? getArrivingShuttles() : "no arriving shuttle")
      ],
    );
  }

  String getArrivingShuttles() {
    String str = "";
    arrivingShuttles.forEach((element) {
      str += "Bus: ${element.vehicle.id} - ${element.vehicle.name}\n";
    });
    return str;
  }
}
