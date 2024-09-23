import 'dart:convert';

PlacesByCategoryModel placesByCategoryFromJson(String str) => PlacesByCategoryModel.fromJson(json.decode(str));

String placesByCategoryToJson(PlacesByCategoryModel data) => json.encode(data.toJson());

class PlacesByCategoryModel {
  List<Category>? categories;

  PlacesByCategoryModel({this.categories});

  factory PlacesByCategoryModel.fromJson(Map<String, dynamic> json) {
    return PlacesByCategoryModel(
      categories: List<Category>.from(
        json["categories"].map((x) => Category.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "categories": List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class Category {
  String? categoryName;  // To hold the category name
  Map<String, String>? places;

  Category({this.categoryName, this.places});

  factory Category.fromJson(Map<String, dynamic> json) {
    // Extract the category name as the key (e.g., "restaurants", "lecture_halls")
    String key = json.keys.first;  // Get the first key, which is the category name
    return Category(
      categoryName: key,
      places: Map<String, String>.from(json[key]),
    );
  }

  Map<String, dynamic> toJson() => {
    categoryName!: places,  // Convert back to JSON format
  };
}
