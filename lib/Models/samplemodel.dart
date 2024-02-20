import 'package:login_page/Models/Model.dart';

class MatchInfo {
  int? matchId;
  int? seriesId;
  String seriesName;
  String matchDesc;
  String matchFormat;
  String startDate;
  String endDate;
  String state;
  String status;
  Team? team1;
  Team? team2;
  VenueInfo? venueInfo;
  String seriesStartDt;
  String seriesEndDt;
  bool isTimeAnnounced;
  String stateTitle;
  bool? isFantasyEnabled;
  int? currBatTeamId;

  MatchInfo({
    required this.matchId,
    required this.seriesId,
    required this.seriesName,
    required this.matchDesc,
    required this.matchFormat,
    required this.startDate,
    required this.endDate,
    required this.state,
    required this.status,
    required this.team1,
    required this.team2,
    required this.venueInfo,
    required this.seriesStartDt,
    required this.seriesEndDt,
    required this.isTimeAnnounced,
    required this.stateTitle,
    this.isFantasyEnabled,
    this.currBatTeamId,
  });

  factory MatchInfo.fromJson(Map<String, dynamic> json) => MatchInfo(
        matchId: json["matchId"],
        seriesId: json["seriesId"],
        seriesName: json["seriesName"],
        matchDesc: json["matchDesc"],
        matchFormat: json["matchFormat"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        state: json["state"],
        status: json["status"],
        team1: Team.fromJson(json["team1"]),
        team2: Team.fromJson(json["team2"]),
        venueInfo: VenueInfo.fromJson(json["venueInfo"]),
        seriesStartDt: json["seriesStartDt"],
        seriesEndDt: json["seriesEndDt"],
        isTimeAnnounced: json["isTimeAnnounced"],
        stateTitle: json["stateTitle"],
        isFantasyEnabled: json["isFantasyEnabled"],
        currBatTeamId: json["currBatTeamId"],
      );

  Map<String, dynamic> toJson() => {
        "matchId": matchId,
        "seriesId": seriesId,
        "seriesName": seriesName,
        "matchDesc": matchDesc,
        "matchFormat": matchFormat,
        "startDate": startDate,
        "endDate": endDate,
        "state": state,
        "status": status,
        "team1": team1?.toJson(),
        "team2": team2?.toJson(),
        "venueInfo": venueInfo?.toJson(),
        "seriesStartDt": seriesStartDt,
        "seriesEndDt": seriesEndDt,
        "isTimeAnnounced": isTimeAnnounced,
        "stateTitle": stateTitle,
        "isFantasyEnabled": isFantasyEnabled,
        "currBatTeamId": currBatTeamId,
      };
}
