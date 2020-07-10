import 'dart:async';

import 'package:flutter/material.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeaconView extends StatefulWidget {
  @override
  _BeaconViewState createState() => _BeaconViewState();
}

class _BeaconViewState extends State<BeaconView> {

  var _isTransmissionSupported;
  var _isAdvertising;
  String broadcastingState = "Currently not broadcasting";
  BeaconBroadcast beaconBroadcast;
  var beaconUuid = 'null';
  Duration uuidDuration;
  var uuidTimer;

  @override
  void initState () {
    super.initState();
    print("Enter beacon");

    checkTime();
    beaconBroadcast = BeaconBroadcast();
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
    
    //uuidTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => changeUUID());
  }

  @override
  void dispose() async {
    super.dispose();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uuid', beaconUuid);
    //uuidTimer.cancel();
    print("Exit beacon");
  }

  void checkTime () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    beaconUuid = prefs.get('uuid') ?? "null";
    var previousTime =  prefs.get('previousTime') ?? DateTime(1990).toString();
    var difference = DateTime.now().difference(DateTime.parse(previousTime)).inSeconds;
    print(difference);
    if (difference > 10) {
      beaconUuid = Uuid().v4();
      prefs.setString('previousTime', DateTime.now().toString());
    }

  }

  void startBroadcast () {
    //start beacon broadcasting
    //if (isBroadcasting)
    //  return;

    beaconBroadcast
        .setUUID(beaconUuid)
        .setMajorId(1)
        .setMinorId(100)
        .setIdentifier('com.example.myDevice')
        .setLayout(BeaconBroadcast.ALTBEACON_LAYOUT)
        .start();

    print(beaconUuid);
    setState(() {
      broadcastingState = "Currently broadcasting";
    });
  }

  void stopBroadcast () {
    // stop beacon broadcasting
    //if (!isBroadcasting)
    //  return;

    beaconBroadcast.stop();
    setState(() {
      broadcastingState = "Currently not broadcasting";
      beaconUuid = "null";
    });
  }

  void changeUUID () {
    beaconUuid = Uuid().v4();
    print(beaconUuid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold (
      appBar: AppBar (
        title: Text ("Bluetooth Beacon Broadcasting"),
      ),

      body: Column (
        children: <Widget>[
          Row (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton (
                onPressed: startBroadcast,
                child: Text ("Start Broadcasting",
                  style: TextStyle (color: Colors.white),
                ),
              ),
              RaisedButton (
                onPressed: stopBroadcast,
                child: Text ("Stop Broadcasting",
                  style: TextStyle (color: Colors.white),
                ),
              ),
            ],
          ),
          Text ("Is transmission supported?"),
          Text ("$_isTransmissionSupported"),
          Text ("Is beacon broadcasting?"),
          Text ("$_isAdvertising"),
          Text ("Broadcasting UUID"),
          Text (beaconUuid),
        ],
      ),
    );
  }
}
