import 'dart:convert';

// To parse this JSON data, do
//
//     final placeDetails = placeDetailsFromJson(jsonString);

PlaceDetails placeDetailsFromJson(String str) => PlaceDetails.fromJson(json.decode(str));

String placeDetailsToJson(PlaceDetails data) => json.encode(data.toJson());

class PlaceDetails {
  PlaceDetailsClass placeDetails;

  PlaceDetails({
    required this.placeDetails,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) => PlaceDetails(
    placeDetails: PlaceDetailsClass.fromJson(json["placeDetails"]),
  );

  Map<String, dynamic> toJson() => {
    "placeDetails": placeDetails.toJson(),
  };
}

class PlaceDetailsClass {
  String placeId;
  Address address;
  Location location;
  List<Category> categories;
  String name;
  String description;
  ContactInfo contactInfo;
  SocialMedia socialMedia;
  Rating rating;
  Hours hours;

  PlaceDetailsClass({
    required this.placeId,
    required this.address,
    required this.location,
    required this.categories,
    required this.name,
    required this.description,
    required this.contactInfo,
    required this.socialMedia,
    required this.rating,
    required this.hours,
  });

  factory PlaceDetailsClass.fromJson(Map<String, dynamic> json) => PlaceDetailsClass(
    placeId: json["placeId"],
    address: Address.fromJson(json["address"]),
    location: Location.fromJson(json["location"]),
    categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
    name: json["name"],
    description: json["description"],
    contactInfo: ContactInfo.fromJson(json["contactInfo"]),
    socialMedia: SocialMedia.fromJson(json["socialMedia"]),
    rating: Rating.fromJson(json["rating"]),
    hours: Hours.fromJson(json["hours"]),
  );

  Map<String, dynamic> toJson() => {
    "placeId": placeId,
    "address": address.toJson(),
    "location": location.toJson(),
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "name": name,
    "description": description,
    "contactInfo": contactInfo.toJson(),
    "socialMedia": socialMedia.toJson(),
    "rating": rating.toJson(),
    "hours": hours.toJson(),
  };
}

class Address {
  String streetAddress;
  String locality;
  String designatedMarketArea;
  String region;
  String postcode;
  dynamic poBox;
  String country;

  Address({
    required this.streetAddress,
    required this.locality,
    required this.designatedMarketArea,
    required this.region,
    required this.postcode,
    required this.poBox,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    streetAddress: json["streetAddress"],
    locality: json["locality"],
    designatedMarketArea: json["designatedMarketArea"],
    region: json["region"],
    postcode: json["postcode"],
    poBox: json["poBox"],
    country: json["country"],
  );

  Map<String, dynamic> toJson() => {
    "streetAddress": streetAddress,
    "locality": locality,
    "designatedMarketArea": designatedMarketArea,
    "region": region,
    "postcode": postcode,
    "poBox": poBox,
    "country": country,
  };
}

class Category {
  String categoryId;
  String label;

  Category({
    required this.categoryId,
    required this.label,
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

class ContactInfo {
  String telephone;
  String website;
  String fax;
  String email;

  ContactInfo({
    required this.telephone,
    required this.website,
    required this.fax,
    required this.email,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    telephone: json["telephone"],
    website: json["website"],
    fax: json["fax"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "telephone": telephone,
    "website": website,
    "fax": fax,
    "email": email,
  };
}

class Hours {
  String opening;
  String popular;
  String openingText;

  Hours({
    required this.opening,
    required this.popular,
    required this.openingText,
  });

  factory Hours.fromJson(Map<String, dynamic> json) => Hours(
    opening: json["opening"],
    popular: json["popular"],
    openingText: json["openingText"],
  );

  Map<String, dynamic> toJson() => {
    "opening": opening,
    "popular": popular,
    "openingText": openingText,
  };
}

class Location {
  double x;
  double y;

  Location({
    required this.x,
    required this.y,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    x: json["x"]?.toDouble(),
    y: json["y"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "x": x,
    "y": y,
  };
}

class Rating {
  dynamic price;
  double user;

  Rating({
    required this.price,
    required this.user,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    price: json["price"],
    user: json["user"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "user": user,
  };
}

class SocialMedia {
  String facebookId;
  String twitter;
  String instagram;

  SocialMedia({
    required this.facebookId,
    required this.twitter,
    required this.instagram,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) => SocialMedia(
    facebookId: json["facebookId"],
    twitter: json["twitter"],
    instagram: json["instagram"],
  );

  Map<String, dynamic> toJson() => {
    "facebookId": facebookId,
    "twitter": twitter,
    "instagram": instagram,
  };
}
