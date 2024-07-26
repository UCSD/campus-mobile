import 'dart:convert';

IAmGoingModel iAmGoingModelFromJson(String str) =>
    IAmGoingModel.fromJson(json.decode(str));

String freeFoodModelToJson(IAmGoingModel data) => json.encode(data.toJson());

class IAmGoingModel {
  int? statusCode;
  Body? body;

  IAmGoingModel({
    this.statusCode,
    this.body,
  });

  factory IAmGoingModel.fromJson(Map<String, dynamic> json) => IAmGoingModel(
    statusCode: json["statusCode"],
    body: Body.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "body": body!.toJson(),
  };
}

class Body {
  int? count;
  int? maxCount;

  Body({this.count, this.maxCount});

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    count: json["count"],
    maxCount: json["maxCount"],
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "maxCount": maxCount,
  };
}