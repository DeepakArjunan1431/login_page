// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  List<ListElement> list;
  AppIndex appIndex;

  Welcome({
    required this.list,
    required this.appIndex,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        list: List<ListElement>.from(
            json["list"].map((x) => ListElement.fromJson(x))),
        appIndex: AppIndex.fromJson(json["appIndex"]),
      );

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
        "appIndex": appIndex.toJson(),
      };
}

class AppIndex {
  String seoTitle;
  String webUrl;

  AppIndex({
    required this.seoTitle,
    required this.webUrl,
  });

  factory AppIndex.fromJson(Map<String, dynamic> json) => AppIndex(
        seoTitle: json["seoTitle"],
        webUrl: json["webURL"],
      );

  Map<String, dynamic> toJson() => {
        "seoTitle": seoTitle,
        "webURL": webUrl,
      };
}

class ListElement {
  String teamName;
  int? teamId;
  String? teamSName;
  int? imageId;
  String? countryName;

  ListElement({
    required this.teamName,
    this.teamId,
    this.teamSName,
    this.imageId,
    this.countryName,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        teamName: json["teamName"],
        teamId: json["teamId"],
        teamSName: json["teamSName"],
        imageId: json["imageId"],
        countryName: json["countryName"],
      );

  Map<String, dynamic> toJson() => {
        "teamName": teamName,
        "teamId": teamId,
        "teamSName": teamSName,
        "imageId": imageId,
        "countryName": countryName,
      };
}
