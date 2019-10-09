// To parse this JSON data, do
//
//     final availabilityModel = availabilityModelFromJson(jsonString);

import 'dart:convert';

List<AvailabilityModel> availabilityModelFromJson(String str) =>
    List<AvailabilityModel>.from(
        json.decode(str).map((x) => AvailabilityModel.fromJson(x)));

String availabilityModelToJson(List<AvailabilityModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AvailabilityModel {
  double lat;
  double lon;
  int locationId;
  String locationName;
  Units units;
  bool isOpen;
  String abbreviation;
  List<AvailabilityModel> subLocations;
  int busyness;
  int estimated;
  DateTime lastUpdated;

  AvailabilityModel({
    this.lat,
    this.lon,
    this.locationId,
    this.locationName,
    this.units,
    this.isOpen,
    this.abbreviation,
    this.subLocations,
    this.busyness,
    this.estimated,
    this.lastUpdated,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        lat: json["lat"] == null ? null : json["lat"].toDouble(),
        lon: json["lon"] == null ? null : json["lon"].toDouble(),
        locationId: json["locationId"] == null ? null : json["locationId"],
        locationName:
            json["locationName"] == null ? null : json["locationName"],
        units: json["units"] == null ? null : unitsValues.map[json["units"]],
        isOpen: json["isOpen"] == null ? null : json["isOpen"],
        abbreviation:
            json["abbreviation"] == null ? null : json["abbreviation"],
        subLocations: json["sublocations"] == null
            ? null
            : List<AvailabilityModel>.from(
                json["sublocations"].map((x) => AvailabilityModel.fromJson(x))),
        busyness: json["busyness"] == null ? null : json["busyness"],
        estimated: json["estimated"] == null ? null : json["estimated"],
        lastUpdated: json["lastUpdated"] == null
            ? null
            : DateTime.parse(json["lastUpdated"]),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat == null ? null : lat,
        "lon": lon == null ? null : lon,
        "locationId": locationId == null ? null : locationId,
        "locationName": locationName == null ? null : locationName,
        "units": units == null ? null : unitsValues.reverse[units],
        "isOpen": isOpen == null ? null : isOpen,
        "abbreviation": abbreviation == null ? null : abbreviation,
        "sublocations": subLocations == null
            ? null
            : List<dynamic>.from(subLocations.map((x) => x.toJson())),
        "busyness": busyness == null ? null : busyness,
        "estimated": estimated == null ? null : estimated,
        "lastUpdated":
            lastUpdated == null ? null : lastUpdated.toIso8601String(),
      };
}

enum Units { OPEN_SEATS, PEOPLE }

final unitsValues =
    EnumValues({"open seats": Units.OPEN_SEATS, "people": Units.PEOPLE});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
