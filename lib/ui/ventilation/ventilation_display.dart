import 'package:flutter/material.dart';

class VentilationDisplay extends StatelessWidget {
  static Map args = {};
  static int numPages = 1;

  // builds a list of the pages that include the locations the user chose
  List<Widget> buildPages() {
    String building = "Bonner Hall";
    String floor = '10th Floor';
    String room = 'Room 222';
    List<Widget> ret = [];

    if (args.length != 0) {
      building = args['building'];
      floor = args['floor'];
      room = args['room'];
    }

    print("-------------------------------");
    print("VENTILATION DISPLAY ARGS: $args");
    print("-------------------------------");

    for (int i = 0; i < numPages; i++) {
      ret.add(Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(
                  building,
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
                  room,
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
                  floor,
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
                          'Currently 74°',
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
                          'Windows are closed',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 15),
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
                          'HVAC is active',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 15),
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
      ));
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) => Column();
}
