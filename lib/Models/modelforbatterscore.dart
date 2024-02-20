// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomedFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomedToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  List<ScoreCard> scoreCard;
  MatchHeader matchHeader;
  bool isMatchComplete;
  String status;
  List<dynamic> videos;
  int responseLastUpdated;

  Welcome({
    required this.scoreCard,
    required this.matchHeader,
    required this.isMatchComplete,
    required this.status,
    required this.videos,
    required this.responseLastUpdated,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        scoreCard: List<ScoreCard>.from(
            json["scoreCard"].map((x) => ScoreCard.fromJson(x))),
        matchHeader: MatchHeader.fromJson(json["matchHeader"]),
        isMatchComplete: json["isMatchComplete"],
        status: json["status"],
        videos: List<dynamic>.from(json["videos"].map((x) => x)),
        responseLastUpdated: json["responseLastUpdated"],
      );

  Map<String, dynamic> toJson() => {
        "scoreCard": List<dynamic>.from(scoreCard.map((x) => x.toJson())),
        "matchHeader": matchHeader.toJson(),
        "isMatchComplete": isMatchComplete,
        "status": status,
        "videos": List<dynamic>.from(videos.map((x) => x)),
        "responseLastUpdated": responseLastUpdated,
      };
}

class MatchHeader {
  int matchId;
  String matchDescription;
  String matchFormat;
  String matchType;
  bool complete;
  bool domestic;
  int matchStartTimestamp;
  int matchCompleteTimestamp;
  bool dayNight;
  int year;
  int dayNumber;
  String state;
  String status;
  RevisedTarget tossResults;
  Result result;
  RevisedTarget revisedTarget;
  List<PlayersOfThe> playersOfTheMatch;
  List<PlayersOfThe> playersOfTheSeries;
  List<MatchTeamInfo> matchTeamInfo;
  bool isMatchNotCovered;
  Team team1;
  Team team2;
  String seriesDesc;
  int seriesId;
  String seriesName;
  String alertType;
  bool livestreamEnabled;

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
    required this.dayNumber,
    required this.state,
    required this.status,
    required this.tossResults,
    required this.result,
    required this.revisedTarget,
    required this.playersOfTheMatch,
    required this.playersOfTheSeries,
    required this.matchTeamInfo,
    required this.isMatchNotCovered,
    required this.team1,
    required this.team2,
    required this.seriesDesc,
    required this.seriesId,
    required this.seriesName,
    required this.alertType,
    required this.livestreamEnabled,
  });

  factory MatchHeader.fromJson(Map<String, dynamic> json) => MatchHeader(
        matchId: json["matchId"],
        matchDescription: json["matchDescription"],
        matchFormat: json["matchFormat"],
        matchType: json["matchType"],
        complete: json["complete"],
        domestic: json["domestic"],
        matchStartTimestamp: json["matchStartTimestamp"],
        matchCompleteTimestamp: json["matchCompleteTimestamp"],
        dayNight: json["dayNight"],
        year: json["year"],
        dayNumber: json["dayNumber"],
        state: json["state"],
        status: json["status"],
        tossResults: RevisedTarget.fromJson(json["tossResults"]),
        result: Result.fromJson(json["result"]),
        revisedTarget: RevisedTarget.fromJson(json["revisedTarget"]),
        playersOfTheMatch: List<PlayersOfThe>.from(
            json["playersOfTheMatch"].map((x) => PlayersOfThe.fromJson(x))),
        playersOfTheSeries: List<PlayersOfThe>.from(
            json["playersOfTheSeries"].map((x) => PlayersOfThe.fromJson(x))),
        matchTeamInfo: List<MatchTeamInfo>.from(
            json["matchTeamInfo"].map((x) => MatchTeamInfo.fromJson(x))),
        isMatchNotCovered: json["isMatchNotCovered"],
        team1: Team.fromJson(json["team1"]),
        team2: Team.fromJson(json["team2"]),
        seriesDesc: json["seriesDesc"],
        seriesId: json["seriesId"],
        seriesName: json["seriesName"],
        alertType: json["alertType"],
        livestreamEnabled: json["livestreamEnabled"],
      );

  Map<String, dynamic> toJson() => {
        "matchId": matchId,
        "matchDescription": matchDescription,
        "matchFormat": matchFormat,
        "matchType": matchType,
        "complete": complete,
        "domestic": domestic,
        "matchStartTimestamp": matchStartTimestamp,
        "matchCompleteTimestamp": matchCompleteTimestamp,
        "dayNight": dayNight,
        "year": year,
        "dayNumber": dayNumber,
        "state": state,
        "status": status,
        "tossResults": tossResults.toJson(),
        "result": result.toJson(),
        "revisedTarget": revisedTarget.toJson(),
        "playersOfTheMatch":
            List<dynamic>.from(playersOfTheMatch.map((x) => x.toJson())),
        "playersOfTheSeries":
            List<dynamic>.from(playersOfTheSeries.map((x) => x.toJson())),
        "matchTeamInfo":
            List<dynamic>.from(matchTeamInfo.map((x) => x.toJson())),
        "isMatchNotCovered": isMatchNotCovered,
        "team1": team1.toJson(),
        "team2": team2.toJson(),
        "seriesDesc": seriesDesc,
        "seriesId": seriesId,
        "seriesName": seriesName,
        "alertType": alertType,
        "livestreamEnabled": livestreamEnabled,
      };
}

