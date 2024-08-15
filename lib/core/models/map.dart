// To parse this JSON data, do
//
//     final mapSearchModel = mapSearchModelFromJson(jsonString);

import 'dart:convert';

List<MapSearchModel> mapSearchModelFromJson(String str) =>
    List<MapSearchModel>.from(
        json.decode(str).map((x) => MapSearchModel.fromJson(x)));

String mapSearchModelToJson(List<MapSearchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MapSearchModel {
  String title;
  int mkrEnabled;
  int mkrRegion;
  String location;
  String description;
  int mkrGroupid;
  double mkrLong;
  double mkrLat;
  String url;
  int mkrMarkerid;

  // confirmed optional
  dynamic score;
  String? access;
  double? distance;

  MapSearchModel({
    required this.title,
    required this.mkrEnabled,
    required this.mkrRegion,
    required this.location,
    required this.description,
    required this.mkrGroupid,
    this.score,
    required this.mkrLong,
    required this.mkrLat,
    this.access,
    required this.url,
    required this.mkrMarkerid,
  });

  MapSearchModel.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        mkrEnabled = json["mkrEnabled"],
        mkrRegion = json["mkrRegion"],
        location = json["location"],
        description = json["description"],
        mkrGroupid = json["mkrGroupid"],
        score = json["score"],
        mkrLong = json["mkrLong"].toDouble(),
        mkrLat = json["mkrLat"].toDouble(),
        access = json["access"],
        url = json["url"],
        mkrMarkerid = json["mkrMarkerid"];

  Map<String, dynamic> toJson() => {
        "title": title,
        "mkrEnabled": mkrEnabled,
        "mkrRegion": mkrRegion,
        "location": location,
        "description": description,
        "mkrGroupid": mkrGroupid,
        "score": score,
        "mkrLong": mkrLong,
        "mkrLat": mkrLat,
        "access": access,
        "url": url,
        "mkrMarkerid": mkrMarkerid,
      };
}
