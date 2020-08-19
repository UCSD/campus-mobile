import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeaconSingleton{
  String advertisingUUID;

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  //Internal Declaration
static final BeaconSingleton _beaconSingleton = BeaconSingleton._internal();

BeaconSingleton._internal();

  void checkTime () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    advertisingUUID = prefs.get('uuid') ?? "null";
    var previousTime =  prefs.get('previousTime') ?? DateTime(1990).toString();
    var difference = DateTime.now().difference(DateTime.parse(previousTime)).inSeconds;
    print(difference);
    if (difference > 10) {
      changeUUID();
      prefs.setString('previousTime', DateTime.now().toString());
    }

  }

  void changeUUID () {
    advertisingUUID = Uuid().v4();
    advertisingUUID = "00000000" + advertisingUUID.substring(8);
  }

  String randomUUID(){

  }
}