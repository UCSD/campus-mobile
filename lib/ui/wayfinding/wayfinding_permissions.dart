import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedWayfindingPermission extends StatefulWidget {
  @override
  _AdvancedWayfindingPermissionState createState() =>
      _AdvancedWayfindingPermissionState();
}


class _AdvancedWayfindingPermissionState
    extends State<AdvancedWayfindingPermission> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          primary: true,
          centerTitle: true,
          title: Text("Advanced Wayfinding"),
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
        children: <Widget>[
          toggleSwitch(context),
          Center(
            child: Container(
              width: 300.0,
              child: Text(
                "Advanced wayfinding benefits\n\u2022 Getting directions\n\u2022 Locate areas of interest on campus\n\u2022 Context aware communication with other Bluetooth devices"
              )
            ),
          ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Text(
          //       "Advanced wayfinding benefits",
          //       style: TextStyle(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //       ),
          //       textAlign: TextAlign.left,
          //     ),
          //   ),
          // ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
          //     child: Text(
          //       "\u2022 Getting directions",
          //       style: TextStyle(
          //         fontSize: 17,
          //       ),
          //       textAlign: TextAlign.left,
          //     ),
          //   ),
          // ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          //     child: Text(
          //       "\u2022 Locate areas of interest on campus",
          //       style: TextStyle(
          //         fontSize: 17,
          //       ),
          //       textAlign: TextAlign.left,
          //     ),
          //   ),
          // ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          //     child: Text(
          //       "\u2022 Context aware communication with other Bluetooth devices",
          //       style: TextStyle(
          //         fontSize: 17,
          //       ),
          //       textAlign: TextAlign.left,
          //     ),
          //   ),
          // )
        ]
    );
  }


  Widget toggleSwitch(BuildContext context) {
    return Text(" ");
    // return Row(
    //   children: <Widget>[
    //     Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Text(
    //         "Enable advanced wayfinding",
    //         style: TextStyle(fontSize: 17),
    //       ),
    //     ),
    //     Expanded(child: SizedBox()),
    //     StreamBuilder(
    //       stream: FlutterBlue.instance.state,
    //       builder: (context, snapshot) {
    //         if (snapshot.hasData) {
    //           return Switch(
    //             value: bluetoothStarted(context, snapshot),
    //             onChanged: (permissionGranted) {
    //               startBluetooth(context, permissionGranted);
    //               bool forceOff = false;
    //               if (((snapshot.data as BluetoothState ==
    //                   BluetoothState.unauthorized) ||
    //                   (snapshot.data as BluetoothState ==
    //                       BluetoothState.off)) &&
    //                   permissionGranted) {
    //                 forceOff = true;
    //                 showDialog(
    //                     context: context,
    //                     barrierDismissible: false,
    //                     builder: (BuildContext context) {
    //                       if (Platform.isIOS) {
    //                         return CupertinoAlertDialog(
    //                           title: Text(
    //                               "UCSD Mobile would like to use Bluetooth."),
    //                           content: Text(
    //                               "This feature use Bluetooth to connect with other devices."),
    //                           actions: <Widget>[
    //                             FlatButton(
    //                               child: Text('Cancel'),
    //                               onPressed: () {
    //                                 Navigator.of(context).pop();
    //                               },
    //                             ),
    //                             FlatButton(
    //                               child: Text('Settings'),
    //                               onPressed: () {
    //                                 AppSettings.openAppSettings();
    //                               },
    //                             )
    //                           ],
    //                         );
    //                       }
    //                       return AlertDialog(
    //                         title: Text(
    //                             "UCSD Mobile would like to use Bluetooth."),
    //                         content: Text(
    //                             "This feature use Bluetooth to connect with other devices."),
    //                         actions: <Widget>[
    //                           FlatButton(
    //                             child: Text('Cancel'),
    //                             onPressed: () {
    //                               Navigator.of(context).pop();
    //                             },
    //                           ),
    //                           FlatButton(
    //                             child: Text('Settings'),
    //                             onPressed: () {
    //                               AppSettings.openAppSettings();
    //                             },
    //                           )
    //                         ],
    //                       );
    //                     });
    //               }
    //               setState(() {
    //                 if (forceOff) {
    //                   _bluetoothSingleton.advancedWayfindingEnabled = false;
    //                 } else {
    //                   _bluetoothSingleton.advancedWayfindingEnabled =
    //                   !_bluetoothSingleton.advancedWayfindingEnabled;
    //                 }
    //
    //                 if (!_bluetoothSingleton.advancedWayfindingEnabled) {
    //                   _bluetoothSingleton.stopScans();
    //                 }
    //                 SharedPreferences.getInstance().then((value) {
    //                   value.setBool("advancedWayfindingEnabled",
    //                       _bluetoothSingleton.advancedWayfindingEnabled);
    //                 });
    //               });
    //             },
    //             activeColor: Theme.of(context).buttonColor,
    //           );
    //         } else {
    //           return CircularProgressIndicator();
    //         }
    //       },
    //     ),
    //   ],
    // );
  }
}