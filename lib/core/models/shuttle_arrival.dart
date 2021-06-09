import 'dart:convert';

List<ArrivingShuttle> getArrivingShuttles(String str) {
  var shuttles = json.decode(str);
  List<ArrivingShuttle> arrivingShuttles = [];
  shuttles.forEach((shuttle) {
    arrivingShuttles.add(ArrivingShuttle.fromJson(shuttle));
  });
  return arrivingShuttles;
}

class ArrivingShuttle {
  ArrivingShuttle({
    this.pattern,
    this.route,
    this.schedulePrediction,
    this.secondsToArrival,
    this.vehicle,
  });

  Pattern? pattern;
  Route? route;
  bool? schedulePrediction;
  int? secondsToArrival;
  Vehicle? vehicle;

  String toRawJson() => json.encode(toJson());

  factory ArrivingShuttle.fromJson(Map<String, dynamic> json) =>
      ArrivingShuttle(
        pattern:
            json["pattern"] == null ? null : Pattern.fromJson(json["pattern"]),
        route: json["route"] == null ? null : Route.fromJson(json["route"]),
        schedulePrediction: json["schedulePrediction"] == null
            ? null
            : json["schedulePrediction"],
        secondsToArrival:
            json["secondsToArrival"] == null ? null : json["secondsToArrival"],
        vehicle:
            json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
      );

  Map<String, dynamic> toJson() => {
        "pattern": pattern == null ? null : pattern!.toJson(),
        "route": route == null ? null : route!.toJson(),
        "schedulePrediction":
            schedulePrediction == null ? null : schedulePrediction,
        "secondsToArrival": secondsToArrival == null ? null : secondsToArrival,
        "vehicle": vehicle == null ? null : vehicle!.toJson(),
      };
}

class Pattern {
  Pattern({
    this.color,
    this.direction,
    this.id,
    this.name,
    this.directionType,
    this.shape,
  });

  String? color;
  dynamic direction;
  int? id;
  String? name;
  dynamic directionType;
  dynamic shape;

  factory Pattern.fromRawJson(String str) => Pattern.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pattern.fromJson(Map<String, dynamic> json) => Pattern(
        color: json["color"] == null ? null : json["color"],
        direction: json["direction"],
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        directionType: json["directionType"],
        shape: json["shape"],
      );

  Map<String, dynamic> toJson() => {
        "color": color == null ? null : color,
        "direction": direction,
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "directionType": directionType,
        "shape": shape,
      };
}

class Route {
  Route({
    this.color,
    this.displayOrder,
    this.id,
    this.name,
    this.customerRouteId,
    this.shortName,
    this.description,
    this.routeType,
    this.url,
    this.textColor,
  });

  String? color;
  int? displayOrder;
  int? id;
  String? name;
  dynamic customerRouteId;
  String? shortName;
  String? description;
  String? routeType;
  dynamic url;
  String? textColor;

  factory Route.fromRawJson(String str) => Route.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Route.fromJson(Map<String, dynamic> json) => Route(
        color: json["color"] == null ? null : json["color"],
        displayOrder:
            json["displayOrder"] == null ? null : json["displayOrder"],
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        customerRouteId: json["customerRouteId"],
        shortName: json["shortName"] == null ? null : json["shortName"],
        description: json["description"] == null ? null : json["description"],
        routeType: json["routeType"] == null ? null : json["routeType"],
        url: json["url"],
        textColor: json["textColor"] == null ? null : json["textColor"],
      );

  Map<String, dynamic> toJson() => {
        "color": color == null ? null : color,
        "displayOrder": displayOrder == null ? null : displayOrder,
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "customerRouteId": customerRouteId,
        "shortName": shortName == null ? null : shortName,
        "description": description == null ? null : description,
        "routeType": routeType == null ? null : routeType,
        "url": url,
        "textColor": textColor == null ? null : textColor,
      };
}

class Vehicle {
  Vehicle({
    this.capacity,
    this.id,
    this.lat,
    this.lon,
    this.name,
    this.passengerLoad,
    this.lastUpdated,
    this.heading,
    this.speed,
    this.headingDegrees,
    this.shapeDistanceTraveled,
  });

  int? capacity;
  int? id;
  double? lat;
  double? lon;
  String? name;
  double? passengerLoad;
  DateTime? lastUpdated;
  String? heading;
  int? speed;
  double? headingDegrees;
  double? shapeDistanceTraveled;

  factory Vehicle.fromRawJson(String str) => Vehicle.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        capacity: json["capacity"] == null ? null : json["capacity"],
        id: json["id"] == null ? null : json["id"],
        lat: json["lat"] == null ? null : json["lat"].toDouble(),
        lon: json["lon"] == null ? null : json["lon"].toDouble(),
        name: json["name"] == null ? null : json["name"],
        passengerLoad: json["passengerLoad"] == null
            ? null
            : json["passengerLoad"].toDouble(),
        lastUpdated: json["lastUpdated"] == null
            ? null
            : DateTime.parse(json["lastUpdated"]),
        heading: json["heading"] == null ? null : json["heading"],
        speed: json["speed"] == null ? null : json["speed"],
        headingDegrees: json["headingDegrees"] == null
            ? null
            : json["headingDegrees"].toDouble(),
        shapeDistanceTraveled: json["shapeDistanceTraveled"] == null
            ? null
            : json["shapeDistanceTraveled"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "capacity": capacity == null ? null : capacity,
        "id": id == null ? null : id,
        "lat": lat == null ? null : lat,
        "lon": lon == null ? null : lon,
        "name": name == null ? null : name,
        "passengerLoad": passengerLoad == null ? null : passengerLoad,
        "lastUpdated":
            lastUpdated == null ? null : lastUpdated!.toIso8601String(),
        "heading": heading == null ? null : heading,
        "speed": speed == null ? null : speed,
        "headingDegrees": headingDegrees == null ? null : headingDegrees,
        "shapeDistanceTraveled":
            shapeDistanceTraveled == null ? null : shapeDistanceTraveled,
      };
}
