// To parse this JSON data, do
//
//     final diningModel = diningModelFromJson(jsonString);

import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/location.dart';

List<DiningModel> diningModelFromJson(String str) => List<DiningModel>.from(
    json.decode(str).map((x) => DiningModel.fromJson(x)));

String diningModelToJson(List<DiningModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiningModel
{
  String name;
  String description;
  String location; // empty is valid state
  String address;
  String tel;
  RegularHours regularHours; // doesn't ever seem to be null
  List<String> paymentOptions;

  // CONFIRMED OPTIONAL
  String? id;
  Meals? meals;
  String? persistentMenu;
  SpecialHour? specialHours;

  List<Image>? images;
  Coordinates? coordinates;
  String? url;
  String? menuWebsite;
  double? distance;

  DiningModel({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.address,
    required this.tel,
    this.meals,
    this.persistentMenu,
    required this.paymentOptions,
    this.images,
    this.coordinates,
    required this.regularHours,
    this.specialHours,
    this.url,
    this.menuWebsite,
  });

  DiningModel.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        description = json["description"],
        location = json["location"],
        address = json["address"],
        tel = json["tel"],
        meals = json["meals"] == null ? null : mealsValues.map[json["meals"]],
        persistentMenu = json["persistentMenu"],
        paymentOptions = List<String>.from(json["paymentOptions"].map((x) => x)),
        images = json["images"] == null
            ? null
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        coordinates = json["coords"] == null
            ? null
            : Coordinates.fromJson(json["coords"]),
        regularHours = RegularHours.fromJson(json["regularHours"]),
        specialHours = (json["specialHours"] == null || json["specialHours"].isEmpty)
            ? null
            : SpecialHour.fromJson(json["specialHours"]),
        url = json["url"],
        menuWebsite = json["menuWebsite"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "location": location,
        "address": address,
        "tel": tel,
        "meals": meals == null ? null : mealsValues.reverse[meals!],
        "persistentMenu": persistentMenu,
        "paymentOptions": List<dynamic>.from(paymentOptions.map((x) => x)),
        "images": images == null
            ? null
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "coords": coordinates == null ? null : coordinates!.toJson(),
        "regularHours": regularHours.toJson(),
        "specialHours": specialHours?.toJson(),
        "url": url,
        "menuWebsite": menuWebsite,
        "distance": distance,
      };
}

class Image
{
  // links to different sizes of the image
  String small;
  String large;

  // TODO: no caption is valid JSON response. Should this be empty str rather than null?
  String? caption;

  Image({
    required this.small,
    required this.large,
    this.caption,
  });

  Image.fromJson(Map<String, dynamic> json)
      : small = json["small"],
        large = json["large"],
        caption = json["caption"];

  Map<String, dynamic> toJson() => {
        "small": small,
        "large": large,
        "caption": caption,
      };
}

enum Meals { BREAKFAST_LUNCH_DINNER, LUNCH_DINNER }

final mealsValues = EnumValues({
  "breakfast, lunch, dinner": Meals.BREAKFAST_LUNCH_DINNER,
  "lunch, dinner": Meals.LUNCH_DINNER
});

class RegularHours
{
  // ALL CONFIRMED OPTIONAL
  String? mon;
  String? tue;
  String? wed;
  String? thu;
  String? fri;
  String? sat;
  String? sun;

  RegularHours({
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.sat,
    this.sun,
  });

  RegularHours.fromJson(Map<String, dynamic> json)
      : mon = json["mon"],
        tue = json["tue"],
        wed = json["wed"],
        thu = json["thu"],
        fri = json["fri"],
        sat = json["sat"],
        sun = json["sun"];

  Map<String, dynamic> toJson() => {
        "mon": mon,
        "tue": tue,
        "wed": wed,
        "thu": thu,
        "fri": fri,
        "sat": sat,
        "sun": sun,
      };
}

class SpecialHour {
  String specialHoursEvent;
  String specialHoursEventDetails;

  // TODO: double check if these can ever be null
  String? specialHoursValidFrom;
  String? specialHoursValidTo;

  SpecialHour({
    required this.specialHoursEvent,
    required this.specialHoursEventDetails,
    this.specialHoursValidFrom,
    this.specialHoursValidTo
  });

  SpecialHour.fromJson(Map<String, dynamic> json)
    : specialHoursEvent = json["specialHoursEvent"],
      specialHoursEventDetails = json["specialHoursEventDetails"],
      specialHoursValidFrom = json["specialHoursValidFrom"],
      specialHoursValidTo = json["specialHoursValidTo"];

  Map<String, dynamic> toJson() => {
        "specialHoursEvent": specialHoursEvent,
        "specialHoursEventDetails": specialHoursEventDetails,
        "specialHoursValidFrom": specialHoursValidFrom,
        "specialHoursValidTo": specialHoursValidTo
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => new MapEntry(v, k));
    return reverseMap!;
  }
}
