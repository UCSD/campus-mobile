import 'package:campus_mobile_experimental/core/data_providers/bluetooth_singleton.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class BluetoothPermissionsView extends StatefulWidget {
  @override
  _BluetoothPermissionsViewState createState() =>
      _BluetoothPermissionsViewState();
}

class _BluetoothPermissionsViewState extends State<BluetoothPermissionsView> {
  BluetoothSingleton _bluetoothSingleton;
  SharedPreferences pref;

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((value) {
      pref = value;
    });
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
          value: bluetoothStarted(),
          onChanged: (_) {
            startBluetooth(context);
            setState(() {
              _bluetoothSingleton.dataOffloadAuthorized =
                  !_bluetoothSingleton.dataOffloadAuthorized;
              if (!_bluetoothSingleton.dataOffloadAuthorized) {
                _bluetoothSingleton.stopScans();
              }
              pref.setBool("offloadPermission", bluetoothStarted());
            });
          },
          activeColor: ColorPrimary,
        ),
      ],
    );
  }

  bool bluetoothStarted() {
    if (_bluetoothSingleton == null) {
      return false;
    }
    return _bluetoothSingleton.dataOffloadAuthorized;
  }

  void startBluetooth(BuildContext context) async {
    _bluetoothSingleton = BluetoothSingleton();

    if (_bluetoothSingleton.firstInstance) {
      _bluetoothSingleton.userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      // Future.delayed(Duration(seconds: 5), ()  => bluetoothInstance.getOffloadAuthorization(context));
      _bluetoothSingleton.init();
    }
  }
}
