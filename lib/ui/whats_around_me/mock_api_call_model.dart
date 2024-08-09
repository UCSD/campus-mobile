// How data is structured
import 'dart:convert';

/// Step 1) Set up data conversion functions:
/*
* This function takes a JSON string,
* decodes it into a Map (using json.decode),
* and then converts it into a PlaceModel object
* using the PlaceModel.fromJson factory constructor.
*/
MockAPIModel mockAPIModelFromJson(String str) => MockAPIModel.fromJson(json.decode(str));

/*
* This function takes a PlaceModel object,
* converts it into a Map (using toJson),
* and then encodes it into a JSON string using json.encode.
*/
String mockAPIModelToJson(MockAPIModel data) => json.encode(data.toJson());

/// Step 2) Create the Class (structure) for this Model.
class MockAPIModel {
  // Declare Instance Variables
  String? locationTitle;

  // Constructor
  MockAPIModel({
    // Define instance variables
    this.locationTitle,
  });

  // Factory (Defines constructor variables using API data -> i.e. json["apiVariable"])
  factory MockAPIModel.fromJson(Map<String, dynamic> json) => MockAPIModel(
    // Instance Variable Definition using Ternary operations.
    locationTitle: json["loc_name"] == null ? null : json["loc_name"]
  );

  // To send data to API (probably won't need to), you'd do the opposite of Factory
  Map<String, dynamic> toJson() => {
    "Loc_name": locationTitle == null ? null : locationTitle,
  };
}

