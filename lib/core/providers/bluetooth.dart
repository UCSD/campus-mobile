

import 'dart:math';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeaconSingleton {
  String? advertisingUUID;
  String ucsdAppPrefix = "08506708-3068-0650-8008-0"; // UCSDAPP in ASCII
  List<String> hexLetters = ["A", "B", "C", "D", "E", "F"];
  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  //Internal Declaration
  static final BeaconSingleton _beaconSingleton = BeaconSingleton._internal();

  BeaconSingleton._internal();

  factory BeaconSingleton() {
    return _beaconSingleton;
  }
  init() async {
    changeUUID();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    checkTime();
    prefs.setString('uuid', advertisingUUID!);
    beaconBroadcast
        .setUUID(advertisingUUID!)
        .setMajorId(1)
        .setMinorId(100)
        .setIdentifier('ucsd.app.mobile')
        .setLayout(BeaconBroadcast.ALTBEACON_LAYOUT)
        .start();
  }

  void checkTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    advertisingUUID = prefs.get('uuid') as String? ?? "null";
    var previousTime = prefs.get('previousTime') ?? DateTime(1990).toString();
    var difference =
        DateTime.now().difference(DateTime.parse(previousTime as String)).inHours;
    if (difference > 24) {
      changeUUID();
      prefs.setString('previousTime', DateTime.now().toString());
    }
  }

  void changeUUID() {
    advertisingUUID = Uuid().v4();

    advertisingUUID = randomUUID();
  }

  String randomUUID() {
    final random = Random();
    String newUUID = ucsdAppPrefix;
    for (int uuidIndex = 0; uuidIndex < 11; uuidIndex++) {
      bool useLetter = random.nextBool();
      if (useLetter) {
        newUUID += hexLetters[random.nextInt(6)];
      } else {
        newUUID += random.nextInt(10).toString();
      }
    }
    return newUUID;
  }
}
