// To parse this JSON data, do
//
//     final parkingModel = parkingModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<DiningModel> parkingModelFromJson(String str) => List<DiningModel>.from(
    json.decode(str).map((x) => DiningModel.fromJson(x)));

String parkingModelToJson(List<DiningModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiningModel {
  String locationId;
  String locationName;
  String locationContext;
  String locationProvider;
  String availabilityType;
  Availability availability;
  DateTime lastUpdated;

  DiningModel({
    this.locationId,
    this.locationName,
    this.locationContext,
    this.locationProvider,
    this.availabilityType,
    this.availability,
    this.lastUpdated,
  });

  factory DiningModel.fromJson(Map<String, dynamic> json) => DiningModel(
        locationId: json["LocationId"] == null ? null : json["LocationId"],
        locationName:
            json["LocationName"] == null ? null : json["LocationName"],
        locationContext:
            json["LocationContext"] == null ? null : json["LocationContext"],
        locationProvider:
            json["LocationProvider"] == null ? null : json["LocationProvider"],
        availabilityType:
            json["AvailabilityType"] == null ? null : json["AvailabilityType"],
        availability: json["Availability"] == null
            ? null
            : Availability.fromJson(json["Availability"]),
        lastUpdated: json["LastUpdated"] == null
            ? null
            : DateTime.parse(json["LastUpdated"]),
      );

  Map<String, dynamic> toJson() => {
        "LocationId": locationId == null ? null : locationId,
        "LocationName": locationName == null ? null : locationName,
        "LocationContext": locationContext == null ? null : locationContext,
        "LocationProvider": locationProvider == null ? null : locationProvider,
        "AvailabilityType": availabilityType == null ? null : availabilityType,
        "Availability": availability == null ? null : availability.toJson(),
        "LastUpdated":
            lastUpdated == null ? null : lastUpdated.toIso8601String(),
      };
}

class Availability {
  SpotType b;
  SpotType accessible;
  SpotType a;
  SpotType s;
  SpotType v;
  int totalSpotsOpen;

  Availability({
    this.b,
    this.accessible,
    this.a,
    this.s,
    this.v,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    Availability availability = Availability(
      accessible: json["Accessible"] == null
          ? null
          : SpotType.fromJson(
              json["Accessible"], Colors.blue, Icon(Icons.accessible)),
      a: json["A"] == null
          ? null
          : SpotType.fromJson(json["A"], Colors.red,
              Text("A", style: TextStyle(color: Colors.white))),
      b: json["B"] == null
          ? null
          : SpotType.fromJson(json["B"], Colors.green,
              Text("B", style: TextStyle(color: Colors.white))),
      s: json["S"] == null
          ? null
          : SpotType.fromJson(json["S"], Colors.yellow,
              Text("S", style: TextStyle(color: Colors.black))),
      v: json["V"] == null
          ? null
          : SpotType.fromJson(json["V"], Colors.black,
              Text("V", style: TextStyle(color: Colors.white))),
    );
    availability.calculateOpenSpots();
    return availability;
  }

  Map<String, dynamic> toJson() => {
        "B": b == null ? null : b.toJson(),
        "Accessible": accessible == null ? null : accessible.toJson(),
        "A": a == null ? null : a.toJson(),
        "S": s == null ? null : s.toJson(),
        "V": v == null ? null : v.toJson(),
      };

  void calculateOpenSpots() {
    int total = 0;
    if (a != null) {
      total += a.open;
    }
    if (accessible != null) {
      total += accessible.open;
    }
    if (b != null) {
      total += b.open;
    }
    if (s != null) {
      total += s.open;
    }
    if (v != null) {
      total += v.open;
    }
    totalSpotsOpen = total;
  }
}

class SpotType {
  int total;
  int open;
  Color color;
  Widget type;

  SpotType({
    this.total,
    this.open,
    this.color,
    this.type,
  });

  factory SpotType.fromJson(
          Map<String, dynamic> json, Color color, Widget type) =>
      SpotType(
        total:
            json["Total"] == null ? null : int.parse(json["Total"].toString()),
        open: json["Open"] == null ? null : int.parse(json["Open"].toString()),
        color: color,
        type: type,
      );

  Map<String, dynamic> toJson() => {
        "Total": total == null ? null : total,
        "Open": open == null ? null : open,
      };
}
