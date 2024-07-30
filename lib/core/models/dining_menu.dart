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

  // TODO: worth redesigning this class in the future to avoid nulls when there is no menu
  // JSON RESPONSE WHEN NO MENU: { "message" : "No menu items available." }
  DiningMenuItemsModel.fromJson(Map<String, dynamic> json)
      : menuItems = json["menuitems"] == null
            ? null
            : List<DiningMenuItem>.from(
                json["menuitems"].map((x) => DiningMenuItem.fromJson(x))),
        disclaimer = json["disclaimer"],
        disclaimerEmail = json["disclaimerEmail"];

  Map<String, dynamic> toJson() => {
        "menuitems": menuItems == null
            ? null
            : List<dynamic>.from(menuItems!.map((x) => x.toJson())),
        "disclaimer": disclaimer,
        "disclaimerEmail": disclaimerEmail,
      };
}

class DiningMenuItem {
  String name;
  String price;
  String tags;
  Nutrition nutrition;

  // UNUSED
  String? itemId;
  String? station;
  dynamic images; // confirmed nullable

  DiningMenuItem({
    required this.name,
    this.itemId,
    this.station,
    required this.price,
    this.images,
    required this.tags,
    required this.nutrition,
  });

  DiningMenuItem.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        itemId = json["itemID"],
        station = json["station"],
        price = json["price"],
        images = json["images"],
        tags = json["tags"],
        nutrition = Nutrition.fromJson(json["nutrition"]);

  Map<String, dynamic> toJson() => {
        "name": name,
        "itemID": itemId,
        "station": station,
        "price": price,
        "images": images,
        "tags": tags,
        "nutrition": nutrition.toJson(),
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

  Nutrition.fromJson(Map<String, dynamic> json)
      : servingSize = json["servingSize"],
        calories = json["calories"],
        totalFat = json["totalFat"],
        totalFatDv = json["totalFat_DV"],
        saturatedFat = json["saturatedFat"],
        saturatedFatDv = json["saturatedFat_DV"],
        transFat = json["transFat"],
        transFatDv = json["transFat_DV"],
        cholesterol = json["cholesterol"],
        cholesterolDv = json["cholesterol_DV"],
        sodium = json["sodium"],
        sodiumDv = json["sodium_DV"],
        totalCarbohydrate = json["totalCarbohydrate"],
        totalCarbohydrateDv = json["totalCarbohhdrate_DV"],
        dietaryFiber = json["dietaryFiber"],
        dietaryFiberDv = json["dietaryFiber_DV"],
        sugar = json["sugars"],
        sugarDv = json["sugars_DV"],
        protein = json["protein"],
        proteinDv = json["protein_DV"],
        ingredients = json["ingredients"],
        allergens = json["allergens"];

  Map<String, dynamic> toJson() => {
        "servingSize": servingSize,
        "calories": calories,
        "totalFat": totalFat,
        "totalFat_DV": totalFatDv,
        "saturatedFat": saturatedFat,
        "saturatedFat_DV": saturatedFatDv,
        "transFat": transFat,
        "transFat_DV": transFatDv,
        "cholesterol": cholesterol,
        "cholesterol_DV": cholesterolDv,
        "sodium": sodium,
        "sodium_DV": sodiumDv,
        "totalCarbohydrate": totalCarbohydrate,
        "totalCarbohhdrate_DV": totalCarbohydrateDv,
        "dietaryFiber": dietaryFiber,
        "dietaryFiber_DV": dietaryFiberDv,
        "sugar": sugar,
        "sugar_DV": sugarDv,
        "protein": protein,
        "protein_DV": proteinDv,
        "ingredients": ingredients,
        "allergens": allergens,
      };
}
