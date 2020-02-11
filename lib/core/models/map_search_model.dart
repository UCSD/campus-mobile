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
  dynamic score;
  double mkrLong;
  double mkrLat;
  String access;
  String url;
  int mkrMarkerid;
  double distance;

  MapSearchModel({
    this.title,
    this.mkrEnabled,
    this.mkrRegion,
    this.location,
    this.description,
    this.mkrGroupid,
    this.score,
    this.mkrLong,
    this.mkrLat,
    this.access,
    this.url,
    this.mkrMarkerid,
  });

  factory MapSearchModel.fromJson(Map<String, dynamic> json) => MapSearchModel(
        title: json["title"] == null ? null : json["title"],
        mkrEnabled: json["mkrEnabled"] == null ? null : json["mkrEnabled"],
        mkrRegion: json["mkrRegion"] == null ? null : json["mkrRegion"],
        location: json["location"] == null ? null : json["location"],
        description: json["description"] == null ? null : json["description"],
        mkrGroupid: json["mkrGroupid"] == null ? null : json["mkrGroupid"],
        score: json["score"],
        mkrLong: json["mkrLong"] == null ? null : json["mkrLong"].toDouble(),
        mkrLat: json["mkrLat"] == null ? null : json["mkrLat"].toDouble(),
        access: json["access"] == null ? null : json["access"],
        url: json["url"] == null ? null : json["url"],
        mkrMarkerid: json["mkrMarkerid"] == null ? null : json["mkrMarkerid"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "mkrEnabled": mkrEnabled == null ? null : mkrEnabled,
        "mkrRegion": mkrRegion == null ? null : mkrRegion,
        "location": location == null ? null : location,
        "description": description == null ? null : description,
        "mkrGroupid": mkrGroupid == null ? null : mkrGroupid,
        "score": score,
        "mkrLong": mkrLong == null ? null : mkrLong,
        "mkrLat": mkrLat == null ? null : mkrLat,
        "access": access == null ? null : access,
        "url": url == null ? null : url,
        "mkrMarkerid": mkrMarkerid == null ? null : mkrMarkerid,
      };
}
