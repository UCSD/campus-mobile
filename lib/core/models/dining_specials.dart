// To parse this JSON data, do
//
//     final diningSpecials = diningSpecialsFromJson(jsonString);

import 'dart:convert';

DiningData diningDataFromJson(String str) => DiningData.fromJson(json.decode(str));
String diningDataToJson(DiningData data) => json.encode(data.toJson());

class DiningData {
  final String summary;
  final String author;
  final int createdOn;
  final String link;
  final int lastPublishedOn;
  final bool isPublished;
  final String title;
  final String path;
  final int lastModified;
  final SystemDataStructure systemDataStructure; // Specials information is here
  final String site;
  final String lastPublishedBy;
  final String displayName;
  final String name;
  final String lastModifiedBy;
  final String createdBy;

  DiningData({
    required this.summary,
    required this.author,
    required this.createdOn,
    required this.link,
    required this.lastPublishedOn,
    required this.isPublished,
    required this.title,
    required this.path,
    required this.lastModified,
    required this.systemDataStructure,
    required this.site,
    required this.lastPublishedBy,
    required this.displayName,
    required this.name,
    required this.lastModifiedBy,
    required this.createdBy,
  });

  factory DiningData.fromJson(Map<String, dynamic> json) => DiningData(
    summary: json['summary'] ?? '',
    author: json['author'] ?? '',
    createdOn: json['created-on'] ?? 0,
    link: json['link'] ?? '',
    lastPublishedOn: json['last-published-on'] ?? 0,
    isPublished: json['is-published'] ?? false,
    title: json['title'] ?? '',
    path: json['path'] ?? '',
    lastModified: json['last-modified'] ?? 0,
    systemDataStructure: SystemDataStructure.fromJson(json['system-data-structure'] ?? {}),
    site: json['site'] ?? '',
    lastPublishedBy: json['last-published-by'] ?? '',
    displayName: json['display-name'] ?? '',
    name: json['name'] ?? '',
    lastModifiedBy: json['last-modified-by'] ?? '',
    createdBy: json['created-by'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'summary': summary,
    'author': author,
    'created-on': createdOn,
    'link': link,
    'last-published-on': lastPublishedOn,
    'is-published': isPublished,
    'title': title,
    'path': path,
    'last-modified': lastModified,
    'system-data-structure': systemDataStructure.toJson(),
    'site': site,
    'last-published-by': lastPublishedBy,
    'display-name': displayName,
    'name': name,
    'last-modified-by': lastModifiedBy,
    'created-by': createdBy,
  };
}

class SystemDataStructure {
  final NavBlocks navBlocks;
  final Notes notes;
  final MiddleBlocks middleBlocks;
  final AdditionalContent? additionalContent;
  final PageComponents? pageComponents;
  final Introduction? introduction;
  final String? definitionPath;

  SystemDataStructure({
    required this.navBlocks,
    required this.notes,
    required this.middleBlocks,
    this.additionalContent,
    this.pageComponents,
    this.introduction,
    this.definitionPath,
  });

  factory SystemDataStructure.fromJson(Map<String, dynamic> json) => SystemDataStructure(
    navBlocks: NavBlocks.fromJson(json['nav-blocks'] ?? {}),
    notes: Notes.fromJson(json['notes'] ?? {}),
    middleBlocks: MiddleBlocks.fromJson(json['middle-blocks'] ?? {}),
    additionalContent: json['additional-content'] != null ? AdditionalContent.fromJson(json['additional-content']) : null,
    pageComponents: json['page-components'] != null ? PageComponents.fromJson(json['page-components']) : null,
    introduction: json['introduction'] != null ? Introduction.fromJson(json['introduction']) : null,
    definitionPath: json['definition-path'],
  );

  Map<String, dynamic> toJson() => {
    'nav-blocks': navBlocks.toJson(),
    'notes': notes.toJson(),
    'middle-blocks': middleBlocks.toJson(),
    if (additionalContent != null) 'additional-content': additionalContent!.toJson(),
    if (pageComponents != null) 'page-components': pageComponents!.toJson(),
    if (introduction != null) 'introduction': introduction!.toJson(),
    if (definitionPath != null) 'definition-path': definitionPath,
  };
}

class AdditionalContent {
  AdditionalContent();

