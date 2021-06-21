import 'dart:async';
import 'dart:io';

import 'package:campus_mobile_experimental/core/providers/wayfinding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:provider/provider.dart';

import '../../app_styles.dart';

class AutomaticBluetoothLoggerView extends StatefulWidget {
  // Instantiate bluetooth singleton

  @override
  State<StatefulWidget> createState() => _AutomaticBluetoothLoggerViewState();
}

class _AutomaticBluetoothLoggerViewState
    extends State<AutomaticBluetoothLoggerView> {
  WayfindingProvider _wayfindingProvider = WayfindingProvider();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _wayfindingProvider = Provider.of<WayfindingProvider>(context);
  }

  // List for rendering the ongoing log
  List loggedItems = [];

   _AutomaticBluetoothLoggerViewState();

  // // Set the state when a new scan occurs
  // void initState() {
  //   bluetoothSingleton = widget.bluetoothSingleton;
  //   super.initState();
  //   if (bluetoothSingleton.loggedItems.length > 0) {
  //     Timer.periodic(Duration(seconds: 3), (timer) {
  //       setState(() {
  //         loggedItems = bluetoothSingleton.loggedItems;
  //         build(context);
  //       });
  //     });
  //   }
  //   subscription = bluetoothSingleton.flutterBlueInstance.scanResults
  //       .listen((event) async {
  //     setState(() {
  //       loggedItems = bluetoothSingleton.loggedItems;
  //     });
  //   });
  // }

  // build Card container to hold log display
  @override
  Widget build(BuildContext context) {
    _wayfindingProvider = Provider.of<WayfindingProvider>(context);

    // //Start dynamic resizing
    // MediaQueryData queryData = MediaQuery.of(context);
    // double verticalSafeBlock = (queryData.size.height -
    //         (queryData.padding.top + queryData.padding.bottom)) /
    //     100;
    // double cardHeight = verticalSafeBlock * 85;

    return Scaffold(
      appBar: AppBar(
        title: Text("AW Developer View"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[statusCard(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                 height: cardContentMaxHeight,
                child: ListView.builder(
                    itemCount: _wayfindingProvider.processedDevices.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return buildText(index);
                          }),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }


  // // Return normal text for device display
  // return Text(loggedItems[index]);

  Card statusCard() {
    return Card(

      color: _wayfindingProvider.ongoingScanner != null ? Colors.green : Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              _wayfindingProvider.ongoingScanner == null
                  ? Text(
                      "Not scanning...",
                      style: Theme.of(context).textTheme.headline5,
                    )
                  : Text(
                      "Scanning...",
                      style: Theme.of(context).textTheme.headline5,
                    ),
              FutureBuilder<Text>(
                  future: checkPermissions(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Text> snapshot) {
                     return  snapshot.hasData ? snapshot.data as Widget : LinearProgressIndicator();
                      }),
            ],
          ),
        ),
      ),
    );
  }

  Future<Text> checkPermissions() async {
    BluetoothState bluetoothStatus =
        await _wayfindingProvider.flutterBlueInstance.state.first;
    PermissionStatus locationStatus =
        await _wayfindingProvider.checkLocationPermission();
    bool locationService = await _wayfindingProvider.checkLocationService();

    return Text(
        "OS: ${Platform.isIOS ? "iOS" : "Android"} \nLocation: ${locationStatus.toString()} \nService enabled: $locationService \nBluetooth: ${bluetoothStatus.toString()} \nAW Enabled: ${_wayfindingProvider.advancedWayfindingEnabled} \nForce off: ${_wayfindingProvider.forceOff}");
  }
  // // Bold location and timestamp to differentiate scans
  Text buildText(int index) {
    if (_wayfindingProvider.processedDevices[index].toString().contains("LATITUDE") ||
        _wayfindingProvider.processedDevices[index].toString().contains("TIMESTAMP")) {
      return Text(
        _wayfindingProvider.processedDevices[index],
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
    return Text(_wayfindingProvider.processedDevices[index].toString() + '\n');
  }

}

//
//   // Detach the listener to avoid calling setState()
//   @override
//   void dispose() {
//     subscription.cancel();
//     super.dispose();
//   }
// }
// Row(
//   children: <Widget>[
//     Expanded(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             "Devices Scanned",
//             style:
//                 TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Card(
//             child: Container(
//               height: cardHeight,
//               child: ListView.builder(
//                   itemCount: loggedItems.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     return buildText(index);
//                   }),
//             ),
//           ),
//         ],
//       ),
//     ),
//   ],
// ),
