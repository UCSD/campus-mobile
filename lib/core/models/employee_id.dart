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

  dynamic employeePreferredDisplayName;
  dynamic employeeId;
  dynamic department;
  dynamic barcode;
  dynamic photo;
  dynamic classificationType;

  factory EmployeeIdModel.fromJson(Map<String, dynamic> json) =>
      EmployeeIdModel(
        employeePreferredDisplayName:
            json["Employee Preferred Display Name"] == null
                ? ""
                : json["Employee Preferred Display Name"],
        employeeId: json["Employee ID"] == null ? "" : json["Employee ID"],
        department: json["Department"] == null ? "" : json["Department"],
        barcode: json["Barcode"] == null ? "" : json["Barcode"],
        photo: json["Photo"] == null ? "" : json["Photo"],
        classificationType: json["Classification Type"] == null
            ? "Employee"
            : json["Classification Type"],
      );

  Map<String, dynamic> toJson() => {
        "Employee Preferred Display Name": employeePreferredDisplayName == null
            ? ""
            : employeePreferredDisplayName,
        "Employee ID": employeeId == null ? "" : employeeId,
        "Department": department == null ? "" : department,
        "Barcode": barcode == null ? "" : barcode,
        "Photo": photo == null ? "" : photo,
        "Classification Type":
            classificationType == null ? "Employee" : classificationType,
      };
}
