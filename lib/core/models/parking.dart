// To parse this JSON data, do
//
//     final parkingModel = parkingModelFromJson(jsonString);

import 'dart:convert';

List<ParkingModel> parkingModelFromJson(String str) => List<ParkingModel>.from(
    json.decode(str).map((x) => ParkingModel.fromJson(x)));

String parkingModelToJson(List<ParkingModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ParkingModel {
  String? locationId;
  String? locationName;
  String? locationContext;
  String? locationProvider;

  ParkingModel({
    this.locationId,
    this.locationName,
    this.locationContext,
    this.locationProvider,
  });

  factory ParkingModel.fromJson(Map<String, dynamic> json) => ParkingModel(
        locationId: json["LocationId"] == null ? null : json["LocationId"],
        locationName:
            json["LocationName"] == null ? null : json["LocationName"],
        locationContext:
            json["LocationContext"] == null ? null : json["LocationContext"],
        locationProvider:
            json["LocationProvider"] == null ? null : json["LocationProvider"],
      );

  Map<String, dynamic> toJson() => {
        "LocationId": locationId == null ? null : locationId,
        "LocationName": locationName == null ? null : locationName,
        "LocationContext": locationContext == null ? null : locationContext,
        "LocationProvider": locationProvider == null ? null : locationProvider,
      };
}
