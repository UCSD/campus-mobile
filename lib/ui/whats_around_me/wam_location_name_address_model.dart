import 'dart:convert';

// Location Name and Address Model (Data Structure for API calls a.k.a JSON response format)
// From JSON (a.k.a string to object so that you can access properties)
LocationNameAddressModel locationNameAddressModelFromJson(String str) => LocationNameAddressModel.fromJson(json.decode(str));
// To Json (a.k.a Stringify, make an object a string to be sent)
String locationNameAddressModelToJson(LocationNameAddressModel data) => json.encode(data.toJson());

class LocationNameAddressModel {
  List<Location>? items;

  LocationNameAddressModel({
    this.items,
  });

  factory LocationNameAddressModel.fromJson(Map<String, dynamic> json) => LocationNameAddressModel(
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
