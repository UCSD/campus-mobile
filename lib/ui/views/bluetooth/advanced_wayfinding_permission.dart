import 'dart:io';

import 'package:campus_mobile_experimental/core/data_providers/advanced_wayfinding_singleton.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class AdvancedWayfindingPermission extends StatefulWidget {
  @override
  _AdvancedWayfindingPermissionState createState() =>
      _AdvancedWayfindingPermissionState();
}

class _AdvancedWayfindingPermissionState extends State<AdvancedWayfindingPermission> {
  AdvancedWayfindingSingleton _bluetoothSingleton;
  SharedPreferences pref;
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
     getPreferences();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          primary: true,
          centerTitle: true,
          title: Text("Advanced Wayfinding"),
        ),
      ),
      body: getPermissionsContainer(context),
    );
  }

  void getPreferences() async {
    isOn = await FlutterBlue.instance.state.last == BluetoothState.unauthorized;

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
              "Advanced wayfinding benefits",
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
            "Enable advanced wayfinding",
            style: TextStyle(fontSize: 17),
          ),
        ),
        Expanded(child: SizedBox()),
        Switch(
          value: bluetoothStarted(context),
          onChanged: (permissionGranted) {


            startBluetooth(context, permissionGranted);
            bool forceOff = false;
            if(!isOn && permissionGranted){
              forceOff = true;
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    if (Platform.isIOS) {
                      return CupertinoAlertDialog(
                        title:
                        Text("Bluetooth permission must be granted."),
                        content: Text(
                            "Please go to the Settings app to enable BT access for UC San Diego."),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                    return AlertDialog(
                      title: Text("Bluetooth permission must be granted."),
                      content: Text(
                          "Please go to the Settings app to enable BT access for UC San Diego."),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            }
            setState(() {
              if(forceOff){
                _bluetoothSingleton.advancedWayfindingEnabled = false;

              }else{
                _bluetoothSingleton.advancedWayfindingEnabled =
                !_bluetoothSingleton.advancedWayfindingEnabled;
              }

              if (!_bluetoothSingleton.advancedWayfindingEnabled) {
                _bluetoothSingleton.stopScans();
              }
              pref.setBool("advancedWayfindingEnabled", _bluetoothSingleton.advancedWayfindingEnabled);
            });
          },
          activeColor: ColorPrimary,
        ),
      ],
    );
  }

  bool bluetoothStarted(BuildContext context) {
    if(!isOn && _bluetoothSingleton != null &&_bluetoothSingleton.advancedWayfindingEnabled){
      return false;
    }
      _bluetoothSingleton = AdvancedWayfindingSingleton();
      return _bluetoothSingleton.advancedWayfindingEnabled;
  }
  void checkToResumeBluetooth(BuildContext context) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey("advancedWayfindingEnabled") && prefs.getBool('advancedWayfindingEnabled')){
      print(prefs.getBool("advancedWayfindingEnabled"));
      AdvancedWayfindingSingleton bluetoothSingleton = AdvancedWayfindingSingleton();
      if(bluetoothSingleton.firstInstance) {
        bluetoothSingleton.firstInstance = false;
        print("Instance: "+ bluetoothSingleton.firstInstance.toString());
        if(bluetoothSingleton.userDataProvider == null) {
          bluetoothSingleton.userDataProvider =
              Provider.of<UserDataProvider>(context, listen: false);
        }
        bluetoothSingleton.init();
      }
    }
  }
  void startBluetooth(BuildContext context,bool permissionGranted) async {
    _bluetoothSingleton = AdvancedWayfindingSingleton();
    if(_bluetoothSingleton.userDataProvider == null) {
      _bluetoothSingleton.userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
    }
    if (permissionGranted ) {
      // Future.delayed(Duration(seconds: 5), ()  => bluetoothInstance.getOffloadAuthorization(context));
    isOn = await _bluetoothSingleton.init();
    }
  }
}
