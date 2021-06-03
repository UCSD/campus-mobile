// To parse this JSON data, do
//
//     final diningModel = diningModelFromJson(jsonString);

import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/location.dart';

List<DiningModel> diningModelFromJson(String str) => List<DiningModel>.from(
    json.decode(str).map((x) => DiningModel.fromJson(x)));

String diningModelToJson(List<DiningModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiningModel {
  String? id;
  String? name;
  String? description;
  String? location;
  String? address;
  String? tel;
  Meals? meals;
  String? persistentMenu;
  List<String>? paymentOptions;
  List<Image>? images;
  Coordinates? coordinates;
  RegularHours? regularHours;
  List<SpecialHour>? specialHours;
  String? url;
  String? menuWebsite;
  double? distance;

  DiningModel({
    this.id,
    this.name,
    this.description,
    this.location,
    this.address,
    this.tel,
    this.meals,
    this.persistentMenu,
    this.paymentOptions,
    this.images,
    this.coordinates,
    this.regularHours,
    this.specialHours,
    this.url,
    this.menuWebsite,
  });

  factory DiningModel.fromJson(Map<String, dynamic> json) => DiningModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        location: json["location"] == null ? null : json["location"],
        address: json["address"] == null ? null : json["address"],
        tel: json["tel"] == null ? null : json["tel"],
        meals: json["meals"] == null ? null : mealsValues.map[json["meals"]],
        persistentMenu:
            json["persistentMenu"] == null ? null : json["persistentMenu"],
        paymentOptions: json["paymentOptions"] == null
            ? null
            : List<String>.from(json["paymentOptions"].map((x) => x)),
        images: json["images"] == null
            ? null
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        coordinates: json["coords"] == null
            ? null
            : Coordinates.fromJson(json["coords"]),
        regularHours: json["regularHours"] == null
            ? null
            : RegularHours.fromJson(json["regularHours"]),
        specialHours: json["specialHours"] == null
            ? null
            : List<SpecialHour>.from(
                json["specialHours"].map((x) => SpecialHour.fromJson(x))),
        url: json["url"] == null ? null : json["url"],
        menuWebsite: json["menuWebsite"] == null ? null : json["menuWebsite"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "location": location == null ? null : location,
        "address": address == null ? null : address,
        "tel": tel == null ? null : tel,
        "meals": meals == null ? null : mealsValues.reverse![meals!],
        "persistentMenu": persistentMenu == null ? null : persistentMenu,
        "paymentOptions": paymentOptions == null
            ? null
            : List<dynamic>.from(paymentOptions!.map((x) => x)),
        "images": images == null
            ? null
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "coords": coordinates == null ? null : coordinates!.toJson(),
        "regularHours": regularHours == null ? null : regularHours!.toJson(),
        "specialHours": specialHours == null
            ? null
            : List<dynamic>.from(specialHours!.map((x) => x.toJson())),
        "url": url == null ? null : url,
        "menuWebsite": menuWebsite == null ? null : menuWebsite,
        "distance": distance == null ? null : distance,
      };
}

class Image {
  String? small;
  String? large;
  String? caption;

  Image({
    this.small,
    this.large,
    this.caption,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        small: json["small"] == null ? null : json["small"],
        large: json["large"] == null ? null : json["large"],
        caption: json["caption"] == null ? null : json["caption"],
      );

  Map<String, dynamic> toJson() => {
        "small": small == null ? null : small,
        "large": large == null ? null : large,
        "caption": caption == null ? null : caption,
      };
}

enum Meals { BREAKFAST_LUNCH_DINNER, LUNCH_DINNER }

final mealsValues = EnumValues({
  "breakfast, lunch, dinner": Meals.BREAKFAST_LUNCH_DINNER,
  "lunch, dinner": Meals.LUNCH_DINNER
});

class RegularHours {
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

  factory RegularHours.fromJson(Map<String, dynamic> json) => RegularHours(
        mon: json["mon"] == null ? null : json["mon"],
        tue: json["tue"] == null ? null : json["tue"],
        wed: json["wed"] == null ? null : json["wed"],
        thu: json["thu"] == null ? null : json["thu"],
        fri: json["fri"] == null ? null : json["fri"],
        sat: json["sat"] == null ? null : json["sat"],
        sun: json["sun"] == null ? null : json["sun"],
      );

  Map<String, dynamic> toJson() => {
        "mon": mon == null ? null : mon,
        "tue": tue == null ? null : tue,
        "wed": wed == null ? null : wed,
        "thu": thu == null ? null : thu,
        "fri": fri == null ? null : fri,
        "sat": sat == null ? null : sat,
        "sun": sun == null ? null : sun,
      };
}

class SpecialHour {
  String? title;
  String? hours;

  SpecialHour({
    this.title,
    this.hours,
  });

  factory SpecialHour.fromJson(Map<String, dynamic> json) => SpecialHour(
        title: json["title"] == null ? null : json["title"],
        hours: json["hours"] == null ? null : json["hours"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "hours": hours == null ? null : hours,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
