import 'dart:convert';
// To parse this JSON data, do
//
//     final placesByCategory = placesByCategoryFromJson(jsonString);
PlacesByCategoryModel placesByCategoryFromJson(String str) => PlacesByCategoryModel.fromJson(json.decode(str));

String placesByCategoryToJson(PlacesByCategoryModel data) => json.encode(data.toJson());

class PlacesByCategoryModel {
  List<Result>? results;

  PlacesByCategoryModel({
    this.results,
  });

  factory PlacesByCategoryModel.fromJson(Map<String, dynamic> json) => PlacesByCategoryModel(
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results!.map((x) => x.toJson())),
  };
}

class Result {
  String? placeId;
  Location? location;
  List<Category>? categories;
  String? name;
  double? distance;

  Result({
    this.placeId,
    this.location,
    this.categories,
    this.name,
    this.distance,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    placeId: json["placeId"],
    location: Location.fromJson(json["location"]),
    categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
    name: json["name"],
    distance: json["distance"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "placeId": placeId,
    "location": location?.toJson(),
    "categories": List<dynamic>.from(categories!.map((x) => x.toJson())),
    "name": name,
    "distance": distance,
  };
}

class Category {
  String? categoryId;
  String? label;

  Category({
    this.categoryId,
    this.label,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    categoryId: json["categoryId"],
    label: json["label"],
  );

  Map<String, dynamic> toJson() => {
    "categoryId": categoryId,
    "label": label,
  };
}

class Location {
  double? x;
  double? y;

  Location({
    this.x,
    this.y,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    x: json["x"].toDouble(),
    y: json["y"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "x": x,
    "y": y,
  };
}