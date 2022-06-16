// To parse this JSON data, do
//
//     final apiModel = apiModelFromJson(jsonString);

import 'dart:convert';

ApiModel apiModelFromJson(String str) => ApiModel.fromJson(json.decode(str));

String apiModelToJson(ApiModel data) => json.encode(data.toJson());

class ApiModel {
  ApiModel({
    required this.aa,
  });

  String aa;

  factory ApiModel.fromJson(Map<String, dynamic> json) => ApiModel(
        aa: json["aa"],
      );

  Map<String, dynamic> toJson() => {
        "aa": aa,
      };
}
