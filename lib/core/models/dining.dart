import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/location.dart';

// To parse this JSON data, do
//
//     final diningModel = diningModelFromJson(jsonString);

List<DiningModel> diningModelFromJson(String str) =>
    List<DiningModel>.from(json.decode(str).map((x) => DiningModel.fromJson(x)));

String diningModelToJson(List<DiningModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiningModel {
  String address;
  String description;
  String location; // empty is valid state
  String name;
  List<String> paymentOptions;
  String paymentFilterTypes;
  RegularHours regularHours; // doesn't ever seem to be null
  String tel;
  // CONFIRMED OPTIONAL
  Coordinates? coordinates;
  double? distance;
  String? id;
  List<Image>? images;
  Meals? meals;
  String? menuWebsite;
  String? persistentMenu;
  SpecialHour? specialHours;
  Specials? specials;
  String? subLocationNum;
  String? url;
  String? vendorLogo;

  DiningModel({
    required this.address,
    required this.description,
    required this.location,
    required this.name,
    required this.paymentFilterTypes,
    required this.paymentOptions,
    required this.regularHours,
    required this.tel,
    this.coordinates,
    this.id,
    this.images,
    this.meals,
    this.menuWebsite,
    this.persistentMenu,
    this.specialHours,
    this.specials,
    this.url,
    this.vendorLogo,
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
      paymentFilterTypes = json["paymentFilterTypes"],
      images = json["images"] == null
          ? null
          : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
      coordinates = json["coords"] == null ? null : Coordinates.fromJson(json["coords"]),
      regularHours = RegularHours.fromJson(json["regularHours"]),
      specialHours = (json["specialHours"] == null || json["specialHours"].isEmpty)
          ? null
          : SpecialHour.fromJson(json["specialHours"]),
      vendorLogo = json["vendorLogo"],
      url = json["url"],
      menuWebsite = json["menuWebsite"],
      specials = json["specials"] == null ? null : Specials.fromJson(json["specials"]);

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
    "paymentFilterTypes": paymentFilterTypes,
    "images": images == null ? null : List<dynamic>.from(images!.map((x) => x.toJson())),
    "coords": coordinates == null ? null : coordinates!.toJson(),
    "regularHours": regularHours.toJson(),
    "specialHours": specialHours?.toJson(),
    "url": url,
    "vendorLogo": vendorLogo,
    "menuWebsite": menuWebsite,
    "distance": distance,
    "specials": specials?.toJson(),
  };
}

class Image {
  // links to different sizes of the image
  // TODO: BUG ON SERVER?? There have been images with no images observed in the wild...
  String? small;
  String? large;
  // TODO: no caption is valid JSON response. Should this be empty str rather than null?
  String? caption;

  Image({this.small, this.large, this.caption});

  Image.fromJson(Map<String, dynamic> json)
    : small = json["small"],
      large = json["large"],
      caption = json["caption"];

  Map<String, dynamic> toJson() => {"small": small, "large": large, "caption": caption};
}

enum Meals { BREAKFAST_LUNCH_DINNER, LUNCH_DINNER }

final mealsValues = EnumValues({
  "breakfast, lunch, dinner": Meals.BREAKFAST_LUNCH_DINNER,
  "lunch, dinner": Meals.LUNCH_DINNER,
});

class RegularHours {
  // ALL CONFIRMED OPTIONAL
  String? mon;
  String? tue;
  String? wed;
  String? thu;
  String? fri;
  String? sat;
  String? sun;

  RegularHours({this.mon, this.tue, this.wed, this.thu, this.fri, this.sat, this.sun});

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
    this.specialHoursValidTo,
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
    "specialHoursValidTo": specialHoursValidTo,
  };
}

class Specials {
  String? specialDescription;
  String? specialTitle;
  PromoDates? promoDates;

  Specials({this.specialDescription, this.specialTitle, this.promoDates});

  Specials.fromJson(Map<String, dynamic> json)
    : specialDescription = json["specialDescription"],
      specialTitle = json["specialTitle"],
      promoDates = json["promoDates"] == null ? null : PromoDates.fromJson(json["promoDates"]);

  Map<String, dynamic> toJson() => {
    "specialDescription": specialDescription,
    "specialTitle": specialTitle,
    "promoDates": promoDates?.toJson(),
  };
}

class PromoDates {
  int? startDate;
  int? endDate;

  PromoDates({this.startDate, this.endDate});

  PromoDates.fromJson(Map<String, dynamic> json)
    : startDate = json["startDate"] is String ? int.tryParse(json["startDate"]) : json["startDate"],
      endDate = json["endDate"] is String ? int.tryParse(json["endDate"]) : json["endDate"];

  Map<String, dynamic> toJson() => {"startDate": startDate, "endDate": endDate};
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
