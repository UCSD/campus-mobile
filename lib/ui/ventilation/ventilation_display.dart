import 'package:flutter/material.dart';

class VentilationDisplay {
  static List pages = [];

  // builds a list of the pages that include the locations the user chose
  List<Widget> buildPages() {
    List<Widget> ret = [];

    if (pages.length == 0) {
      ret.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Locations to Display",
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Add Locations via 'Manage Locations'",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ],
      ));
    } else {
      for (int i = 0; i < pages.length; i++) {
        ret.add(Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(
                    pages[i]['building'],
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
                    pages[i]['room'],
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
                    pages[i]['floor'],
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
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 15),
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
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 15),
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
    }
    return ret;
  }
}
