import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:flutter/material.dart';

class VentilationDisplay extends StatelessWidget {
  VentilationDisplay({Key? key, required this.model}) : super(key: key);

  final VentilationDataModel? model;
  // static List pages = [];

  @override
  Widget build(BuildContext context) {
    print(model);

    String windowText = '';
    bool? window = model!.windowsOpen;
    String hvacText = '';
    bool? hvac = model!.hvacActive;

    if (window != null) {
      window
          ? windowText = 'Windows are open'
          : windowText = 'Windows are closed';
    }

    if (hvac != null) {
      hvac ? hvacText = 'HVAC is active' : hvacText = 'HVAC is off';
    }

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                model!.buildingName.toString(),
                style: TextStyle(color: Colors.grey[600], fontSize: 20),
                textAlign: TextAlign.left,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
            ),
            Container(
              child: Text(
                model!.buildingRoomName.toString(),
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey[600], fontSize: 20),
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              child: Text(
                model!.buildingFloorName.toString(),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Currently ${model!.currentTemperature}°',
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

  // // builds a list of the pages that include the locations the user chose
  // List<Widget> buildPages() {
  //   List<Widget> ret = [];
  //
  //   if (pages.length == 0) {
  //     ret.add(Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           "No Locations to Display",
  //           style: TextStyle(color: Colors.black, fontSize: 24),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.only(top: 5),
  //           child: Text(
  //             "Add Locations via 'Manage Locations'",
  //             style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
  //           ),
  //         ),
  //       ],
  //     ));
  //   } else {
  //     for (int i = 0; i < pages.length; i++) {
  //       ret.add(Column(
  //         children: <Widget>[
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: <Widget>[
  //               Container(
  //                 child: Text(
  //                   pages[i]['building'],
  //                   style: TextStyle(color: Colors.grey[600], fontSize: 20),
  //                   textAlign: TextAlign.left,
  //                 ),
  //                 padding: EdgeInsets.only(
  //                   left: 10,
  //                   right: 10,
  //                 ),
  //               ),
  //               Container(
  //                 child: Text(
  //                   pages[i]['room'],
  //                   textAlign: TextAlign.right,
  //                   style: TextStyle(color: Colors.grey[600], fontSize: 20),
  //                 ),
  //                 padding: EdgeInsets.only(
  //                   left: 10,
  //                   right: 10,
  //                 ),
  //               )
  //             ],
  //           ),
  //           Row(
  //             children: <Widget>[
  //               Container(
  //                 child: Text(
  //                   pages[i]['floor'],
  //                   style: TextStyle(color: Colors.grey[600], fontSize: 15),
  //                   textAlign: TextAlign.left,
  //                 ),
  //                 padding: EdgeInsets.only(
  //                   left: 10,
  //                   right: 10,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               Column(
  //                 children: <Widget>[
  //                   Row(
  //                     children: <Widget>[
  //                       Container(
  //                         child: Text(
  //                           'Currently 74°',
  //                           style: TextStyle(color: Colors.black, fontSize: 36),
  //                           textAlign: TextAlign.center,
  //                         ),
  //                         padding: EdgeInsets.only(
  //                           left: 10,
  //                           right: 10,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: <Widget>[
  //                       Icon(Icons.window),
  //                       Container(
  //                         child: Text(
  //                           'Windows are closed',
  //                           style: TextStyle(
  //                               color: Colors.grey[600], fontSize: 15),
  //                           textAlign: TextAlign.left,
  //                         ),
  //                         padding: EdgeInsets.only(
  //                           left: 10,
  //                           right: 10,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: <Widget>[
  //                       Icon(Icons.air),
  //                       Container(
  //                         child: Text(
  //                           'HVAC is active',
  //                           style: TextStyle(
  //                               color: Colors.grey[600], fontSize: 15),
  //                           textAlign: TextAlign.left,
  //                         ),
  //                         padding: EdgeInsets.only(
  //                           left: 10,
  //                           right: 10,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       ));
  //     }
  //   }
  //   return ret;
  // }
}
