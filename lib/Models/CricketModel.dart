// import 'package:flutter/material.dart';

class ScoreCard {
  final List<InningsDetails> innings;
  final MatchHeader matchHeader;

  ScoreCard({
    required this.innings,
    required this.matchHeader,
  });

  factory ScoreCard.fromJson(Map<String, dynamic> json) {
    var scoreCardData = json['scoreCard'] as List<dynamic>;
    return ScoreCard(
      innings: scoreCardData.map((inning) => InningsDetails.fromJson(inning)).toList(),
      matchHeader: MatchHeader.fromJson(json['matchHeader'] ?? {}),
    );
  }
}

class InningsDetails {
  final BatTeamDetails batTeamDetails;
  final BowlTeamDetails bowlTeamDetails;
  final ScoreDetails scoreDetails;
  final Map<String, WicketsDatum> wicketsData;

  InningsDetails({
    required this.batTeamDetails,
    required this.bowlTeamDetails,
    required this.scoreDetails,
    required this.wicketsData,
  });

  factory InningsDetails.fromJson(Map<String, dynamic> json) {
    return InningsDetails(
      batTeamDetails: BatTeamDetails.fromJson(json['batTeamDetails'] ?? {}),
      bowlTeamDetails: BowlTeamDetails.fromJson(json['bowlTeamDetails'] ?? {}),
      scoreDetails: ScoreDetails.fromJson(json['scoreDetails'] ?? {}),
      wicketsData: (json['wicketsData'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, WicketsDatum.fromJson(v)),
      ) ?? {},
    );
  }
}

class BatTeamDetails {
  final int batTeamId;
  final String batTeamName;
  final String batTeamShortName;
  final Map<String, BatsmenDatum> batsmenData;

  BatTeamDetails({
    required this.batTeamId,
    required this.batTeamName,
    required this.batTeamShortName,
    required this.batsmenData,
  });

  factory BatTeamDetails.fromJson(Map<String, dynamic> json) {
    var batsmenMap = json['batsmenData'] as Map<String, dynamic>? ?? {};
    Map<String, BatsmenDatum> batsmenDataMap = {};
    batsmenMap.forEach((key, value) {
      batsmenDataMap[key] = BatsmenDatum.fromJson(value);
    });

    return BatTeamDetails(
      batTeamId: json['batTeamId'] ?? 0,
      batTeamName: json['batTeamName'] ?? '',
      batTeamShortName: json['batTeamShortName'] ?? '',
      batsmenData: batsmenDataMap,
    );
  }
}

class BatsmenDatum {
  final int batId;
  final String batName;
  final bool isCaptain;
  final bool isKeeper;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final double strikeRate;
  final String outDesc;

  BatsmenDatum({
    required this.batId,
    required this.batName,
    required this.isCaptain,
    required this.isKeeper,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.outDesc,
  });

  factory BatsmenDatum.fromJson(Map<String, dynamic> json) {
    return BatsmenDatum(
      batId: json['batId'] ?? 0,
      batName: json['batName'] ?? '',
      isCaptain: json['isCaptain'] ?? false,
      isKeeper: json['isKeeper'] ?? false,
      runs: json['runs'] ?? 0,
      balls: json['balls'] ?? 0,
      fours: json['fours'] ?? 0,
      sixes: json['sixes'] ?? 0,
      strikeRate: (json['strikeRate'] ?? 0).toDouble(),
      outDesc: json['outDesc'] ?? '',
    );
  }
}

class BowlTeamDetails {
  final int bowlTeamId;
  final String bowlTeamName;
  final String bowlTeamShortName;
  final Map<String, BowlerDatum> bowlersData;

  BowlTeamDetails({
    required this.bowlTeamId,
    required this.bowlTeamName,
    required this.bowlTeamShortName,
    required this.bowlersData,
  });

