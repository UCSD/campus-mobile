// To parse this JSON data, do
//
//     final linksModel = linksModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<LinksModel> linksModelFromJson(String str) =>
    List<LinksModel>.from(json.decode(str).map((x) => LinksModel.fromJson(x)));

String linksModelToJson(List<LinksModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LinksModel {
  String name;
  String url;
  IconData icon;

  LinksModel({
    this.name,
    this.url,
    this.icon,
  });

  factory LinksModel.fromJson(Map<String, dynamic> json) => LinksModel(
        name: json["name"] == null ? null : json["name"],
        url: json["url"] == null ? null : json["url"],
        icon: json["icon"] == null ? null : getIconForName(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "url": url == null ? null : url,
        "icon": icon == null ? null : icon,
      };
}

IconData getIconForName(String iconName) {
  switch (iconName) {
    case 'school':
      {
        return Icons.school;
      }
      break;

    case 'twitter':
      {
        return Icons.library_books;
      }
      break;
    case 'directions_run':
      {
        return Icons.directions_run;
      }
      break;
    case 'search':
      {
        return Icons.search;
      }
      break;
    case 'store':
      {
        return Icons.store;
      }
      break;
    case 'local_hotel':
      {
        return Icons.local_hotel;
      }
      break;
    case 'rowing':
      {
        return Icons.rowing;
      }
      break;
    case 'local_hospital':
      {
        return Icons.local_hospital;
      }
      break;
    default:
      {
        return Icons.error;
      }
  }
}
