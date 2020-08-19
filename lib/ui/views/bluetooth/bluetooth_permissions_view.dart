import 'package:campus_mobile_experimental/core/data_providers/bluetooth_singleton.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BluetoothPermissionsView extends StatefulWidget {
  @override
  _BluetoothPermissionsViewState createState() => _BluetoothPermissionsViewState();
}

class _BluetoothPermissionsViewState extends State<BluetoothPermissionsView> {
  BluetoothSingleton _bluetoothSingleton = BluetoothSingleton();

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: offloadPermissionToggle(context),
    );
  }

  Widget offloadPermissionToggle(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text("Provide bluetooth logs for research."),
          trailing: Switch(
            value: _bluetoothSingleton.dataOffloadAuthorized,
            onChanged: (_) {
              
              setState(() {
                _bluetoothSingleton.dataOffloadAuthorized  = !_bluetoothSingleton.dataOffloadAuthorized;
              });
          },
            activeColor: ColorPrimary,
          ),
        )
      ],
    );

  }
}