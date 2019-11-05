// To parse this JSON data, do
//
//     final surfModel = surfModelFromJson(jsonString);

import 'dart:convert';

SurfModel surfModelFromJson(String str) => SurfModel.fromJson(json.decode(str));

String surfModelToJson(SurfModel data) => json.encode(data.toJson());

class SurfModel {
  String forecast;
  List<Spot> spots;

  SurfModel({
    this.forecast,
    this.spots,
  });

  factory SurfModel.fromJson(Map<String, dynamic> json) => SurfModel(
        forecast: json["forecast"] == null ? null : json["forecast"],
        spots: json["spots"] == null
            ? null
            : List<Spot>.from(json["spots"].map((x) => Spot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "forecast": forecast == null ? null : forecast,
        "spots": spots == null
            ? null
            : List<dynamic>.from(spots.map((x) => x.toJson())),
      };
}

class Spot {
  String title;
  int surfMax;
  int surfMin;

  Spot({
    this.title,
    this.surfMax,
    this.surfMin,
  });

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        title: json["title"] == null ? null : json["title"],
        surfMax: json["surf_max"] == null ? null : json["surf_max"],
        surfMin: json["surf_min"] == null ? null : json["surf_min"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "surf_max": surfMax == null ? null : surfMax,
        "surf_min": surfMin == null ? null : surfMin,
      };
}
