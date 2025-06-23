// To parse this JSON data, do
//
//     final diningSpecials = diningSpecialsFromJson(jsonString);

import 'dart:convert';

List<DiningSpecial> diningSpecialsFromJson(String str) =>
    List<DiningSpecial>.from(json.decode(str).map((x) => DiningSpecial.fromJson(x)));

String diningSpecialsToJson(List<DiningSpecial> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiningSpecial {
  final String name;
  final BasicInfo basic;
  final SpecialsPromotions specialsPromotions;

  DiningSpecial({
    required this.name,
    required this.basic,
    required this.specialsPromotions,
  });

  factory DiningSpecial.fromJson(Map<String, dynamic> json) {
    return DiningSpecial(
      name: json['name'],
      basic: BasicInfo.fromJson(json['basic']),
      specialsPromotions: SpecialsPromotions.fromJson(json['specials-promotions']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'basic': basic.toJson(),
    'specials-promotions': specialsPromotions.toJson(),
  };
}

class BasicInfo {
  final String address;
  final String menuUrl;
  final GpsCoords gpsCoords;
  final String description;
  final String location;
  final String tel;
  final String url;

  BasicInfo({
    required this.address,
    required this.menuUrl,
    required this.gpsCoords,
    required this.description,
    required this.location,
    required this.tel,
    required this.url,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      address: json['address'],
      menuUrl: json['menuUrl'],
      gpsCoords: GpsCoords.fromJson(json['gpsCoords']),
      description: json['description'],
      location: json['location'],
      tel: json['tel'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'menuUrl': menuUrl,
    'gpsCoords': gpsCoords.toJson(),
    'description': description,
    'location': location,
    'tel': tel,
    'url': url,
  };
}

class GpsCoords {
  final double latitude;
  final double longitude;

  GpsCoords({
    required this.latitude,
    required this.longitude,
  });

  factory GpsCoords.fromJson(Map<String, dynamic> json) {
    return GpsCoords(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class SpecialsPromotions {
  final String specialDescription;
  final String specialTitle;
  final PromoDates promoDates;

  SpecialsPromotions({
    required this.specialDescription,
    required this.specialTitle,
    required this.promoDates,
  });

  factory SpecialsPromotions.fromJson(Map<String, dynamic> json) {
    return SpecialsPromotions(
      specialDescription: json['special-description'],
      specialTitle: json['special-title'],
      promoDates: PromoDates.fromJson(json['promo-dates']),
    );
  }

  Map<String, dynamic> toJson() => {
    'special-description': specialDescription,
    'special-title': specialTitle,
    'promo-dates': promoDates.toJson(),
  };
}

class PromoDates {
  final int startDate;
  final int endDate;

  PromoDates({
    required this.startDate,
    required this.endDate,
  });

  factory PromoDates.fromJson(Map<String, dynamic> json) {
    return PromoDates(
      startDate: json['start-date'] is int ? json['start-date'] : int.tryParse(json['start-date'] ?? '0') ?? 0,
      endDate: json['end-date'] is int ? json['end-date'] : int.tryParse(json['end-date'] ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'start-date': startDate,
    'end-date': endDate,
  };
}