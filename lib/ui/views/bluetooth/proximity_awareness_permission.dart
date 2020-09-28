import 'package:campus_mobile_experimental/core/data_providers/proximity_awareness_singleton.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProximityAwarenessPermission extends StatefulWidget {
  @override
  _ProximityAwarenessPermissionState createState() =>
      _ProximityAwarenessPermissionState();
}

class _ProximityAwarenessPermissionState extends State<ProximityAwarenessPermission> {
  ProximityAwarenessSingleton _bluetoothSingleton = ProximityAwarenessSingleton();
  SharedPreferences pref;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          primary: true,
          centerTitle: true,
          title: Text('Proximity Awareness'),
        ),
      ),
      body: getPermissionsContainer(context),
    );
  }

  void getPreferences() async {
    SharedPreferences.getInstance().then((value) {
     pref = value;
        });
  }

  Widget getPermissionsContainer(BuildContext context) {
    return Column(
      children: <Widget>[
        offloadPermissionToggle(context),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Proximity awareness benefits",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
            child: Text(
              "\u2022 Getting directions",
              style: TextStyle(
                fontSize: 17,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              "\u2022 Locate areas of interest on campus",
              style: TextStyle(
                fontSize: 17,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              "\u2022 Context aware communication with other Bluetooth devices",
              style: TextStyle(
                fontSize: 17,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ],
    );
  }

  Widget offloadPermissionToggle(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Enable proximity awareness",
            style: TextStyle(fontSize: 17),
          ),
        ),
        Expanded(child: SizedBox()),
        Switch(
          value: bluetoothStarted(context),
          onChanged: (permissionGranted) {
            startBluetooth(context, permissionGranted);
            setState(() {
              _bluetoothSingleton.proximityAwarenessEnabled =
                  !_bluetoothSingleton.proximityAwarenessEnabled;
              if (!_bluetoothSingleton.proximityAwarenessEnabled) {
                _bluetoothSingleton.stopScans();
              }
              pref.setBool("proximityAwarenessEnabled", _bluetoothSingleton.proximityAwarenessEnabled);
            });
          },
          activeColor: ColorPrimary,
        ),
      ],
    );
  }

  bool bluetoothStarted(BuildContext context) {
  return _bluetoothSingleton.proximityAwarenessEnabled;
  }
  void startBluetooth(BuildContext context,bool permissionGranted) async {
    _bluetoothSingleton = ProximityAwarenessSingleton();
    if(_bluetoothSingleton.userDataProvider == null) {
      _bluetoothSingleton.userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
    }
    if (permissionGranted ) {
      // Future.delayed(Duration(seconds: 5), ()  => bluetoothInstance.getOffloadAuthorization(context));
      print("RAN INIT");
      _bluetoothSingleton.init();
    }
  }
}
