import 'dart:convert';
import 'dart:core';

List<ShuttleStopModel> shuttleStopModelFromJson(String str) {
  Map<String, dynamic> list = json.decode(str);
  List<ShuttleStopModel> ret = [];
  list.forEach((key, value) {
    ret.add(ShuttleStopModel(
      lat: value["lat"] == null ? null : value["lat"].toDouble(),
      lon: value["lon"] == null ? null : value["lon"].toDouble(),
      id: value["id"] == null ? null : value["id"],
      name: value["name"] == null ? null : value["name"],
    ));
  });
  return ret;
}

String shuttleStopModelToJson(List<ShuttleStopModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ShuttleStopModel {
  double? lat;
  double? lon;
  int? id;
  String? name;

  ShuttleStopModel({
    this.lat,
    this.lon,
    this.id,
    this.name,
  });

  factory ShuttleStopModel.fromJson(Map<String, dynamic> json) =>
      ShuttleStopModel(
        lat: json["lat"] == null ? null : json["lat"].toDouble(),
        lon: json["lon"] == null ? null : json["lon"].toDouble(),
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "lat": lat == null ? null : lat,
        "lon": lon == null ? null : lon,
        "id": id == null ? null : id,
        "name": name == null ? null : name,
      };
}
