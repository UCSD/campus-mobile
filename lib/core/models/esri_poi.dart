import 'dart:convert';

List<EsriPOIModel> esriPOIModelFromJson(String str) =>
    List<EsriPOIModel>.from(json.decode(str)["features"].map((x) => EsriPOIModel.fromJson(x)));

String esriPOIModelToJson(List<EsriPOIModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EsriPOIModel {
  Attributes attributes;
  Geometry geometry;

  EsriPOIModel({
    required this.attributes,
    required this.geometry,
  });

  factory EsriPOIModel.fromJson(Map<String, dynamic> json) => EsriPOIModel(
        attributes: Attributes.fromJson(json["attributes"]),
        geometry: Geometry.fromJson(json["geometry"]),
      );

  Map<String, dynamic> toJson() => {
        "attributes": attributes.toJson(),
        "geometry": geometry.toJson(),
      };

  @override
  String toString() {
    return 'EsriPOIModel(attributes: $attributes, geometry: $geometry)';
  }
}

class Attributes {
  int objectId;
  String? c3dName;
  String? updatedName;
  double? c3dMarkerId;
  String? c3dCategories;
  String? classType;
  String? subclass;
  String? c3dKeywords;
  String? updatedKeywords;
  String? c3dDescription;
  String? url;
  String? contactInformation;
  String? floor;
  String? connectionCodes;
  String? classroomCodes;
  String? mailCode;
  String? tritonPlusAccepted;
  String? status;
  double? latitude;
  double? longitude;
  String? issues;
  String? notesQuestions;
  int? subtypeId;
  String? globalId;
  String? createdUser;
  String? createdDate;
  String? lastEditedUser;
  String? lastEditedDate;

  Attributes({
    required this.objectId,
    this.c3dName,
    this.updatedName,
    this.c3dMarkerId,
    this.c3dCategories,
    this.classType,
    this.subclass,
    this.c3dKeywords,
    this.updatedKeywords,
    this.c3dDescription,
    this.url,
    this.contactInformation,
    this.floor,
    this.connectionCodes,
    this.classroomCodes,
    this.mailCode,
    this.tritonPlusAccepted,
    this.status,
    this.latitude,
    this.longitude,
    this.issues,
    this.notesQuestions,
    this.subtypeId,
    this.globalId,
    this.createdUser,
    this.createdDate,
    this.lastEditedUser,
    this.lastEditedDate,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        objectId: json["OBJECTID"],
        c3dName: json["C3DName"],
        updatedName: json["UpdatedName"],
        c3dMarkerId: json["C3DMarkerID"]?.toDouble(),
        c3dCategories: json["C3DCategories"],
        classType: json["Class"],
        subclass: json["Subclass"],
        c3dKeywords: json["C3DKeywords"],
        updatedKeywords: json["UpdatedKeywords"],
        c3dDescription: json["C3DDescription"],
        url: json["URL"],
        contactInformation: json["ContactInformation"],
        floor: json["Floor"],
        connectionCodes: json["ConnectionCodes"],
        classroomCodes: json["ClassroomCodes"],
        mailCode: json["MailCode"],
        tritonPlusAccepted: json["TritonPlusAccepted"],
        status: json["Status"],
        latitude: json["Latitude"]?.toDouble(),
        longitude: json["Longitude"]?.toDouble(),
        issues: json["Issues"],
        notesQuestions: json["NotesQuestions"],
        subtypeId: json["SubtypeID"],
        globalId: json["GlobalID"],
        createdUser: json["created_user"],
        createdDate: json["created_date"],
        lastEditedUser: json["last_edited_user"],
        lastEditedDate: json["last_edited_date"],
      );

  Map<String, dynamic> toJson() => {
        "OBJECTID": objectId,
        "C3DName": c3dName,
        "UpdatedName": updatedName,
        "C3DMarkerID": c3dMarkerId,
        "C3DCategories": c3dCategories,
        "Class": classType,
        "Subclass": subclass,
        "C3DKeywords": c3dKeywords,
        "UpdatedKeywords": updatedKeywords,
        "C3DDescription": c3dDescription,
        "URL": url,
        "ContactInformation": contactInformation,
        "Floor": floor,
        "ConnectionCodes": connectionCodes,
        "ClassroomCodes": classroomCodes,
        "MailCode": mailCode,
        "TritonPlusAccepted": tritonPlusAccepted,
        "Status": status,
        "Latitude": latitude,
        "Longitude": longitude,
        "Issues": issues,
        "NotesQuestions": notesQuestions,
        "SubtypeID": subtypeId,
        "GlobalID": globalId,
        "created_user": createdUser,
        "created_date": createdDate,
        "last_edited_user": lastEditedUser,
        "last_edited_date": lastEditedDate,
      };

  @override
  String toString() {
    return 'Attributes(objectId: $objectId, c3dName: $c3dName, updatedName: $updatedName, latitude: $latitude, longitude: $longitude)';
  }
}

class Geometry {
  double x;
  double y;

  Geometry({
    required this.x,
    required this.y,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        x: json["x"]?.toDouble(),
        y: json["y"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };

  @override
  String toString() {
    return 'Geometry(x: $x, y: $y)';
  }
}