  factory AdditionalContent.fromJson(Map<String, dynamic> json) => AdditionalContent();

  Map<String, dynamic> toJson() => {};
}

class PageComponents {
  PageComponents();

  factory PageComponents.fromJson(Map<String, dynamic> json) => PageComponents();

  Map<String, dynamic> toJson() => {};
}

class Introduction {
  Introduction();

  factory Introduction.fromJson(Map<String, dynamic> json) => Introduction();

  Map<String, dynamic> toJson() => {};
}

class NavBlocks {
  final Map<String, dynamic> defaultBlock;
  final String blockType;
  final String custom;
  final String navType;

  NavBlocks({
    required this.defaultBlock,
    required this.blockType,
    required this.custom,
    required this.navType,
  });

  factory NavBlocks.fromJson(Map<String, dynamic> json) => NavBlocks(
    defaultBlock: json['default'] ?? {},
    blockType: json['block-type'] ?? '',
    custom: json['custom'] ?? '',
    navType: json['nav-type'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'default': defaultBlock,
    'block-type': blockType,
    'custom': custom,
    'nav-type': navType,
  };
}

class Notes {
  final String note;

  Notes({required this.note});

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
    note: json['note'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'note': note,
  };
}

class MiddleBlocks {
  final List<Eatery> eatery;

  MiddleBlocks({required this.eatery});

  factory MiddleBlocks.fromJson(Map<String, dynamic> json) => MiddleBlocks(
    eatery: (json['eatery'] as List<dynamic>? ?? [])
        .map((e) => Eatery.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'eatery': eatery.map((e) => e.toJson()).toList(),
  };
}

class Eatery {
  final Hours hours;
  final PaymentOptions paymentOptions;
  final String name;
  final BasicInfo basic;
  final SpecialsPromotions specialsPromotions;

  Eatery({
    required this.hours,
    required this.paymentOptions,
    required this.name,
    required this.basic,
    required this.specialsPromotions,
  });

