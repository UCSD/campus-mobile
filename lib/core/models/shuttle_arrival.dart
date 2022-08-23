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
    this.routeId,
    this.routeName,
    this.routeStopId,
    this.routeColor,
    this.secondsToArrival,
  });

  int? routeId;
  String? routeName;
  int? routeStopId;
  String? routeColor;
  int? secondsToArrival;

  factory ArrivingShuttle.fromJson(Map<String, dynamic> json) {
    print('Arrivals resp--------------------------------:');
    print(json);
    return ArrivingShuttle(
      routeId: json["routeId"] == null ? null : json["routeId"],
      routeName: json["routeName"] == null ? null : json["routeName"],
      routeStopId: json["routeStopId"] == null ? null : json["routeStopId"],
      routeColor: json["routeColor"] == null ? null : json["routeColor"],
      secondsToArrival:
          json["secondsToArrival"] == null ? null : json["secondsToArrival"],
    );
  }

  Map<String, dynamic> toJson() => {
        "routeId": routeId == null ? null : routeId,
        "routeName": routeName == null ? null : routeName,
        "routeStopId": routeStopId == null ? null : routeStopId,
        "routeColor": routeColor == null ? null : routeColor,
        "secondsToArrival": secondsToArrival == null ? null : secondsToArrival,
      };
}
