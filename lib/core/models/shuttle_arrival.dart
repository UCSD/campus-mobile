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
    required this.routeId,
    required this.routeName,
    this.routeStopId,
    required this.routeColor,
    required this.secondsToArrival,
  });

  int routeId;
  String routeName;
  int? routeStopId; // unused, not sure if this is nullable or not
  String routeColor;
  int secondsToArrival;

  factory ArrivingShuttle.fromJson(Map<String, dynamic> json) {
    print('Arrivals resp--------------------------------:');
    print(json);
    return ArrivingShuttle(
      routeId: json["routeId"],
      routeName: json["routeName"],
      routeStopId: json["routeStopId"],
      routeColor: json["routeColor"],
      secondsToArrival: json["secondsToArrival"],
    );
  }

  Map<String, dynamic> toJson() => {
        "routeId": routeId,
        "routeName": routeName,
        "routeStopId": routeStopId,
        "routeColor": routeColor,
        "secondsToArrival": secondsToArrival
      };
}
