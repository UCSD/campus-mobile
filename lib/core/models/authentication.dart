import 'dart:convert';
import 'package:hive/hive.dart';
part 'authentication.g.dart';

// To parse this JSON data, do
//
//     final authenticationModel = authenticationModelFromJson(jsonString);
AuthenticationModel authenticationModelFromJson(String str) => AuthenticationModel.fromJson(json.decode(str));

String authenticationModelToJson(AuthenticationModel data) => json.encode(data.toJson());

bool _isTsnValue(String? value) => value != null && RegExp(r'^\d{9}$').hasMatch(value);

@HiveType(typeId: 1)
class AuthenticationModel extends HiveObject {
  @HiveField(0)
  String? accessToken;
  // Deprecated reserved field number - DO NOT REMOVE
  // @HiveField(1)
  // String refreshToken;
  @HiveField(2)
  String? pid;
  @HiveField(3)
  String? ucsdaffiliation;
  @HiveField(4)
  int? expiration;
  @HiveField(5)
  String? tsn;

  AuthenticationModel({
    this.accessToken,
    String? pid,
    String? tsn,
    this.ucsdaffiliation,
    this.expiration,
  })  : pid = _isTsnValue(pid) && tsn == null ? null : pid,
        tsn = tsn ?? (_isTsnValue(pid) ? pid : null);

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(
      accessToken: json["access_token"] == null ? null : json["access_token"],
      // MA-477 keeps PID and TSN separate
      pid: json["pid"]?.toString(),
      tsn: json["tsn"]?.toString(),
      ucsdaffiliation: json["ucsdaffiliation"] == null ? "" : json["ucsdaffiliation"],
      expiration: json["expiration"] == null ? 0 : json["expiration"],
    );
  }

  Map<String, dynamic> toJson() => {
        "access_token": accessToken == null ? null : accessToken,
        "pid": pid == null ? null : pid,
        "tsn": tsn == null ? null : tsn,
        "ucsdaffiliation": ucsdaffiliation == null ? "" : ucsdaffiliation,
        "expiration": expiration == null ? null : expiration,
      };

  /// Checks if the token we got back is expired
  bool isLoggedIn(DateTime? lastUpdated) {
    // User has not logged in previously - isLoggedIn FALSE
    if (lastUpdated == null) return false;

    // User has no expiration or accessToken - isLoggedIn FALSE
    if (expiration == null || accessToken == null) return false;

    // User has expiration and accessToken
    // The `expiration` field represents how many seconds the token is valid after it was issued (i.e., after `lastUpdated`).
    // By adding `expiration` seconds to `lastUpdated`, we get the exact DateTime when the token will expire.
    final DateTime expirationTime = lastUpdated.add(Duration(seconds: expiration!));
    // If the current time is before this expiration time, the token is still valid.
    final bool isNotExpired = DateTime.now().isBefore(expirationTime);
    if (isNotExpired) {
      // Current datetime < expiration datetime - isLoggedIn TRUE
      return true;
    } else {
      // Current datetime > expiration datetime - isLoggedIn FALSE
      return false;
    }
  }
}
