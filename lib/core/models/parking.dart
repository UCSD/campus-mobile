// To parse this JSON data, do
//
//     final parkingModel = parkingModelFromJson(jsonString);

import 'dart:convert';

List<ParkingModel> parkingModelFromJson(String str) => List<ParkingModel>.from(
    json.decode(str).map((x) => ParkingModel.fromJson(x)));

String parkingModelToJson(List<ParkingModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ParkingModel {
  String neighborhood;
  bool isStructure;
  String locationId;
  String locationName;
  String locationContext;
  String locationProvider;
  Map<String, dynamic> availability;

  // confirmed optional
  String? availabilityType;
  DateTime? lastUpdated;

  ParkingModel({
    required this.neighborhood,
    required this.isStructure,
    required this.locationId,
    required this.locationName,
    required this.locationContext,
    required this.locationProvider,
    required this.availability,
    this.lastUpdated,
    this.availabilityType,
  });

  ParkingModel.fromJson(Map<String, dynamic> json)
      : neighborhood = json["neighborhood"],
        isStructure = json["isStructure"],
        locationId = json["LocationId"],
        locationName = json["LocationName"],
        locationContext = json["LocationContext"],
        locationProvider = json["LocationProvider"],
        availability = json["Availability"] as Map<String, dynamic>,
        lastUpdated = json["lastUpdated"] == null
            ? null : DateTime.parse(json["LastUpdated"]),
        availabilityType = json["AvailabilityType"] == null
            ? null : json["AvailabilityType"];

  Map<String, dynamic> toJson() => {
        "Neighborhood": neighborhood,
        "isStructure": isStructure,
        "LocationId": locationId,
        "LocationName": locationName,
        "LocationContext": locationContext,
        "LocationProvider": locationProvider,
        "Availability": availability,
        "LastUpdated": lastUpdated?.toIso8601String(),
        "AvailabilityType": availabilityType
      };
}
