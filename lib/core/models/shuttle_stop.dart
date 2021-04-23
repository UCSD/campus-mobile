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
        stopCode: value["stopCode"] == null ? null : value["stopCode"],
        rtpiNumber: value["rtpiNumber"] == null ? null : value["rtpiNumber"]));
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
  int stopCode;
  String rtpiNumber;

  ShuttleStopModel({
    this.lat,
    this.lon,
    this.id,
    this.name,
    this.stopCode,
    this.rtpiNumber,
  });

  factory ShuttleStopModel.fromJson(Map<String, dynamic> json) =>
      ShuttleStopModel(
          lat: json["lat"] == null ? null : json["lat"].toDouble(),
          lon: json["lon"] == null ? null : json["lon"].toDouble(),
          id: json["id"] == null ? null : json["id"],
          name: json["name"] == null ? null : json["name"],
          stopCode: json["stopCode"] == null ? null : json["stopCode"],
          rtpiNumber: json["rtpiNumber"] == null ? null : json["rtpiNumber"]);

  Map<String, dynamic> toJson() => {
        "lat": lat == null ? null : lat,
        "lon": lon == null ? null : lon,
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "stopCode": stopCode == null ? null : stopCode,
        "rtpiNumber": rtpiNumber == null ? null : rtpiNumber,
      };
}
