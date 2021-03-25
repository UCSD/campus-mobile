import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:wifi_connection/WifiInfo.dart';

class SpeedTestModel {
  bool isUCSDWifi;
  String uploadUrl;
  String downloadUrl;
  String platform;
  String ssid;
  String bssid;
  String ipAddress;
  String macAddress;
  String linkSpeed;
  String signalStrength;
  String frequency;
  String networkID;
  String isHiddenSSID;
  String routerIP;
  String channel;
  double latitude;
  double longitude;
  String timeStamp;
  double downloadSpeed;
  double uploadSpeed;

  SpeedTestModel(
      {this.isUCSDWifi,
      this.uploadUrl,
      this.downloadUrl,
      this.platform,
      this.ssid,
      this.bssid,
      this.ipAddress,
      this.macAddress,
      this.linkSpeed,
      this.signalStrength,
      this.frequency,
      this.networkID,
      this.isHiddenSSID,
      this.routerIP,
      this.channel,
      this.latitude,
      this.longitude,
      this.timeStamp,
      this.downloadSpeed,
      this.uploadSpeed});

  factory SpeedTestModel.fromJson(
      WifiInfo wifiInfo,
      Map<String, String> downloadJson,
      Map<String, String> uploadJson,
      bool isUCSDWifi) {
    return SpeedTestModel(
        isUCSDWifi: isUCSDWifi,
        uploadUrl: uploadJson["signed_url"],
        downloadUrl: downloadJson["signed_url"],
        platform: Platform.isAndroid ? "Android" : "iOS",
        ssid: wifiInfo.ssid == null ? "" : wifiInfo.ssid,
        bssid: wifiInfo.bssId == null ? "" : wifiInfo.bssId,
        ipAddress: wifiInfo.ipAddress == null ? "" : wifiInfo.ipAddress,
        macAddress: wifiInfo.macAddress == null ? "" : wifiInfo.macAddress,
        linkSpeed: wifiInfo.linkSpeed == null ? "" : wifiInfo.linkSpeed,
        signalStrength:
            wifiInfo.signalStrength == null ? "" : wifiInfo.signalStrength,
        frequency: wifiInfo.frequency == null ? "" : wifiInfo.frequency,
        networkID: wifiInfo.networkId == null ? "" : wifiInfo.networkId,
        isHiddenSSID:
            wifiInfo.isHiddenSSid == null ? "" : wifiInfo.isHiddenSSid,
        routerIP: wifiInfo.routerIp == null ? "" : wifiInfo.routerIp,
        channel: wifiInfo.channel == null ? "" : wifiInfo.channel,
        latitude: 0.0,
        longitude: 0.0,
        timeStamp: DateTime.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch)
            .toString(),
        downloadSpeed: 0.0,
        uploadSpeed: 0.0);
  }
}

SpeedTestModel speedTestModelFromJson( WifiInfo wifiInfo,
     String downloadUrl,String uploadUrl, bool isUCSDWifi) {
  return SpeedTestModel.fromJson(
      wifiInfo, json.decode(downloadUrl), json.decode(uploadUrl), isUCSDWifi);
}
