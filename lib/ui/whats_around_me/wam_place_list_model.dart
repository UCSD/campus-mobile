// To parse this JSON data, do
//
//     final placesByCategory = placesByCategoryFromJson(jsonString);

import 'dart:convert';

PlacesByCategoryModel placesByCategoryFromJson(String str) => PlacesByCategoryModel.fromJson(json.decode(str));

String placesByCategoryToJson(PlacesByCategoryModel data) => json.encode(data.toJson());

class PlacesByCategoryModel {
  List<Category>? categories;

  PlacesByCategoryModel({
    this.categories,
  });

  factory PlacesByCategoryModel.fromJson(Map<String, dynamic> json) => PlacesByCategoryModel(
    categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class Category {
  Restaurants? restaurants;
  LectureHalls? lectureHalls;
  CoffeeShops? coffeeShops;

  Category({
    this.restaurants,
    this.lectureHalls,
    this.coffeeShops,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    restaurants: Restaurants.fromJson(json["restaurants"]),
    lectureHalls: LectureHalls.fromJson(json["lecture_halls"]),
    coffeeShops: CoffeeShops.fromJson(json["coffee_shops"]),
  );

  Map<String, dynamic> toJson() => {
    "restaurants": restaurants?.toJson(),
    "lecture_halls": lectureHalls?.toJson(),
    "coffee_shops": coffeeShops?.toJson(),
  };
}

class CoffeeShops {
  String? coffeeShop1;
  String? coffeeShop2;

  CoffeeShops({
    this.coffeeShop1,
    this.coffeeShop2,
  });

  factory CoffeeShops.fromJson(Map<String, dynamic> json) => CoffeeShops(
    coffeeShop1: json["coffee_shop_1"],
    coffeeShop2: json["coffee_shop_2"],
  );

  Map<String, dynamic> toJson() => {
    "coffee_shop_1": coffeeShop1,
    "coffee_shop_2": coffeeShop2,
  };
}

class LectureHalls {
  String? lectureHall1;
  String? lectureHall2;

  LectureHalls({
    this.lectureHall1,
    this.lectureHall2,
  });

  factory LectureHalls.fromJson(Map<String, dynamic> json) => LectureHalls(
    lectureHall1: json["lecture_hall_1"],
    lectureHall2: json["lecture_hall_2"],
  );

  Map<String, dynamic> toJson() => {
    "lecture_hall_1": lectureHall1,
    "lecture_hall_2": lectureHall2,
  };
}

class Restaurants {
  String? restaurant1;
  String? restaurant2;

  Restaurants({
    this.restaurant1,
    this.restaurant2,
  });

  factory Restaurants.fromJson(Map<String, dynamic> json) => Restaurants(
    restaurant1: json["restaurant_1"],
    restaurant2: json["restaurant_2"],
  );

  Map<String, dynamic> toJson() => {
    "restaurant_1": restaurant1,
    "restaurant_2": restaurant2,
  };
}
