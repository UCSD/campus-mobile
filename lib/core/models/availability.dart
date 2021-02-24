import 'dart:convert';

List<AvailabilityModel> availabilityModelFromJson(String str) {
  var jsonStr = json.decode(str)['data']['children'];
  return List<AvailabilityModel>.from(
      jsonStr.map((x) => AvailabilityModel.fromJson(x)));
}

class AvailabilityModel {
  int locationId;
  bool isOpen;
  bool isError;
  double percent;
  String locationName;
  List<AvailabilityModel> subLocations;

  AvailabilityModel(
      {this.locationId,
      this.isOpen,
      this.isError,
      this.percent,
      this.locationName,
      this.subLocations});

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        locationId: json["id"] == null ? null : json["id"],
        isOpen: json["isOpen"] == null ? null : json["isOpen"],
        isError: json["isError"] == null ? null : json["isError"],
        locationName: json["name"] == null ? null : json["name"],
        percent: json["percent"] == null ? null : json["percent"].toDouble(),
        subLocations: json["children"] == null
            ? null
            : List<AvailabilityModel>.from(
                json["children"].map((x) => AvailabilityModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "locationId": locationId == null ? null : locationId,
        "locationName": locationName == null ? null : locationName,
        "isOpen": isOpen == null ? null : isOpen,
        "isError": isError == null ? null : isError,
        "percent": percent == null ? null : percent.toString(),
        "children": subLocations == null
            ? null
            : List<dynamic>.from(subLocations.map((x) => x.toJson())),
      };
}
