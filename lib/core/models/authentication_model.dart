// To parse this JSON data, do
//
//     final authenticationModel = authenticationModelFromJson(jsonString);

import 'dart:convert';
import 'package:hive/hive.dart';

part 'authentication_model.g.dart';

AuthenticationModel authenticationModelFromJson(String str) =>
    AuthenticationModel.fromJson(json.decode(str));

String authenticationModelToJson(AuthenticationModel data) =>
    json.encode(data.toJson());

@HiveType(typeId: 1)
class AuthenticationModel extends HiveObject {
  @HiveField(0)
  String accessToken;
  @HiveField(1)
  String refreshToken;
  @HiveField(2)
  String pid;
  @HiveField(3)
  String ucsdaffiliation;
  @HiveField(4)
  int expiration;

  AuthenticationModel({
    this.accessToken,
    this.refreshToken,
    this.pid,
    this.ucsdaffiliation,
    this.expiration,
  });

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    ///this if statement is added so refresh token data can be used
    if (json['expires_in'] != null) {
      json['expiration'] = json['expires_in'];
    }
    print("in authentication_model.dart");
    print(json["ucsdaffiliation"]);
    print(json["access_token"]);
    return AuthenticationModel(
      accessToken: json["access_token"] == null ? null : json["access_token"],
      refreshToken:
          json["refresh_token"] == null ? null : json["refresh_token"],
      pid: json["pid"] == null ? null : json["pid"],
      ucsdaffiliation:
          json["ucsdaffiliation"] == null ? null : json["ucsdaffiliation"],
      expiration: json["expiration"] == null ? 0 : json["expiration"],
    );
  }

  Map<String, dynamic> toJson() => {
        "access_token": accessToken == null ? null : accessToken,
        "refresh_token": refreshToken == null ? null : refreshToken,
        "pid": pid == null ? null : pid,
        "ucsdaffiliation": ucsdaffiliation == null ? null : ucsdaffiliation,
        "expiration": expiration == null ? null : expiration,
      };

  /// Checks if the token we got back is expired
  bool isLoggedIn(DateTime lastUpdated) {
    if (lastUpdated == null) {
      return false;
    }
    if (expiration == null) {
      return false;
    }
    if (DateTime.now()
        .isAfter(lastUpdated.add(Duration(seconds: expiration)))) {
      return false;
    }
    return true;
  }
}
