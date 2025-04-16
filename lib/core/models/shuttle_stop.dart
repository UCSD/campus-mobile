import 'dart:convert';
import 'dart:core';

List<ShuttleStopModel> shuttleStopModelFromJson(String str) {
  Map<String, dynamic> list = json.decode(str);
  List<ShuttleStopModel> ret = [];
  list.forEach((key, value) {
    ret.add(ShuttleStopModel.fromJson(value));
  });
  return ret;
}

String shuttleStopModelToJson(List<ShuttleStopModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ShuttleStopModel {
  double lat;
  double lon;
  int id;
  String name;

  ShuttleStopModel({
    required this.lat,
    required this.lon,
    required this.id,
    required this.name,
  });

  ShuttleStopModel.fromJson(Map<String, dynamic> json)
      : lat = json["lat"].toDouble(),
        lon = json["lon"].toDouble(),
        id = json["id"],
        name = json["name"];

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
        "id": id,
        "name": name,
      };
}
