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
  var _isAdvertising = false;
  var _isAdvertisingSubscription;
  BeaconBroadcast beaconBroadcast;
  var beaconUuid = 'null';

  @override
  void initState() {
    super.initState();

    checkTime();
    beaconBroadcast = BeaconBroadcast();
    beaconBroadcast
        .checkTransmissionSupported()
        .then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uuid', beaconUuid);
    _isAdvertisingSubscription.cancel();
    beaconBroadcast.stop();
  }

  void checkTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    beaconUuid = prefs.get('uuid') ?? "null";
    var previousTime = prefs.get('previousTime') ?? DateTime(1990).toString();
    var difference =
        DateTime.now().difference(DateTime.parse(previousTime)).inSeconds;
    print(difference);
    if (difference > 10) {
      changeUUID();
      prefs.setString('previousTime', DateTime.now().toString());
    }
  }

  void _startBroadcast() {
    if (_isAdvertising) return null;

    beaconBroadcast
        .setUUID(beaconUuid)
        .setMajorId(1)
        .setMinorId(100)
        .setIdentifier('com.example.myDevice')
        .setLayout(BeaconBroadcast.ALTBEACON_LAYOUT)
        .start();

    print(beaconUuid);
  }

  void _stopBroadcast() => beaconBroadcast.stop();

  void changeUUID() {
    beaconUuid = Uuid().v4();
    beaconUuid = "00000000" + beaconUuid.substring(8);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Beacon Broadcasting"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: _startBroadcast,
                child: Text(
                  "Start Broadcasting",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              RaisedButton(
                onPressed: _stopBroadcast,
                child: Text(
                  "Stop Broadcasting",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          Text("Is transmission supported?"),
          Text("$_isTransmissionSupported"),
          Text("Is beacon broadcasting?"),
          Text("$_isAdvertising"),
          Text("Broadcasting UUID"),
          Text(beaconUuid),
        ],
      ),
    );
  }
}
