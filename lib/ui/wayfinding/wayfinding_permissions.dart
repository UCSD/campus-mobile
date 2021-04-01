import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/providers/wayfinding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';

// ignore: must_be_immutable
class AdvancedWayfindingPermission extends StatefulWidget {
  @override
  _AdvancedWayfindingPermissionState createState() =>
      _AdvancedWayfindingPermissionState();
}

class _AdvancedWayfindingPermissionState
    extends State<AdvancedWayfindingPermission> {
  AdvancedWayfindingSingleton _bluetoothSingleton;
  SharedPreferences pref;
  Coordinates _coordinates;

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
        StreamBuilder(
          stream: FlutterBlue.instance.state,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Switch(
                value: bluetoothStarted(context, snapshot),
                onChanged: (permissionGranted) {
                  startBluetooth(context, permissionGranted);
                  bool forceOff = false;
                  if (((snapshot.data as BluetoothState ==
                              BluetoothState.unauthorized) ||
                          (snapshot.data as BluetoothState ==
                              BluetoothState.off)) &&
                      permissionGranted) {
                    forceOff = true;
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          if (Platform.isIOS) {
                            return CupertinoAlertDialog(
                              title: Text(
                                  "UCSD Mobile would like to use Bluetooth."),
                              content: Text(
                                  "This feature use Bluetooth to connect with other devices."),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text('Settings'),
                                  onPressed: () {
                                    AppSettings.openAppSettings();
                                  },
                                )
                              ],
                            );
                          }
                          return AlertDialog(
                            title: Text(
                                "UCSD Mobile would like to use Bluetooth."),
                            content: Text(
                                "This feature use Bluetooth to connect with other devices."),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Settings'),
                                onPressed: () {
                                  AppSettings.openAppSettings();
                                },
                              )
                            ],
                          );
                        });
                  }
                  // check if location is available
                  double userLongitude = (_coordinates == null) ? null : _coordinates.lon;
                  double userLatitude = (_coordinates == null) ? null : _coordinates.lat;
                  if (userLatitude == null || userLongitude == null){
                    forceOff = true;
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          if (Platform.isIOS) {
                            return CupertinoAlertDialog(
                              title: Text(
                                  "UCSD Mobile would like to use Location."),
                              content: Text(
                                  "Please turn on Location."),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text('Settings'),
                                  onPressed: () {
                                    AppSettings.openAppSettings();
                                  },
                                )
                              ],
                            );
                          }
                          return AlertDialog(
                            title: Text(
                                "UCSD Mobile would like to use Location."),
                            content: Text(
                                "Please turn on location."),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Settings'),
                                onPressed: () {
                                  AppSettings.openAppSettings();
                                },
                              )
                            ],
                          );
                        });
                  }
                  setState(() {
                    if (forceOff) {
                      _bluetoothSingleton.advancedWayfindingEnabled = false;
                    } else {
                      _bluetoothSingleton.advancedWayfindingEnabled =
                          !_bluetoothSingleton.advancedWayfindingEnabled;
                    }

                    if (!_bluetoothSingleton.advancedWayfindingEnabled) {
                      _bluetoothSingleton.stopScans();
                    }
                    SharedPreferences.getInstance().then((value) {
                      value.setBool("advancedWayfindingEnabled",
                          _bluetoothSingleton.advancedWayfindingEnabled);
                    });
                  });
                },
                activeColor: Theme.of(context).buttonColor,
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }

  bool bluetoothStarted(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    double userLongitude = (_coordinates == null) ? null : _coordinates.lon;
    double userLatitude = (_coordinates == null) ? null : _coordinates.lat;
//    print("latitude: $userLatitude");
//    print("longitude: $userLongitude");
//    print("coordinates: $_coordinates");
    bool locationOn = false;
    if (userLatitude != null && userLongitude != null) {
      locationOn = true;
    }
    _bluetoothSingleton = AdvancedWayfindingSingleton();

    if ((snapshot.data as BluetoothState == BluetoothState.unauthorized ||
            snapshot.data as BluetoothState == BluetoothState.off) ||
        (_bluetoothSingleton != null &&
            !_bluetoothSingleton.advancedWayfindingEnabled) || !locationOn) {
      _bluetoothSingleton.advancedWayfindingEnabled = false;
    }

    return _bluetoothSingleton.advancedWayfindingEnabled;
  }

  void checkToResumeBluetooth(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("advancedWayfindingEnabled") &&
        prefs.getBool('advancedWayfindingEnabled')) {
      AdvancedWayfindingSingleton bluetoothSingleton =
          AdvancedWayfindingSingleton();
      if (bluetoothSingleton.firstInstance) {
        bluetoothSingleton.firstInstance = false;
        if (bluetoothSingleton.userDataProvider == null) {
          bluetoothSingleton.userDataProvider =
              Provider.of<UserDataProvider>(context, listen: false);
        }
        bluetoothSingleton.init();
      }
    }
  }

  void startBluetooth(BuildContext context, bool permissionGranted) async {
    _bluetoothSingleton = AdvancedWayfindingSingleton();
    if (_bluetoothSingleton.userDataProvider == null) {
      _bluetoothSingleton.userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
    }
    if (permissionGranted) {
      // Future.delayed(Duration(seconds: 5), ()  => bluetoothInstance.getOffloadAuthorization(context));
      await _bluetoothSingleton.init();
    }
  }
  set coordinates(Coordinates value) {
    _coordinates = value;
  }
}
