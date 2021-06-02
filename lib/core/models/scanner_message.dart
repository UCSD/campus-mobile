import 'dart:convert';

ScannerMessageModel scannerMessageModelFromJson(String str) =>
    ScannerMessageModel.fromJson(json.decode(str));

String scannerMessageModelToJson(ScannerMessageModel data) =>
    json.encode(data.toJson());

class ScannerMessageModel {
  ScannerMessageModel({this.collectionTime});

  String? collectionTime;

  factory ScannerMessageModel.fromJson(Map<String, dynamic> json) =>
      ScannerMessageModel(
        collectionTime: json["Collection Date/Time"] == null
            ? ""
            : json["Collection Date/Time"],
      );

  Map<String, dynamic> toJson() => {
        "Collection Date/Time": collectionTime == null ? "" : collectionTime,
      };
}
