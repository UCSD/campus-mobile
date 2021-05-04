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
  CardsModel(
      {this.cardActive,
      this.initialURL,
      this.isWebCard,
      this.requireAuth,
      this.titleText});

  bool? cardActive;
  String? initialURL;
  bool? isWebCard;
  bool? requireAuth;
  String? titleText;

  factory CardsModel.fromJson(Map<String, dynamic> json) => CardsModel(
        cardActive: json["cardActive"] == null ? false : json["cardActive"],
        initialURL: json["initialURL"] == null ? "" : json["initialURL"],
        isWebCard: json["isWebCard"] == null ? false : json["isWebCard"],
        requireAuth: json["requireAuth"] == null ? false : json["requireAuth"],
        titleText: json["titleText"] == null ? "" : json["titleText"],
      );

  Map<String, dynamic> toJson() => {
        "cardActive": cardActive == null ? false : cardActive,
        "initialURL": initialURL == null ? "" : initialURL,
        "isWebCard": isWebCard == null ? false : isWebCard,
        "requireAuth": requireAuth == null ? false : requireAuth,
        "titleText": titleText == null ? "" : titleText,
      };
}