  factory Eatery.fromJson(Map<String, dynamic> json) => Eatery(
    hours: Hours.fromJson(json['hours'] ?? {}),
    paymentOptions: PaymentOptions.fromJson(json['paymentOptions'] ?? {}),
    name: json['name'] ?? '',
    basic: BasicInfo.fromJson(json['basic'] ?? {}),
    specialsPromotions: SpecialsPromotions.fromJson(json['specials-promotions'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'hours': hours.toJson(),
    'paymentOptions': paymentOptions.toJson(),
    'name': name,
    'basic': basic.toJson(),
    'specials-promotions': specialsPromotions.toJson(),
  };
}

class SpecialsPromotions {
  SpecialsPromotions();

  factory SpecialsPromotions.fromJson(Map<String, dynamic> json) => SpecialsPromotions();

  Map<String, dynamic> toJson() => {};
}

class Hours {
  final RegularHours regularHours;
  final SpecialHours specialHours;

  Hours({
    required this.regularHours,
    required this.specialHours,
  });

  factory Hours.fromJson(Map<String, dynamic> json) => Hours(
    regularHours: RegularHours.fromJson(json['regularHours'] ?? {}),
    specialHours: SpecialHours.fromJson(json['specialHours'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'regularHours': regularHours.toJson(),
    'specialHours': specialHours.toJson(),
  };
}

class PaymentOptions {
  final List<String> paymentMethods;

  PaymentOptions({required this.paymentMethods});

  factory PaymentOptions.fromJson(Map<String, dynamic> json) {
    final methods = json['paymentMethods'];
    if (methods is List) {
      return PaymentOptions(paymentMethods: methods.map((e) => e.toString()).toList());
    } else if (methods is String) {
      return PaymentOptions(paymentMethods: methods.split(',').map((e) => e.trim()).toList());
    }
    return PaymentOptions(paymentMethods: []);
  }

  Map<String, dynamic> toJson() => {
    'paymentMethods': paymentMethods,
  };
}

class RegularHours {
  final String thu;
  final DayHours sunHours;
  final String tue;
  final DayHours friHours;
  final String sat;
  final DayHours wedHours;
  final DayHours satHours;
  final DayHours thuHours;
  final String mon;
  final String sun;
  final DayHours tueHours;
  final DayHours monHours;
  final String wed;
  final String fri;

  RegularHours({
    required this.thu,
    required this.sunHours,
    required this.tue,
    required this.friHours,
    required this.sat,
    required this.wedHours,
    required this.satHours,
    required this.thuHours,
    required this.mon,
    required this.sun,
    required this.tueHours,
    required this.monHours,
    required this.wed,
    required this.fri,
  });

  factory RegularHours.fromJson(Map<String, dynamic> json) => RegularHours(
    thu: json['thu'] ?? '',
    sunHours: DayHours.fromJson(json['sunHours'] ?? {}),
    tue: json['tue'] ?? '',
    friHours: DayHours.fromJson(json['friHours'] ?? {}),
    sat: json['sat'] ?? '',
    wedHours: DayHours.fromJson(json['wedHours'] ?? {}),
    satHours: DayHours.fromJson(json['satHours'] ?? {}),
    thuHours: DayHours.fromJson(json['thuHours'] ?? {}),
    mon: json['mon'] ?? '',
    sun: json['sun'] ?? '',
    tueHours: DayHours.fromJson(json['tueHours'] ?? {}),
    monHours: DayHours.fromJson(json['monHours'] ?? {}),
    wed: json['wed'] ?? '',
    fri: json['fri'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'thu': thu,
    'sunHours': sunHours.toJson(),
    'tue': tue,
    'friHours': friHours.toJson(),
    'sat': sat,
    'wedHours': wedHours.toJson(),
    'satHours': satHours.toJson(),
    'thuHours': thuHours.toJson(),
    'mon': mon,
    'sun': sun,
    'tueHours': tueHours.toJson(),
    'monHours': monHours.toJson(),
    'wed': wed,
    'fri': fri,
  };
}

class DayHours {
  final String closingAmPm;
  final String closeTime;
  final String openingAmPm;
  final String openTime;

  DayHours({
    required this.closingAmPm,
    required this.closeTime,
    required this.openingAmPm,
    required this.openTime,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) => DayHours(
    closingAmPm: json['closingAmPm'] ?? '',
    closeTime: json['closeTime'] ?? '',
    openingAmPm: json['openingAmPm'] ?? '',
    openTime: json['openTime'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'closingAmPm': closingAmPm,
    'closeTime': closeTime,
    'openingAmPm': openingAmPm,
    'openTime': openTime,
  };
}

class SpecialHours {
  final SpecialEvent specialEvent;
  final String areSpecialHours;

  SpecialHours({
    required this.specialEvent,
    required this.areSpecialHours,
  });

  factory SpecialHours.fromJson(Map<String, dynamic> json) => SpecialHours(
    specialEvent: SpecialEvent.fromJson(json['specialEvent'] ?? {}),
    areSpecialHours: json['areSpecialHours'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'specialEvent': specialEvent.toJson(),
    'areSpecialHours': areSpecialHours,
  };
}

class SpecialEvent {
  final String eventDescription;
  final String eventName;

  SpecialEvent({
    required this.eventDescription,
    required this.eventName,
  });

  factory SpecialEvent.fromJson(Map<String, dynamic> json) => SpecialEvent(
    eventDescription: json['eventDescription'] ?? '',
    eventName: json['eventName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'eventDescription': eventDescription,
    'eventName': eventName,
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

  factory BasicInfo.fromJson(Map<String, dynamic> json) => BasicInfo(
    address: json['address'] ?? '',
    menuUrl: json['menuUrl'] ?? '',
    gpsCoords: GpsCoords.fromJson(json['gpsCoords'] ?? {}),
    description: json['description'] ?? '',
    location: json['location'] ?? '',
    tel: json['tel'] ?? '',
    url: json['url'] ?? '',
  );

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
  final double? latitude;
  final double? longitude;

  GpsCoords({
    this.latitude,
    this.longitude,
  });

  factory GpsCoords.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic value) {
      if (value == null || value == '') return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }
    return GpsCoords(
      latitude: parseCoord(json['latitude']),
      longitude: parseCoord(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

