import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:flutter/material.dart';

class VentilationDisplay extends StatelessWidget {
  VentilationDisplay({Key? key, required this.model}) : super(key: key);

  final VentilationDataModel? model;
  double fontSize = 10;

  @override
  Widget build(BuildContext context) {
    print(model);

    String windowText = '';
    bool? window = model!.windowsOpen!;
    String hvacText = '';
    bool? hvac = model!.hvacActive!;

    window
        ? windowText = 'Windows are open'
        : windowText = 'Windows are closed';

    hvac ? hvacText = 'HVAC is active' : hvacText = 'HVAC is off';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(
                  model!.buildingName!.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.only(
                  right: 10,
                  left: 16,
                ),
              ),
              Container(
                child: Text(
                  model!.buildingRoomName!.toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey[600], fontSize: 20),
                ),
                padding: EdgeInsets.only(
                  right: 16,
                  left: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Text(
            "${model!.buildingFloorName!} Floor",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.left,
          ),
          padding: EdgeInsets.only(
            left: 16,
          ),
        ),
        SizedBox(
          height: 5,
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

  Widget hi(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [],
        ),
      ],
    );
  }
}
