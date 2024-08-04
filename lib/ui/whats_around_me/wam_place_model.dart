import 'dart:convert';

// From JSON (converts string to object so that you can access properties)
PlaceModel placeModelFromJson(String str) => PlaceModel.fromJson(json.decode(str));
// To Json (converts object to string so it can be sent)
String placeModelToJson(PlaceModel data) => json.encode(data.toJson());

class PlaceModel {
  List<Location>? items;

  PlaceModel({
    this.items,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
    items: json["items"] == null
        ? null
        : List<Location>.from(json["items"].map((x) => Location.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "items": items == null
        ? null
        : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Location {
  String? name;
  String? address;
  String? coordinateX;
  String? coordinateY;

  Location({
    this.name,
    this.address,
    this.coordinateX,
    this.coordinateY,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    name: json["Loc_name"] == null ? null : json["Loc_name"],
    address: json["Match_addr"] == null ? null : json["Match_addr"].trim(),
    coordinateX: json["X"] == null ? null : json["X"],
    coordinateY: json["Y"] == null ? null : json["Y"],
  );

  Map<String, dynamic> toJson() => {
    "Loc_name": name == null ? null : name,
    "Match_addr": address == null ? null : address,
    "X": coordinateX == null ? null : coordinateX,
    "Y": coordinateY == null ? null : coordinateY,
  };
}
