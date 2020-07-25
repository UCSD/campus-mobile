// To parse this JSON data, do
//
//     final cardsModel = cardsModelFromJson(jsonString);

import 'dart:convert';

Map<String, CardsModel> cardsModelFromJson(String str) =>
    Map.from(json.decode(str))
        .map((k, v) => MapEntry<String, CardsModel>(k, CardsModel.fromJson(v)));

String cardsModelToJson(Map<String, CardsModel> data) => json.encode(
    Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class CardsModel {
  CardsModel({
    this.cardActive,
  });

  bool cardActive;

  factory CardsModel.fromJson(Map<String, dynamic> json) => CardsModel(
        cardActive: json["cardActive"] == null ? null : json["cardActive"],
      );

  Map<String, dynamic> toJson() => {
        "cardActive": cardActive == null ? null : cardActive,
      };
}
