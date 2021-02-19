// To parse this JSON data, do
//
//     final employeeIdModel = employeeIdModelFromJson(jsonString);

import 'dart:convert';

EmployeeIdModel employeeIdModelFromJson(String str) =>
    EmployeeIdModel.fromJson(json.decode(str));

String employeeIdModelToJson(EmployeeIdModel data) =>
    json.encode(data.toJson());

class EmployeeIdModel {
  EmployeeIdModel({
    this.employeePreferredDisplayName,
    this.employeeId,
    this.department,
    this.barcode,
    this.photo,
    this.classificationType,
  });

  String employeePreferredDisplayName;
  String employeeId;
  String department;
  String barcode;
  String photo;
  String classificationType;

  factory EmployeeIdModel.fromJson(Map<String, dynamic> json) =>
      EmployeeIdModel(
        employeePreferredDisplayName:
            json["Employee Preferred Display Name"] == null
                ? null
                : json["Employee Preferred Display Name"],
        employeeId: json["Employee ID"] == null ? null : json["Employee ID"],
        department: json["Department"] == null ? null : json["Department"],
        barcode: json["Barcode"] == null ? null : json["Barcode"],
        photo: json["Photo"] == null ? null : json["Photo"],
        classificationType: json["Classification Type"] == null
            ? null
            : json["Classification Type"],
      );

  Map<String, dynamic> toJson() => {
        "Employee Preferred Display Name": employeePreferredDisplayName == null
            ? null
            : employeePreferredDisplayName,
        "Employee ID": employeeId == null ? null : employeeId,
        "Department": department == null ? null : department,
        "Barcode": barcode == null ? null : barcode,
        "Photo": photo == null ? null : photo,
        "Classification Type":
            classificationType == null ? null : classificationType,
      };
}
