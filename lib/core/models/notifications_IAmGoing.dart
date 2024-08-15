import 'dart:convert';

IAmGoingModel IAmGoingModelFromJson(String str) =>
    IAmGoingModel.fromJson(json.decode(str));

String freeFoodModelToJson(IAmGoingModel data) => json.encode(data.toJson());

class IAmGoingModel {
  int? statusCode;
  Body body;

  IAmGoingModel({
    this.statusCode,
    required this.body,
  });

  IAmGoingModel.fromJson(Map<String, dynamic> json)
      : statusCode = json["statusCode"],
        body = Body.fromJson(json["body"]);

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "body": body.toJson(),
      };
}

class Body {
  int count;
  int maxCount;

  Body({required this.count, required this.maxCount});

  Body.fromJson(Map<String, dynamic> json)
      : count = json["count"],
        maxCount = json["maxCount"];

  Map<String, dynamic> toJson() => {
        "count": count,
        "maxCount": maxCount,
      };
}
