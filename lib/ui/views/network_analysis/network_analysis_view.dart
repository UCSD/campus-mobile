import 'dart:ffi';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:campus_mobile_experimental/core/data_providers/advanced_wayfinding_singleton.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_connection/WifiConnection.dart';
import 'package:connectivity/connectivity.dart';

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
               if(snapshot.hasData && snapshot.data[2] == ConnectivityResult.wifi){


                 if(Platform.isIOS) {
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
                           DateTime
                               .now()
                               .millisecondsSinceEpoch).toString()}"),
                       FlatButton(onPressed: () {}, child: Container(
                           color: ThemeData
                               .light()
                               .buttonColor,
                           height: 30,
                           width: 200,
                           child: Center(child: Text("Log Data"))),)
                     ],
                   );
                 }
                 else if(Platform.isAndroid){
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
                       Text("Link speed: ${snapshot.data[0].linkSpeed}" ),
                       Text("Signal Strength: ${snapshot.data[0].signalStrength}" ),
                       Text("Frequency : ${snapshot.data[0].frequency}" ),
                       Text("Network ID: ${snapshot.data[0].networkId}" ),
                       Text("Hidden SSID: ${snapshot.data[0].isHiddenSSid}" ),
                       Text("Router IP: ${snapshot.data[0].routerIp}" ),
                       Text("Channel : ${snapshot.data[0].channel}" ),
                       Text("Latitude: ${snapshot.data[1].latitude}"),
                       Text("Longitude: ${snapshot.data[1].longitude}"),
                       Text("Time stamp: ${DateTime.fromMillisecondsSinceEpoch(
                           DateTime
                               .now()
                               .millisecondsSinceEpoch).toString()}"),
                       FlatButton(onPressed: () {}, child: Container(
                           color: ThemeData
                               .light()
                               .buttonColor,
                           height: 30,
                           width: 200,
                           child: Center(child: Text("Log Data"))),)
                     ],
                   );
                 }
                 if(Platform.isAndroid) {
                   Map wifiLog = {
                     "Platform": "Android",
                     "SSID": snapshot.data[0].ssid,
                     "BSSID": snapshot.data[0].bssId,
                     "IPAddress": snapshot.data[0].ipAddress,
                     "MacAddress": snapshot.data[0].macAddress,
                     "LinkSpeed": snapshot.data[0].linkSpeed,
                     "SignalStrength": snapshot.data[0].signalStrength,
                     "Frequency": snapshot.data[0].frequency,
                     "NetworkID": snapshot.data[0].networkId,
                     "IsHiddenSSID": snapshot.data[0].isHiddenSSid,
                     "RouterIP": snapshot.data[0].routerIp,
                     "Channel": snapshot.data[0].channel,
                     "Latitude": snapshot.data[1].latitude as Double,
                     "Longitude": snapshot.data[1].longitude as Double,
                     "TimeStamp": DateTime.fromMillisecondsSinceEpoch(
                         DateTime
                             .now()
                             .millisecondsSinceEpoch).toString()
                   };
                 }else{
                   Map wifiLog = {
                   "Platform": "iOS",
                   "SSID": snapshot.data[0].ssid,
                   "BSSID": snapshot.data[0].bssId,
                   "IPAddress": snapshot.data[0].ipAddress,
                   "MacAddress": snapshot.data[0].macAddress,
                   "LinkSpeed": "",
                   "SignalStrength": "",
                   "Frequency": "",
                   "NetworkID": "",
                   "IsHiddenSSID": "",
                   "RouterIP": "",
                   "Channel": "",
                   "Latitude": snapshot.data[1].latitude as Double,
                   "Longitude": snapshot.data[1].longitude as Double,
                   "TimeStamp": DateTime.fromMillisecondsSinceEpoch(
                       DateTime
                           .now()
                           .millisecondsSinceEpoch).toString()
                 };
                 }

               }else if(snapshot.hasData){
                  return Column(
                    children: [
                      Center(child: Text("Not connected to WiFi"))
                    ],
                  );
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
  if(await (Connectivity().checkConnectivity()) != ConnectivityResult.wifi){
    return [ null, null, await (Connectivity().checkConnectivity()) ];
  }

  var location = Location();
  location.changeSettings(accuracy: LocationAccuracy.low);

  LocationData position;
  return [ await WifiConnection.wifiInfo, await location.getLocation(), await (Connectivity().checkConnectivity()) ];
}