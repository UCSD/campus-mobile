import 'package:flutter/material.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:uuid/uuid.dart';

class BeaconView extends StatefulWidget {
  @override
  _BeaconViewState createState() => _BeaconViewState();
}

class _BeaconViewState extends State<BeaconView> {

  var _isTransmissionSupported;
  var _isAdvertisingSubscription;
  var _isAdvertising;
  String broadcastingState = "Currently not broadcasting";
  BeaconBroadcast beaconBroadcast;
  var beaconUuid = "null";

  @override
  void initState () {
    super.initState();
    print("Entered broadcasting section");

    beaconBroadcast = BeaconBroadcast();
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
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

  void startBroadcast () {
    //start beacon broadcasting
    //if (isBroadcasting)
    //  return;

    beaconUuid = Uuid().v4();
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
