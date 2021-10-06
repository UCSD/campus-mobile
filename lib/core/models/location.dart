class Coordinates {
  double? lat;
  double? lon;

  Coordinates({
    this.lat,
    this.lon,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        lat: json["lat"] == null ? null : double.parse(json["lat"]),
        lon: json["lon"] == null ? null : double.parse(json["lon"]),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat == null ? null : lat,
        "lon": lon == null ? null : lon,
      };
}
