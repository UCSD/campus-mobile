import 'dart:async';

import 'package:campus_mobile_experimental/core/providers/wayfinding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AutomaticBluetoothLoggerView extends StatefulWidget {
  // Instantiate bluetooth singleton
  final WayfindingProvider bluetoothSingleton =
      WayfindingProvider();

  @override
  State<StatefulWidget> createState() =>
      _AutomaticBluetoothLoggerViewState(bluetoothSingleton);
}

class _AutomaticBluetoothLoggerViewState
    extends State<AutomaticBluetoothLoggerView> {
  // Instances of the singleton and its listener
  WayfindingProvider bluetoothSingleton;
  StreamSubscription subscription;

  // List for rendering the ongoing log
  List loggedItems = [];

  _AutomaticBluetoothLoggerViewState(WayfindingProvider bluetoothScan);

  // Set the state when a new scan occurs
  void initState() {
    bluetoothSingleton = widget.bluetoothSingleton;
    super.initState();
    if (bluetoothSingleton.loggedItems.length > 0) {
      Timer.periodic(Duration(seconds: 3), (timer) {
        setState(() {
          loggedItems = bluetoothSingleton.loggedItems;
          build(context);
        });
      });
    }
    subscription = bluetoothSingleton.flutterBlueInstance.scanResults
        .listen((event) async {
      setState(() {
        loggedItems = bluetoothSingleton.loggedItems;
      });
    });
  }

  // build Card container to hold log display
  @override
  Widget build(BuildContext context) {
    //Start dynamic resizing
    MediaQueryData queryData = MediaQuery.of(context);
    double verticalSafeBlock = (queryData.size.height -
            (queryData.padding.top + queryData.padding.bottom)) /
        100;
    double cardHeight = verticalSafeBlock * 85;

    return Scaffold(
      appBar: AppBar(
        title: Text("Automatic Bluetooth Logger"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Devices Scanned",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: Container(
                        height: cardHeight,
                        child: ListView.builder(
                            itemCount: loggedItems.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return buildText(index);
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bold location and timestamp to differentiate scans
  Text buildText(int index) {
    if (loggedItems[index].toString().contains("LATITUDE") ||
        loggedItems[index].toString().contains("TIMESTAMP")) {
      return Text(
        loggedItems[index],
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }

    // Return normal text for device display
    return Text(loggedItems[index]);
  }

  // Detach the listener to avoid calling setState()
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
