// To parse this JSON data, do
//
//     final diningMenuItemsModel = diningMenuItemsModelFromJson(jsonString);

import 'dart:convert';

DiningMenuItemsModel diningMenuItemsModelFromJson(String str) =>
    DiningMenuItemsModel.fromJson(json.decode(str));

String diningMenuItemsModelToJson(DiningMenuItemsModel data) =>
    json.encode(data.toJson());

class DiningMenuItemsModel {
  List<DiningMenuItem>? menuItems;
  String? disclaimer;
  String? disclaimerEmail;

  DiningMenuItemsModel({
    this.menuItems,
    this.disclaimer,
    this.disclaimerEmail,
  });

  factory DiningMenuItemsModel.fromJson(Map<String, dynamic> json) =>
      DiningMenuItemsModel(
        menuItems: json["menuitems"] == null
            ? null
            : List<DiningMenuItem>.from(
                json["menuitems"].map((x) => DiningMenuItem.fromJson(x))),
        disclaimer: json["disclaimer"] == null ? null : json["disclaimer"],
        disclaimerEmail:
            json["disclaimerEmail"] == null ? null : json["disclaimerEmail"],
      );

  Map<String, dynamic> toJson() => {
        "menuitems": menuItems == null
            ? null
            : List<dynamic>.from(menuItems!.map((x) => x.toJson())),
        "disclaimer": disclaimer == null ? null : disclaimer,
        "disclaimerEmail": disclaimerEmail == null ? null : disclaimerEmail,
      };
}

class DiningMenuItem {
  String? name;
  String? itemId;
  String? station;
  String? price;
  dynamic images;
  String? tags;
  Nutrition? nutrition;

  DiningMenuItem({
    this.name,
    this.itemId,
    this.station,
    this.price,
    this.images,
    this.tags,
    this.nutrition,
  });

  factory DiningMenuItem.fromJson(Map<String, dynamic> json) => DiningMenuItem(
        name: json["name"] == null ? null : json["name"],
        itemId: json["itemID"] == null ? null : json["itemID"],
        station: json["station"] == null ? null : json["station"],
        price: json["price"] == null ? null : json["price"],
        images: json["images"],
        tags: json["tags"] == null ? null : json["tags"],
        nutrition: json["nutrition"] == null
            ? null
            : Nutrition.fromJson(json["nutrition"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "itemID": itemId == null ? null : itemId,
        "station": station == null ? null : station,
        "price": price == null ? null : price,
        "images": images,
        "tags": tags == null ? null : tags,
        "nutrition": nutrition == null ? null : nutrition!.toJson(),
      };
}

class Nutrition {
  String? servingSize;
  String? calories;
  String? totalFat;
  String? totalFatDv;
  String? saturatedFat;
  String? saturatedFatDv;
  String? transFat;
  String? transFatDv;
  String? cholesterol;
  String? cholesterolDv;
  String? sodium;
  String? sodiumDv;
  String? totalCarbohydrate;
  String? totalCarbohydrateDv;
  String? dietaryFiber;
  String? dietaryFiberDv;
  String? sugar;
  String? sugarDv;
  String? protein;
  String? proteinDv;
  String? ingredients;
  String? allergens;

  Nutrition({
    this.servingSize,
    this.calories,
    this.totalFat,
    this.totalFatDv,
    this.saturatedFat,
    this.saturatedFatDv,
    this.transFat,
    this.transFatDv,
    this.cholesterol,
    this.cholesterolDv,
    this.sodium,
    this.sodiumDv,
    this.totalCarbohydrate,
    this.totalCarbohydrateDv,
    this.dietaryFiber,
    this.dietaryFiberDv,
    this.sugar,
    this.sugarDv,
    this.protein,
    this.proteinDv,
    this.ingredients,
    this.allergens,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) => Nutrition(
        servingSize: json["servingSize"] == null ? null : json["servingSize"],
        calories: json["calories"] == null ? null : json["calories"],
        totalFat: json["totalFat"] == null ? null : json["totalFat"],
        totalFatDv: json["totalFat_DV"] == null ? null : json["totalFat_DV"],
        saturatedFat:
            json["saturatedFat"] == null ? null : json["saturatedFat"],
        saturatedFatDv:
            json["saturatedFat_DV"] == null ? null : json["saturatedFat_DV"],
        transFat: json["transFat"] == null ? null : json["transFat"],
        transFatDv: json["transFat_DV"] == null ? null : json["transFat_DV"],
        cholesterol: json["cholesterol"] == null ? null : json["cholesterol"],
        cholesterolDv:
            json["cholesterol_DV"] == null ? null : json["cholesterol_DV"],
        sodium: json["sodium"] == null ? null : json["sodium"],
        sodiumDv: json["sodium_DV"] == null ? null : json["sodium_DV"],
        totalCarbohydrate: json["totalCarbohydrate"] == null
            ? null
            : json["totalCarbohydrate"],
        totalCarbohydrateDv: json["totalCarbohhdrate_DV"] == null
            ? null
            : json["totalCarbohhdrate_DV"],
        dietaryFiber:
            json["dietaryFiber"] == null ? null : json["dietaryFiber"],
        dietaryFiberDv:
            json["dietaryFiber_DV"] == null ? null : json["dietaryFiber_DV"],
        sugar: json["sugars"] == null ? null : json["sugars"],
        sugarDv: json["sugars_DV"] == null ? null : json["sugars_DV"],
        protein: json["protein"] == null ? null : json["protein"],
        proteinDv: json["protein_DV"] == null ? null : json["protein_DV"],
        ingredients: json["ingredients"] == null ? null : json["ingredients"],
        allergens: json["allergens"] == null ? null : json["allergens"],
      );

  Map<String, dynamic> toJson() => {
        "servingSize": servingSize == null ? null : servingSize,
        "calories": calories == null ? null : calories,
        "totalFat": totalFat == null ? null : totalFat,
        "totalFat_DV": totalFatDv == null ? null : totalFatDv,
        "saturatedFat": saturatedFat == null ? null : saturatedFat,
        "saturatedFat_DV": saturatedFatDv == null ? null : saturatedFatDv,
        "transFat": transFat == null ? null : transFat,
        "transFat_DV": transFatDv == null ? null : transFatDv,
        "cholesterol": cholesterol == null ? null : cholesterol,
        "cholesterol_DV": cholesterolDv == null ? null : cholesterolDv,
        "sodium": sodium == null ? null : sodium,
        "sodium_DV": sodiumDv == null ? null : sodiumDv,
        "totalCarbohydrate":
            totalCarbohydrate == null ? null : totalCarbohydrate,
        "totalCarbohhdrate_DV":
            totalCarbohydrateDv == null ? null : totalCarbohydrateDv,
        "dietaryFiber": dietaryFiber == null ? null : dietaryFiber,
        "dietaryFiber_DV": dietaryFiberDv == null ? null : dietaryFiberDv,
        "sugar": sugar == null ? null : sugar,
        "sugar_DV": sugarDv == null ? null : sugarDv,
        "protein": protein == null ? null : protein,
        "protein_DV": proteinDv == null ? null : proteinDv,
        "ingredients": ingredients == null ? null : ingredients,
        "allergens": allergens == null ? null : allergens,
      };
}
