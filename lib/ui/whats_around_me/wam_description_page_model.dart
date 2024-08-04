import 'dart:convert';

// From JSON (converts string to object so that you can access properties)
DescriptionModel descriptionModelFromJson(String str) => DescriptionModel.fromJson(json.decode(str));
// To Json (converts object to string so it can be sent)
String descriptionModelToJson(DescriptionModel data) => json.encode(data.toJson());

class DescriptionModel {
  // List to get all the places from a category (?)
  List<LocationPage>? items;

  DescriptionModel({
    this.items,
  });

  factory DescriptionModel.fromJson(Map<String, dynamic> json) => DescriptionModel(
    items: json["items"] == null
        ? null
        : List<LocationPage>.from(json["items"].map((x) => LocationPage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "items": items == null
        ? null
        : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class LocationPage {
  String? name;           // Burger King
  String? rating;         // 3.3
  String? rateCount;      // (182)
  String? category;       // Fast Food Restaurant
  String? busyness;       // (Not too busy)
  String? distance;       // 0.01 mi
  bool isOpen;            // true -> display Open
  String? closeTime;      // 17:00
  String? description;    // Well-known fast-food chain serving grilled burgers, fries & shakes.
  String? address;        // 9500 Gilman Dr, San Diego, CA 92093
  String? phoneNumber;    // 6191234567
  String? website;        // burgerking.com
  String? expense;        // $1-10 per person.
  List<String?> locationHours; // value [0] (which is of the form "10:00-17:00") is for Sunday.

  LocationPage({
    this.name,
    this.rating,
    this.rateCount,
    this.category,
    this.busyness,
    this.distance,
    this.isOpen = false,
    this.closeTime,
    this.description,
    this.address,
    this.phoneNumber,
    this.website,
    this.expense,
    required this.locationHours,
  });

  factory LocationPage.fromJson(Map<String, dynamic> json) => LocationPage(
    /// TODO: Fill in with API fields
    name: json["Loc_name"] == null ? null : json["Loc_name"],
    rating: json["Loc_name"] == null ? null : json["Loc_name"],
    rateCount: json["Loc_name"] == null ? null : json["Loc_name"],
    category: json["Loc_name"] == null ? null : json["Loc_name"],
    busyness: json["Loc_name"] == null ? null : json["Loc_name"],
    distance: json["Loc_name"] == null ? null : json["Loc_name"],
    isOpen: json["Loc_name"] == null ? null : json["Loc_name"],
    closeTime: json["Loc_name"] == null ? null : json["Loc_name"],
    description: json["Loc_name"] == null ? null : json["Loc_name"],
    address: json["Loc_name"] == null ? null : json["Loc_name"],
    phoneNumber: json["Loc_name"] == null ? null : json["Loc_name"],
    website: json["Loc_name"] == null ? null : json["Loc_name"],
    expense: json["Loc_name"] == null ? null : json["Loc_name"],
    locationHours: []
  );

  Map<String, dynamic> toJson() => {
    /// TODO: Fill in with API fields
    "api field": name == null ? null : name,
    " ": rating == null ? null : rating,
    " ": rateCount == null ? null : rateCount,
    " ": category == null ? null : category,
    " ": busyness == null ? null : busyness,
    " ": distance == null ? null : distance,
    " ": isOpen == null ? null : isOpen,
    " ": closeTime == null ? null : closeTime,
    " ": description == null ? null : description,
    " ": address == null ? null : address,
    " ": phoneNumber == null ? null : phoneNumber,
    " ": website == null ? null : website,
    " ": expense == null ? null : expense,
    " ": locationHours == null ? null : locationHours,
  };
}
