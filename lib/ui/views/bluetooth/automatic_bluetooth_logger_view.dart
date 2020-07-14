
import 'dart:async';
import 'package:campus_mobile_experimental/core/data_providers/bluetooth_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AutomaticBluetoothLoggerView extends StatefulWidget{
  final BluetoothSingleton bluetoothSingleton = BluetoothSingleton();
    @override
    State<StatefulWidget> createState() => _AutomaticBluetoothLoggerViewState(bluetoothSingleton);
  }

class _AutomaticBluetoothLoggerViewState extends  State<AutomaticBluetoothLoggerView>{
  BluetoothSingleton bluetoothSingleton;
  StreamSubscription subscription;
  List loggedItems = [];
  _AutomaticBluetoothLoggerViewState(BluetoothSingleton bluetoothScan);

  void initState(){
    bluetoothSingleton = widget.bluetoothSingleton;
    super.initState();
    subscription = bluetoothSingleton.flutterBlueInstance.scanResults.listen((event) async {
      setState(() {
        loggedItems = bluetoothSingleton.loggedItems;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    //Start dynamic resizing
    MediaQueryData queryData = MediaQuery.of(context);
    double verticalSafeBlock = (queryData.size.height -
        (queryData.padding.top + queryData.padding.bottom)) /
        100;
    double cardHeight = verticalSafeBlock * 90;
    return Scaffold(
      appBar: AppBar(
        title: Text("Automatic Bluetooth Logger"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Devices Scanned",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: Container(
                        height: cardHeight,
                        child: ListView.builder(
                            itemCount: loggedItems.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return buildText(index);
                            }),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );

  }

  Text buildText(int index) {
    if(loggedItems[index].toString().contains("LATITUDE") || loggedItems[index].toString().contains("TIMESTAMP")){
      return Text(loggedItems[index],
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),
      );
    }

    return Text(loggedItems[index]);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    subscription.cancel();
    super.dispose();
  }
}

