import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:flutter/material.dart';

class VentilationDisplay extends StatelessWidget {
  VentilationDisplay({Key? key, required this.model}) : super(key: key);
  final VentilationDataModel? model;
  // static List pages = [];

  @override
  Widget build(BuildContext context) {
    String windowText = '';
    bool? window = model!.windowsOpen!;
    String hvacText = '';
    bool? hvac = model!.hvacActive!;
    window
        ? windowText = 'Windows are open'
        : windowText = 'Windows are closed';
    hvac ? hvacText = 'HVAC is active' : hvacText = 'HVAC is off';
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      model!.buildingName!.toString(),
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.grey[600], fontSize: 20),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      model!.buildingRoomName!.toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.grey[600], fontSize: 20),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: Text(
                      "${model!.buildingFloorName!.toString()} Floor",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Currently ${model!.currentTemperature!}°',
                        style: TextStyle(color: Colors.black, fontSize: 36),
                        textAlign: TextAlign.center,
                      ),
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.window),
                    Container(
                      child: Text(
                        windowText,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.air),
                    Container(
                      child: Text(
                        hvacText,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
