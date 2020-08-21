
import 'package:campus_mobile_experimental/core/data_providers/bluetooth_singleton.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class BluetoothPermissionsView extends StatefulWidget {
  @override
  _BluetoothPermissionsViewState createState() => _BluetoothPermissionsViewState();
}

class _BluetoothPermissionsViewState extends State<BluetoothPermissionsView> {
  BluetoothSingleton _bluetoothSingleton = BluetoothSingleton();
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
          title: Text(
            'Research Data'
          ),
        ),
      ),
      body: getPermissionsContainer(context),
    );
  }

  Widget getPermissionsContainer(BuildContext context){
    return Column(
      children: <Widget>[
        offloadPermissionToggle(context),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                "What is collected:",
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
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              "\u2022 A unique randomized 128 bit identifier.",
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              "\u2022 Other bluetooth devices detected in proximity.",
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              "\u2022 Location when in the presence of bluetooth devices.",
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              "\u2022 Timestamp of bluetooth scans.",
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              "\u2022 The presence of nearby devices running the UCSD App.",
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left:  16, top: 32.0),
            child: Text(
              "What is not collected:",
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
            padding: const EdgeInsets.only(left: 16, top: 20),
            child: Text(
              "\u2022 Your devices' actual 128 bit identifier.",
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              "\u2022 Names of devices (yours and others).",
              style: TextStyle(
                fontSize: 15,
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
            child: Text("Allow researchers to use my data.",
              style: TextStyle(
              fontSize: 17
             ),
            ),
          ),
          Expanded(child:
          SizedBox()

          ),
    Switch(
    value: _bluetoothSingleton.dataOffloadAuthorized,
    onChanged: (_) {

    setState(() {
    _bluetoothSingleton.dataOffloadAuthorized  = !_bluetoothSingleton.dataOffloadAuthorized;
    pref.setBool("offloadPermission", _bluetoothSingleton.dataOffloadAuthorized);

    });
    },
    activeColor: ColorPrimary,
    )
          ,

      ],
    );

  }

  Widget dataDescription(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text(
            "What is collected?",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        ListTile(
          title: Text(
            "A unique randomized 128 bit identifier."
          ),
          leading:Icon(Icons.fiber_manual_record) ,
        ),
        ListTile(
          title: Text(
              "Other bluetooth devices detected in proximity."
          ),
          leading:Icon(Icons.fiber_manual_record) ,
        ),
      ],
    );
  }
}