class MatchTeamInfo {
  int battingTeamId;
  String battingTeamShortName;
  int bowlingTeamId;
  String bowlingTeamShortName;

  MatchTeamInfo({
    required this.battingTeamId,
    required this.battingTeamShortName,
    required this.bowlingTeamId,
    required this.bowlingTeamShortName,
  });

  factory MatchTeamInfo.fromJson(Map<String, dynamic> json) => MatchTeamInfo(
        battingTeamId: json["battingTeamId"],
        battingTeamShortName: json["battingTeamShortName"],
        bowlingTeamId: json["bowlingTeamId"],
        bowlingTeamShortName: json["bowlingTeamShortName"],
      );

  Map<String, dynamic> toJson() => {
        "battingTeamId": battingTeamId,
        "battingTeamShortName": battingTeamShortName,
        "bowlingTeamId": bowlingTeamId,
        "bowlingTeamShortName": bowlingTeamShortName,
      };
}

class PlayersOfThe {
  int id;
  String name;
  String fullName;
  String nickName;
  bool captain;
  String role;
  bool keeper;
  bool substitute;
  int teamId;
  String battingStyle;
  String bowlingStyle;
  String teamName;
  int faceImageId;

  PlayersOfThe({
    required this.id,
    required this.name,
    required this.fullName,
    required this.nickName,
    required this.captain,
    required this.role,
    required this.keeper,
    required this.substitute,
    required this.teamId,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.teamName,
    required this.faceImageId,
  });

  factory PlayersOfThe.fromJson(Map<String, dynamic> json) => PlayersOfThe(
        id: json["id"],
        name: json["name"],
        fullName: json["fullName"],
        nickName: json["nickName"],
        captain: json["captain"],
        role: json["role"],
        keeper: json["keeper"],
        substitute: json["substitute"],
        teamId: json["teamId"],
        battingStyle: json["battingStyle"],
        bowlingStyle: json["bowlingStyle"],
        teamName: json["teamName"],
        faceImageId: json["faceImageId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "fullName": fullName,
        "nickName": nickName,
        "captain": captain,
        "role": role,
        "keeper": keeper,
        "substitute": substitute,
        "teamId": teamId,
        "battingStyle": battingStyle,
        "bowlingStyle": bowlingStyle,
        "teamName": teamName,
        "faceImageId": faceImageId,
      };
}

class Result {
  String resultType;
  String winningTeam;
  int winningteamId;
  int winningMargin;
  bool winByRuns;
  bool winByInnings;

