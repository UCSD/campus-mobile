class Parking {
  String locationId;
  String locationName;
  String locationContext;
  String locationProvider;
  Availability availability;
  DateTime lastUpdated;
  String availabilityType;
  int total;
  int open;

  Parking({
    this.locationId,
    this.locationName,
    this.locationContext,
    this.locationProvider,
    this.availability,
    this.lastUpdated,
    this.availabilityType,
    this.total,
    this.open,
  });
}

class Availability {
  SpotType a;
  SpotType accessible;
  SpotType b;
  SpotType s;
  SpotType v;

  Availability({
    this.a,
    this.accessible,
    this.b,
    this.s,
    this.v,
  });

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
        b: json["B"] == null ? null : SpotType.fromJson(json["B"]),
        accessible: json["Accessible"] == null
            ? null
            : SpotType.fromJson(json["Accessible"]),
        a: json["A"] == null ? null : SpotType.fromJson(json["A"]),
        s: json["S"] == null ? null : SpotType.fromJson(json["S"]),
        v: json["V"] == null ? null : SpotType.fromJson(json["V"]),
      );

  Map<String, dynamic> toJson() => {
        "B": b == null ? null : b.toJson(),
        "Accessible": accessible == null ? null : accessible.toJson(),
        "A": a == null ? null : a.toJson(),
        "S": s == null ? null : s.toJson(),
        "V": v == null ? null : v.toJson(),
      };
}

class SpotType {
  int total;
  int open;
  int level;

  SpotType({
    this.total,
    this.open,
    this.level,
  });
  factory SpotType.fromJson(Map<String, dynamic> json) => SpotType(
        level: json["Level"] == null ? null : json["Level"],
        total: json["Total"] == null ? null : json["Total"],
        open: json["Open"] == null ? null : json["Open"],
      );

  Map<String, dynamic> toJson() => {
        "Level": level == null ? null : level,
        "Total": total == null ? null : total,
        "Open": open == null ? null : open,
      };
}
