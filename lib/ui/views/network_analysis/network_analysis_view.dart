import 'dart:io';

import 'package:WifiConnection/WifiConnection.dart';
import 'package:app_settings/app_settings.dart';
import 'package:campus_mobile_experimental/core/data_providers/advanced_wayfinding_singleton.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkAnalysisView extends StatefulWidget {
  @override
  _NetworkAnalysisState createState() =>
      _NetworkAnalysisState();
}


class _NetworkAnalysisState extends State<NetworkAnalysisView>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: AppBar(
            primary: true,
            centerTitle: true,
            title: Text("Network Analysis"),
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.only(top: 200.0),
        child: Center(
          child: FutureBuilder(
           //future: Future.wait( [WifiConnection.wifiInfo, Location().getLocation()] ),
             future: futureCombo(),
             builder: (context,  snapshot){
               if(snapshot.hasData){


                 return Column(
                   children: [
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Text("Wifi Information",
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 22
                       ),),
                     ),
                     Text("BSSID: ${snapshot.data[0].bssId}"),
                     Text("SSID: ${snapshot.data[0].ssid}"),
                     Text("WiFi IP Address: ${snapshot.data[0].ipAddress}"),
                     Text("MAC Address: ${snapshot.data[0].macAddress}"),
                     Text("Latitude: ${snapshot.data[1].latitude}"),
                     Text("Longitude: ${snapshot.data[1].longitude}"),
                     Text("Time stamp: ${DateTime.fromMillisecondsSinceEpoch(
               DateTime.now().millisecondsSinceEpoch).toString()}"),
                    FlatButton(onPressed: (){}, child: Container(
                      color: ThemeData.light().buttonColor,
                        height: 30,
                        width: 200,
                        child: Center(child: Text("Log Data"))),)
                   ],
                 );
               }else if(snapshot.hasError){
                 print(snapshot.error.toString());
                 print("error");
               }
               return CircularProgressIndicator();
             },
          ),
        ),
      )
    );
  }
}
Future<List<Object>> futureCombo() async{
  return [ await WifiConnection.wifiInfo, await Location().getLocation()];
}