  Result({
    required this.resultType,
    required this.winningTeam,
    required this.winningteamId,
    required this.winningMargin,
    required this.winByRuns,
    required this.winByInnings,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        resultType: json["resultType"],
        winningTeam: json["winningTeam"],
        winningteamId: json["winningteamId"],
        winningMargin: json["winningMargin"],
        winByRuns: json["winByRuns"],
        winByInnings: json["winByInnings"],
      );

  Map<String, dynamic> toJson() => {
        "resultType": resultType,
        "winningTeam": winningTeam,
        "winningteamId": winningteamId,
        "winningMargin": winningMargin,
        "winByRuns": winByRuns,
        "winByInnings": winByInnings,
      };
}

class RevisedTarget {
  RevisedTarget();

  factory RevisedTarget.fromJson(Map<String, dynamic> json) => RevisedTarget();

  Map<String, dynamic> toJson() => {};
}

class Team {
  int id;
  String name;
  List<dynamic> playerDetails;
  String shortName;

  Team({
    required this.id,
    required this.name,
    required this.playerDetails,
    required this.shortName,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json["id"],
        name: json["name"],
        playerDetails: List<dynamic>.from(json["playerDetails"].map((x) => x)),
        shortName: json["shortName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "playerDetails": List<dynamic>.from(playerDetails.map((x) => x)),
        "shortName": shortName,
      };
}

class ScoreCard {
  int matchId;
  int inningsId;
  int timeScore;
  BatTeamDetails batTeamDetails;
  BowlTeamDetails bowlTeamDetails;
  ScoreDetails scoreDetails;
  ExtrasData extrasData;
  PpData ppData;
  Map<String, WicketsDatum> wicketsData;
  Map<String, PartnershipsDatum> partnershipsData;

  ScoreCard({
    required this.matchId,
    required this.inningsId,
    required this.timeScore,
    required this.batTeamDetails,
    required this.bowlTeamDetails,
    required this.scoreDetails,
    required this.extrasData,
    required this.ppData,
    required this.wicketsData,
    required this.partnershipsData,
  });

  factory ScoreCard.fromJson(Map<String, dynamic> json) => ScoreCard(
        matchId: json["matchId"],
        inningsId: json["inningsId"],
        timeScore: json["timeScore"],
        batTeamDetails: BatTeamDetails.fromJson(json["batTeamDetails"]),
        bowlTeamDetails: BowlTeamDetails.fromJson(json["bowlTeamDetails"]),
        scoreDetails: ScoreDetails.fromJson(json["scoreDetails"]),
        extrasData: ExtrasData.fromJson(json["extrasData"]),
        ppData: PpData.fromJson(json["ppData"]),
        wicketsData: Map.from(json["wicketsData"]).map((k, v) =>
            MapEntry<String, WicketsDatum>(k, WicketsDatum.fromJson(v))),
        partnershipsData: Map.from(json["partnershipsData"]).map((k, v) =>
            MapEntry<String, PartnershipsDatum>(
                k, PartnershipsDatum.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "matchId": matchId,
        "inningsId": inningsId,
        "timeScore": timeScore,
        "batTeamDetails": batTeamDetails.toJson(),
        "bowlTeamDetails": bowlTeamDetails.toJson(),
        "scoreDetails": scoreDetails.toJson(),
        "extrasData": extrasData.toJson(),
        "ppData": ppData.toJson(),
        "wicketsData": Map.from(wicketsData)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "partnershipsData": Map.from(partnershipsData)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class BatTeamDetails {
  int batTeamId;
  String batTeamName;
  String batTeamShortName;
  Map<String, BatsmenDatum> batsmenData;

  BatTeamDetails({
    required this.batTeamId,
    required this.batTeamName,
    required this.batTeamShortName,
    required this.batsmenData,
  });

  factory BatTeamDetails.fromJson(Map<String, dynamic> json) => BatTeamDetails(
        batTeamId: json["batTeamId"],
        batTeamName: json["batTeamName"],
        batTeamShortName: json["batTeamShortName"],
        batsmenData: Map.from(json["batsmenData"]).map((k, v) =>
            MapEntry<String, BatsmenDatum>(k, BatsmenDatum.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "batTeamId": batTeamId,
        "batTeamName": batTeamName,
        "batTeamShortName": batTeamShortName,
        "batsmenData": Map.from(batsmenData)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class BatsmenDatum {
  int batId;
  String batName;
  String batShortName;
  bool isCaptain;
  bool isKeeper;
  int runs;
  int balls;
  int dots;
  int fours;
  int sixes;
  int mins;
  double strikeRate;
  String outDesc;
  int bowlerId;
  int fielderId1;
  int fielderId2;
  int fielderId3;
  int ones;
  int twos;
  int threes;
  int fives;
  int boundaries;
  int sixers;
  String wicketCode;
  bool isOverseas;
  String inMatchChange;
  String playingXiChange;

  BatsmenDatum({
    required this.batId,
    required this.batName,
    required this.batShortName,
    required this.isCaptain,
    required this.isKeeper,
    required this.runs,
    required this.balls,
    required this.dots,
    required this.fours,
    required this.sixes,
    required this.mins,
    required this.strikeRate,
    required this.outDesc,
    required this.bowlerId,
    required this.fielderId1,
    required this.fielderId2,
    required this.fielderId3,
    required this.ones,
    required this.twos,
    required this.threes,
    required this.fives,
    required this.boundaries,
    required this.sixers,
    required this.wicketCode,
    required this.isOverseas,
    required this.inMatchChange,
    required this.playingXiChange,
  });

  factory BatsmenDatum.fromJson(Map<String, dynamic> json) => BatsmenDatum(
        batId: json["batId"],
        batName: json["batName"],
        batShortName: json["batShortName"],
        isCaptain: json["isCaptain"],
        isKeeper: json["isKeeper"],
        runs: json["runs"],
        balls: json["balls"],
        dots: json["dots"],
        fours: json["fours"],
        sixes: json["sixes"],
        mins: json["mins"],
        strikeRate: json["strikeRate"]?.toDouble(),
        outDesc: json["outDesc"],
        bowlerId: json["bowlerId"],
        fielderId1: json["fielderId1"],
        fielderId2: json["fielderId2"],
        fielderId3: json["fielderId3"],
        ones: json["ones"],
        twos: json["twos"],
        threes: json["threes"],
        fives: json["fives"],
        boundaries: json["boundaries"],
        sixers: json["sixers"],
        wicketCode: json["wicketCode"],
        isOverseas: json["isOverseas"],
        inMatchChange: json["inMatchChange"],
        playingXiChange: json["playingXIChange"],
      );

  Map<String, dynamic> toJson() => {
        "batId": batId,
        "batName": batName,
        "batShortName": batShortName,
        "isCaptain": isCaptain,
        "isKeeper": isKeeper,
        "runs": runs,
        "balls": balls,
        "dots": dots,
        "fours": fours,
        "sixes": sixes,
        "mins": mins,
        "strikeRate": strikeRate,
        "outDesc": outDesc,
        "bowlerId": bowlerId,
        "fielderId1": fielderId1,
        "fielderId2": fielderId2,
        "fielderId3": fielderId3,
        "ones": ones,
        "twos": twos,
        "threes": threes,
        "fives": fives,
        "boundaries": boundaries,
        "sixers": sixers,
        "wicketCode": wicketCode,
        "isOverseas": isOverseas,
        "inMatchChange": inMatchChange,
        "playingXIChange": playingXiChange,
      };
}

class BowlTeamDetails {
  int bowlTeamId;
  String bowlTeamName;
  String bowlTeamShortName;
  BowlersData bowlersData;

  BowlTeamDetails({
    required this.bowlTeamId,
    required this.bowlTeamName,
    required this.bowlTeamShortName,
    required this.bowlersData,
  });

  factory BowlTeamDetails.fromJson(Map<String, dynamic> json) =>
      BowlTeamDetails(
        bowlTeamId: json["bowlTeamId"],
        bowlTeamName: json["bowlTeamName"],
        bowlTeamShortName: json["bowlTeamShortName"],
        bowlersData: BowlersData.fromJson(json["bowlersData"]),
      );

  Map<String, dynamic> toJson() => {
        "bowlTeamId": bowlTeamId,
        "bowlTeamName": bowlTeamName,
        "bowlTeamShortName": bowlTeamShortName,
        "bowlersData": bowlersData.toJson(),
      };
}

class BowlersData {
  Bowl bowl1;
  Bowl bowl4;
  Bowl bowl6;
  Bowl bowl5;
  Bowl bowl3;
  Bowl bowl2;

  BowlersData({
    required this.bowl1,
    required this.bowl4,
    required this.bowl6,
    required this.bowl5,
    required this.bowl3,
    required this.bowl2,
  });

  factory BowlersData.fromJson(Map<String, dynamic> json) => BowlersData(
        bowl1: Bowl.fromJson(json["bowl_1"]),
        bowl4: Bowl.fromJson(json["bowl_4"]),
        bowl6: Bowl.fromJson(json["bowl_6"]),
        bowl5: Bowl.fromJson(json["bowl_5"]),
        bowl3: Bowl.fromJson(json["bowl_3"]),
        bowl2: Bowl.fromJson(json["bowl_2"]),
      );

  Map<String, dynamic> toJson() => {
        "bowl_1": bowl1.toJson(),
        "bowl_4": bowl4.toJson(),
        "bowl_6": bowl6.toJson(),
        "bowl_5": bowl5.toJson(),
        "bowl_3": bowl3.toJson(),
        "bowl_2": bowl2.toJson(),
      };
}

class Bowl {
  int bowlerId;
  String bowlName;
  String bowlShortName;
  bool isCaptain;
  bool isKeeper;
  double overs;
  int maidens;
  int runs;
  int wickets;
  double economy;
  int noBalls;
  int wides;
  int dots;
  int balls;
  int runsPerBall;
  bool isOverseas;
  String inMatchChange;
  String playingXiChange;

  Bowl({
    required this.bowlerId,
    required this.bowlName,
    required this.bowlShortName,
    required this.isCaptain,
    required this.isKeeper,
    required this.overs,
    required this.maidens,
    required this.runs,
    required this.wickets,
    required this.economy,
    required this.noBalls,
    required this.wides,
    required this.dots,
    required this.balls,
    required this.runsPerBall,
    required this.isOverseas,
    required this.inMatchChange,
    required this.playingXiChange,
  });

  factory Bowl.fromJson(Map<String, dynamic> json) => Bowl(
        bowlerId: json["bowlerId"],
        bowlName: json["bowlName"],
        bowlShortName: json["bowlShortName"],
        isCaptain: json["isCaptain"],
        isKeeper: json["isKeeper"],
        overs: json["overs"]?.toDouble(),
        maidens: json["maidens"],
        runs: json["runs"],
        wickets: json["wickets"],
        economy: json["economy"]?.toDouble(),
        noBalls: json["no_balls"],
        wides: json["wides"],
        dots: json["dots"],
        balls: json["balls"],
        runsPerBall: json["runsPerBall"],
        isOverseas: json["isOverseas"],
        inMatchChange: json["inMatchChange"],
        playingXiChange: json["playingXIChange"],
      );

  Map<String, dynamic> toJson() => {
        "bowlerId": bowlerId,
        "bowlName": bowlName,
        "bowlShortName": bowlShortName,
        "isCaptain": isCaptain,
        "isKeeper": isKeeper,
        "overs": overs,
        "maidens": maidens,
        "runs": runs,
        "wickets": wickets,
        "economy": economy,
        "no_balls": noBalls,
        "wides": wides,
        "dots": dots,
        "balls": balls,
        "runsPerBall": runsPerBall,
        "isOverseas": isOverseas,
        "inMatchChange": inMatchChange,
        "playingXIChange": playingXiChange,
      };
}

class ExtrasData {
  int noBalls;
  int total;
  int byes;
  int penalty;
  int wides;
  int legByes;

  ExtrasData({
    required this.noBalls,
    required this.total,
    required this.byes,
    required this.penalty,
    required this.wides,
    required this.legByes,
  });

  factory ExtrasData.fromJson(Map<String, dynamic> json) => ExtrasData(
        noBalls: json["noBalls"],
        total: json["total"],
        byes: json["byes"],
        penalty: json["penalty"],
        wides: json["wides"],
        legByes: json["legByes"],
      );

  Map<String, dynamic> toJson() => {
        "noBalls": noBalls,
        "total": total,
        "byes": byes,
        "penalty": penalty,
        "wides": wides,
        "legByes": legByes,
      };
}

class PartnershipsDatum {
  int bat1Id;
  String bat1Name;
  int bat1Runs;
  int bat1Fours;
  int bat1Sixes;
  int bat2Id;
  String bat2Name;
  int bat2Runs;
  int bat2Fours;
  int bat2Sixes;
  int totalRuns;
  int totalBalls;
  int bat1Balls;
  int bat2Balls;
  int bat1Ones;
  int bat1Twos;
  int bat1Threes;
  int bat1Fives;
  int bat1Boundaries;
  int bat1Sixers;
  int bat2Ones;
  int bat2Twos;
  int bat2Threes;
  int bat2Fives;
  int bat2Boundaries;
  int bat2Sixers;

  PartnershipsDatum({
    required this.bat1Id,
    required this.bat1Name,
    required this.bat1Runs,
    required this.bat1Fours,
    required this.bat1Sixes,
    required this.bat2Id,
    required this.bat2Name,
    required this.bat2Runs,
    required this.bat2Fours,
    required this.bat2Sixes,
    required this.totalRuns,
    required this.totalBalls,
    required this.bat1Balls,
    required this.bat2Balls,
    required this.bat1Ones,
    required this.bat1Twos,
    required this.bat1Threes,
    required this.bat1Fives,
    required this.bat1Boundaries,
    required this.bat1Sixers,
    required this.bat2Ones,
    required this.bat2Twos,
    required this.bat2Threes,
    required this.bat2Fives,
    required this.bat2Boundaries,
    required this.bat2Sixers,
  });

  factory PartnershipsDatum.fromJson(Map<String, dynamic> json) =>
      PartnershipsDatum(
        bat1Id: json["bat1Id"],
        bat1Name: json["bat1Name"],
        bat1Runs: json["bat1Runs"],
        bat1Fours: json["bat1fours"],
        bat1Sixes: json["bat1sixes"],
        bat2Id: json["bat2Id"],
        bat2Name: json["bat2Name"],
        bat2Runs: json["bat2Runs"],
        bat2Fours: json["bat2fours"],
        bat2Sixes: json["bat2sixes"],
        totalRuns: json["totalRuns"],
        totalBalls: json["totalBalls"],
        bat1Balls: json["bat1balls"],
        bat2Balls: json["bat2balls"],
        bat1Ones: json["bat1Ones"],
        bat1Twos: json["bat1Twos"],
        bat1Threes: json["bat1Threes"],
        bat1Fives: json["bat1Fives"],
        bat1Boundaries: json["bat1Boundaries"],
        bat1Sixers: json["bat1Sixers"],
        bat2Ones: json["bat2Ones"],
        bat2Twos: json["bat2Twos"],
        bat2Threes: json["bat2Threes"],
        bat2Fives: json["bat2Fives"],
        bat2Boundaries: json["bat2Boundaries"],
        bat2Sixers: json["bat2Sixers"],
      );

  Map<String, dynamic> toJson() => {
        "bat1Id": bat1Id,
        "bat1Name": bat1Name,
        "bat1Runs": bat1Runs,
        "bat1fours": bat1Fours,
        "bat1sixes": bat1Sixes,
        "bat2Id": bat2Id,
        "bat2Name": bat2Name,
        "bat2Runs": bat2Runs,
        "bat2fours": bat2Fours,
        "bat2sixes": bat2Sixes,
        "totalRuns": totalRuns,
        "totalBalls": totalBalls,
        "bat1balls": bat1Balls,
        "bat2balls": bat2Balls,
        "bat1Ones": bat1Ones,
        "bat1Twos": bat1Twos,
        "bat1Threes": bat1Threes,
        "bat1Fives": bat1Fives,
        "bat1Boundaries": bat1Boundaries,
        "bat1Sixers": bat1Sixers,
        "bat2Ones": bat2Ones,
        "bat2Twos": bat2Twos,
        "bat2Threes": bat2Threes,
        "bat2Fives": bat2Fives,
        "bat2Boundaries": bat2Boundaries,
        "bat2Sixers": bat2Sixers,
      };
}

class PpData {
  Pp1 pp1;

  PpData({
    required this.pp1,
  });

  factory PpData.fromJson(Map<String, dynamic> json) => PpData(
        pp1: Pp1.fromJson(json["pp_1"]),
      );

  Map<String, dynamic> toJson() => {
        "pp_1": pp1.toJson(),
      };
}

class Pp1 {
  int ppId;
  double ppOversFrom;
  int ppOversTo;
  String ppType;
  int runsScored;

  Pp1({
    required this.ppId,
    required this.ppOversFrom,
    required this.ppOversTo,
    required this.ppType,
    required this.runsScored,
  });

  factory Pp1.fromJson(Map<String, dynamic> json) => Pp1(
        ppId: json["ppId"],
        ppOversFrom: json["ppOversFrom"]?.toDouble(),
        ppOversTo: json["ppOversTo"],
        ppType: json["ppType"],
        runsScored: json["runsScored"],
      );

  Map<String, dynamic> toJson() => {
        "ppId": ppId,
        "ppOversFrom": ppOversFrom,
        "ppOversTo": ppOversTo,
        "ppType": ppType,
        "runsScored": runsScored,
      };
}

class ScoreDetails {
  int ballNbr;
  bool isDeclared;
  bool isFollowOn;
  double overs;
  int revisedOvers;
  double runRate;
  int runs;
  int wickets;
  double runsPerBall;

  ScoreDetails({
    required this.ballNbr,
    required this.isDeclared,
    required this.isFollowOn,
    required this.overs,
    required this.revisedOvers,
    required this.runRate,
    required this.runs,
    required this.wickets,
    required this.runsPerBall,
  });

  factory ScoreDetails.fromJson(Map<String, dynamic> json) => ScoreDetails(
        ballNbr: json["ballNbr"],
        isDeclared: json["isDeclared"],
        isFollowOn: json["isFollowOn"],
        overs: json["overs"]?.toDouble(),
        revisedOvers: json["revisedOvers"],
        runRate: json["runRate"]?.toDouble(),
        runs: json["runs"],
        wickets: json["wickets"],
        runsPerBall: json["runsPerBall"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "ballNbr": ballNbr,
        "isDeclared": isDeclared,
        "isFollowOn": isFollowOn,
        "overs": overs,
        "revisedOvers": revisedOvers,
        "runRate": runRate,
        "runs": runs,
        "wickets": wickets,
        "runsPerBall": runsPerBall,
      };
}

class WicketsDatum {
  int batId;
  String batName;
  int wktNbr;
  double wktOver;
  int wktRuns;
  int ballNbr;

  WicketsDatum({
    required this.batId,
    required this.batName,
    required this.wktNbr,
    required this.wktOver,
    required this.wktRuns,
    required this.ballNbr,
  });

  factory WicketsDatum.fromJson(Map<String, dynamic> json) => WicketsDatum(
        batId: json["batId"],
        batName: json["batName"],
        wktNbr: json["wktNbr"],
        wktOver: json["wktOver"]?.toDouble(),
        wktRuns: json["wktRuns"],
        ballNbr: json["ballNbr"],
      );

  Map<String, dynamic> toJson() => {
        "batId": batId,
        "batName": batName,
        "wktNbr": wktNbr,
        "wktOver": wktOver,
        "wktRuns": wktRuns,
        "ballNbr": ballNbr,
      };
}
