import 'dart:convert';

List<MapSearchModel> mapFeatureFromJson(String str) => List<MapSearchModel>.from(
    json.decode(str)["features"].map((x) => MapSearchModel.fromJson(x)));

String mapFeatureToJson(List<MapSearchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// The Campus Map Search API returns a list (collection) named "features"
/// that contains all the attributes and geometry for each location.
class MapSearchCollection {
  final List<MapSearchModel> features;

  MapSearchCollection({required this.features});

  factory MapSearchCollection.fromJson(Map<String, dynamic> json) {
    return MapSearchCollection(
      features: (json['features'] as List<dynamic>)
          .map((e) => MapSearchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'features': features.map((f) => f.toJson()).toList(),
      };
}

class MapSearchModel {
  final Attributes attributes;
  final Geometry geometry;
  double? distance;
  int? mkrMarkerid;

  MapSearchModel({
    required this.attributes,
    required this.geometry,
    this.distance,
    this.mkrMarkerid,
  });

  factory MapSearchModel.fromJson(Map<String, dynamic> json) {
    return MapSearchModel(
      attributes: Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      mkrMarkerid: json['mkrMarkerid'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'attributes': attributes.toJson(),
        'geometry': geometry.toJson(),
        if (distance != null) 'distance': distance,
        if (mkrMarkerid != null) 'mkrMarkerid': mkrMarkerid,
      };

  @override
  String toString() {
    return 'MapSearchModel(attributes: $attributes, geometry: $geometry, distance: $distance, mkrMarkerid: $mkrMarkerid)';
  }
}

class Attributes {
  final int ObjectId;
  final String? UpdatedName;
  final String? Description;
  final String? Class;
  final String? Subclass;
  final String? UpdatedKeywords;
  final String? URL;
  final String? ContactInformation;
  final String? Floor;
  final String? ConnectionCodes;
  final String? ClassroomCodes;
  final String? TritonPlusAccepted;
  final double? Latitude;
  final double? Longitude;
  final String? FacilityLongName;
  final String? BuildingAliases;
  final String? StreetAddress;
  final String? City;
  final String? Zipcode;
  final String? TopResult;

  Attributes({
    required this.ObjectId,
    this.UpdatedName,
    this.Description,
    this.Class,
    this.Subclass,
    this.UpdatedKeywords,
    this.URL,
    this.ContactInformation,
    this.Floor,
    this.ConnectionCodes,
    this.ClassroomCodes,
    this.TritonPlusAccepted,
    this.Latitude,
    this.Longitude,
    this.FacilityLongName,
    this.BuildingAliases,
    this.StreetAddress,
    this.City,
    this.Zipcode,
    this.TopResult,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      ObjectId: json['OBJECTID'] as int,
      UpdatedName: json['UpdatedName'] as String?,
      Description: json['Description'] as String?,
      Class: json['Class'] as String,
      Subclass: json['Subclass'] as String,
      UpdatedKeywords: json['UpdatedKeywords'] as String?,
      URL: json['URL'] as String?,
      ContactInformation: json['ContactInformation'] as String?,
      Floor: json['Floor'] as String?,
      ConnectionCodes: json['ConnectionCodes'] as String?,
      ClassroomCodes: json['ClassroomCodes'] as String?,
      TritonPlusAccepted: json['TritonPlusAccepted']?.toString(),
      Latitude: (json['Latitude'] as num).toDouble(),
      Longitude: (json['Longitude'] as num).toDouble(),
      FacilityLongName: json['FacilityLongName'] as String?,
      BuildingAliases: json['BuildingAliases'] as String?,
      StreetAddress: json['StreetAddress'] as String?,
      City: json['City'] as String?,
      Zipcode: json['Zipcode'] as String?,
      TopResult: json['TopResult']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'OBJECTID': ObjectId,
        'UpdatedName': UpdatedName,
        'Description': Description,
        'Class': Class,
        'Subclass': Subclass,
        'UpdatedKeywords': UpdatedKeywords,
        'URL': URL,
        'ContactInformation': ContactInformation,
        'Floor': Floor,
        'ConnectionCodes': ConnectionCodes,
        'ClassroomCodes': ClassroomCodes,
        'TritonPlusAccepted': TritonPlusAccepted,
        'Latitude': Latitude,
        'Longitude': Longitude,
        'FacilityLongName': FacilityLongName,
        'BuildingAliases': BuildingAliases,
        'StreetAddress': StreetAddress,
        'City': City,
        'Zipcode': Zipcode,
        'TopResult': TopResult,
      };

  @override
  String toString() {
    return 'Attributes(ObjectId: $ObjectId, UpdatedName: $UpdatedName, Class: $Class, Subclass: $Subclass, Latitude: $Latitude, Longitude: $Longitude, FacilityLongName: $FacilityLongName)';
  }
}

class Geometry {
  final double x;
  final double y;

  Geometry({required this.x, required this.y});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };

  @override
  String toString() {
    return 'Geometry(x: $x, y: $y)';
  }
}
