import 'dart:convert';
import 'dart:core';

List<ShuttleStopModel> shuttleStopModelFromJson(String str) {
  Map<String, dynamic> list = json.decode(str);
  List<ShuttleStopModel> ret = [];
  list.forEach((key, value) {
    ret.add(ShuttleStopModel.fromJson(value));
  });
  return ret;
}

String shuttleStopModelToJson(List<ShuttleStopModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// Converts a OneBusAway identifier (e.g. `UCSD_1040`) into the integer id
/// used by the Transit UI and the persisted user profile. If the part after
/// the agency prefix is not numeric, falls back to a stable hash so ids stay
/// unique and non-negative.
int oneBusAwayIdToInt(String id) {
  final int separatorIndex = id.lastIndexOf('_');
  final String numericPart = separatorIndex >= 0 ? id.substring(separatorIndex + 1) : id;
  return int.tryParse(numericPart) ?? (id.hashCode & 0x7FFFFFFF);
}

/// Parses the envelope of a OneBusAway `stops-for-agency` response
/// (`{"code":200,...,"data":{"list":[...]}}`) into the existing
/// [ShuttleStopModel] shape used by the Transit UI.
///
/// Malformed entries are skipped so a single bad record cannot break the
/// whole stop list (graceful degradation).
List<ShuttleStopModel> shuttleStopsFromOneBusAwayEnvelope(Map<String, dynamic> envelope) {
  final dynamic data = envelope['data'];
  if (data is! Map<String, dynamic>) return const <ShuttleStopModel>[];
  final dynamic list = data['list'];
  if (list is! List) return const <ShuttleStopModel>[];
  return list
      .whereType<Map<String, dynamic>>()
      .map(ShuttleStopModel.fromOneBusAwayJson)
      .whereType<ShuttleStopModel>()
      .toList();
}

class ShuttleStopModel {
  double lat;
  double lon;
  int id;
  String name;

  /// Raw OneBusAway stop id (e.g. `UCSD_10378`), kept so the arrivals
  /// endpoint can be queried with the exact id OneBusAway expects.
  String? oneBusAwayId;

  ShuttleStopModel({required this.lat, required this.lon, required this.id, required this.name, this.oneBusAwayId});

  ShuttleStopModel.fromJson(Map<String, dynamic> json)
    : lat = json["lat"].toDouble(),
      lon = json["lon"].toDouble(),
      id = json["id"],
      name = json["name"];

  /// Maps a OneBusAway stop object onto the existing model shape. Returns
  /// null when required fields are missing or malformed.
  static ShuttleStopModel? fromOneBusAwayJson(Map<String, dynamic> json) {
    final dynamic lat = json['lat'];
    final dynamic lon = json['lon'];
    final String? rawId = json['id']?.toString();
    final String? name = json['name']?.toString();
    if (lat is! num || lon is! num || rawId == null || rawId.isEmpty || name == null) {
      return null;
    }
    return ShuttleStopModel(
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      id: oneBusAwayIdToInt(rawId),
      name: name,
      oneBusAwayId: rawId,
    );
  }

  Map<String, dynamic> toJson() => {"lat": lat, "lon": lon, "id": id, "name": name, "oneBusAwayId": oneBusAwayId};
}