  factory BowlTeamDetails.fromJson(Map<String, dynamic> json) {
    var bowlersMap = json['bowlersData'] as Map<String, dynamic>? ?? {};
    Map<String, BowlerDatum> bowlersDataMap = {};
    bowlersMap.forEach((key, value) {
      bowlersDataMap[key] = BowlerDatum.fromJson(value);
    });

    return BowlTeamDetails(
      bowlTeamId: json['bowlTeamId'] ?? 0,
      bowlTeamName: json['bowlTeamName'] ?? '',
      bowlTeamShortName: json['bowlTeamShortName'] ?? '',
      bowlersData: bowlersDataMap,
    );
  }
}

class BowlerDatum {
  final int bowlerId;
  final String bowlName;
  final bool isCaptain;
  final bool isKeeper;
  final double overs;
  final int maidens;
  final int runs;
  final int wickets;
  final double economy;

  BowlerDatum({
    required this.bowlerId,
    required this.bowlName,
    required this.isCaptain,
    required this.isKeeper,
    required this.overs,
    required this.maidens,
    required this.runs,
    required this.wickets,
    required this.economy,
  });

  factory BowlerDatum.fromJson(Map<String, dynamic> json) {
    return BowlerDatum(
      bowlerId: json['bowlerId'] ?? 0,
      bowlName: json['bowlName'] ?? '',
      isCaptain: json['isCaptain'] ?? false,
      isKeeper: json['isKeeper'] ?? false,
      overs: (json['overs'] ?? 0).toDouble(),
      maidens: json['maidens'] ?? 0,
      runs: json['runs'] ?? 0,
      wickets: json['wickets'] ?? 0,
      economy: (json['economy'] ?? 0).toDouble(),
    );
  }
}

class ScoreDetails {
  final int runs;
  final int wickets;
  final double overs;
  final double runRate;

  ScoreDetails({
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.runRate,
  });

  factory ScoreDetails.fromJson(Map<String, dynamic> json) {
    return ScoreDetails(
      runs: json['runs'] ?? 0,
      wickets: json['wickets'] ?? 0,
      overs: (json['overs'] ?? 0).toDouble(),
      runRate: (json['runRate'] ?? 0).toDouble(),
    );
  }
}

class WicketsDatum {
  final int batId;
  final String batName;
  final String wicketDesc;

  WicketsDatum({
    required this.batId,
    required this.batName,
    required this.wicketDesc,
  });

  factory WicketsDatum.fromJson(Map<String, dynamic> json) {
    return WicketsDatum(
      batId: json['batId'] ?? 0,
      batName: json['batName'] ?? '',
      wicketDesc: json['wicketDesc'] ?? '',
    );
  }
}

class MatchHeader {
  final int matchId;
  final String matchDescription;
  final String matchFormat;
  final String matchType;
  final bool complete;
  final bool domestic;
  final int matchStartTimestamp;
  final int matchCompleteTimestamp;
  final bool dayNight;
  final int year;
  final String state;
  final String status;

  MatchHeader({
    required this.matchId,
    required this.matchDescription,
    required this.matchFormat,
    required this.matchType,
    required this.complete,
    required this.domestic,
    required this.matchStartTimestamp,
    required this.matchCompleteTimestamp,
    required this.dayNight,
    required this.year,
    required this.state,
    required this.status,
  });

  factory MatchHeader.fromJson(Map<String, dynamic> json) {
    return MatchHeader(
      matchId: json['matchId'] ?? 0,
      matchDescription: json['matchDescription'] ?? '',
      matchFormat: json['matchFormat'] ?? '',
      matchType: json['matchType'] ?? '',
      complete: json['complete'] ?? false,
      domestic: json['domestic'] ?? false,
      matchStartTimestamp: json['matchStartTimestamp'] ?? 0,
      matchCompleteTimestamp: json['matchCompleteTimestamp'] ?? 0,
      dayNight: json['dayNight'] ?? false,
      year: json['year'] ?? 0,
      state: json['state'] ?? '',
      status: json['status'] ?? '',
    );
  }
}