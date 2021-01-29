// To parse this JSON data, do
//
//     final surveyModel = surveyModelFromJson(jsonString);

import 'dart:convert';

SurveyModel surveyModelFromJson(String str) =>
    SurveyModel.fromJson(json.decode(str));

String surveyModelToJson(SurveyModel data) => json.encode(data.toJson());

class SurveyModel {
  SurveyModel({
    this.surveyActive,
    this.surveyId,
    this.surveyUrl,
  });

  bool surveyActive;
  String surveyId;
  String surveyUrl;

  factory SurveyModel.fromJson(Map<String, dynamic> json) => SurveyModel(
        surveyActive: json["survey_active"],
        surveyId: json["survey_id"],
        surveyUrl: json["survey_url"],
      );

  Map<String, dynamic> toJson() => {
        "survey_active": surveyActive,
        "survey_id": surveyId,
        "survey_url": surveyUrl,
      };
}
