import 'dart:convert';

FreeFoodModel freeFoodModelFromJson(String str) => FreeFoodModel.fromJson(json.decode(str));

String freeFoodModelToJson(FreeFoodModel data) => json.encode(data.toJson());

class FreeFoodModel {
    int statusCode;
    Body body;

    FreeFoodModel({
        this.statusCode,
        this.body,
    });

    factory FreeFoodModel.fromJson(Map<String, dynamic> json) => FreeFoodModel(
        statusCode: json["statusCode"],
        body: Body.fromJson(json["body"]),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "body": body.toJson(),
    };
}

class Body {
    int count;

    Body({
        this.count,
    });

    factory Body.fromJson(Map<String, dynamic> json) => Body(
        count: json["count"],
    );

    Map<String, dynamic> toJson() => {
        "count": count,
    };
}
