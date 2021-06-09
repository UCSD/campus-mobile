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
  Map<String, dynamic>? availability;
  DateTime? lastUpdated;
  String? availabilityType;

  ParkingModel({
    this.locationId,
    this.locationName,
    this.locationContext,
    this.locationProvider,
    this.availability,
    this.lastUpdated,
    this.availabilityType,
  });

  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return ParkingModel(
      locationId: json["LocationId"] == null ? null : json["LocationId"],
      locationName: json["LocationName"] == null ? null : json["LocationName"],
      locationContext:
          json["LocationContext"] == null ? null : json["LocationContext"],
      locationProvider:
          json["LocationProvider"] == null ? null : json["LocationProvider"],
      availability: json["Availability"] == null
          ? null
          : json["Availability"] as Map<String, dynamic>?,
      lastUpdated: json["lastUpdated"] == null
          ? null
          : DateTime.parse(json["LastUpdated"]),
      availabilityType:
          json["AvailabilityType"] == null ? null : json["AvailabilityType"],
    );
  }

  Map<String, dynamic> toJson() => {
        "LocationId": locationId == null ? null : locationId,
        "LocationName": locationName == null ? null : locationName,
        "LocationContext": locationContext == null ? null : locationContext,
        "LocationProvider": locationProvider == null ? null : locationProvider,
        "Availability": availability == null ? null : availability,
        "LastUpdated":
            lastUpdated == null ? null : lastUpdated!.toIso8601String(),
        "AvailabilityType": availabilityType == null ? null : availabilityType
      };
}
