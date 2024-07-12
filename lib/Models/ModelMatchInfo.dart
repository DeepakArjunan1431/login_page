// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
    MatchInfo matchInfo;
    VenueInfo venueInfo;
    // List<dynamic> broadcastInfo;

    Welcome({
        required this.matchInfo,
        required this.venueInfo,
        // required this.broadcastInfo,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        matchInfo: MatchInfo.fromJson(json["matchInfo"]),
        venueInfo: VenueInfo.fromJson(json["venueInfo"]),
        // broadcastInfo: List<dynamic>.from(json["broadcastInfo"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "matchInfo": matchInfo.toJson(),
        "venueInfo": venueInfo.toJson(),
        // "broadcastInfo": List<dynamic>.from(broadcastInfo.map((x) => x)),
    };
}

class MatchInfo {
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
    Team team1;
    Team team2;
    Series series;
    Referee umpire1;
    Referee umpire2;
    Referee umpire3;
    Referee referee;
    RevisedTarget tossResults;
    Result result;
    Venue venue;
    String status;
    List<Player> playersOfTheMatch;
    List<dynamic> playersOfTheSeries;
    RevisedTarget revisedTarget;
    List<MatchTeamInfo> matchTeamInfo;
    bool isMatchNotCovered;
    int hysEnabled;
    bool livestreamEnabled;
    bool isFantasyEnabled;
    List<dynamic> livestreamEnabledGeo;
    String alertType;
    String shortStatus;
    int matchImageId;

    MatchInfo({
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
        required this.team1,
        required this.team2,
        required this.series,
        required this.umpire1,
        required this.umpire2,
        required this.umpire3,
        required this.referee,
        required this.tossResults,
        required this.result,
        required this.venue,
        required this.status,
        required this.playersOfTheMatch,
        required this.playersOfTheSeries,
        required this.revisedTarget,
        required this.matchTeamInfo,
        required this.isMatchNotCovered,
        required this.hysEnabled,
        required this.livestreamEnabled,
        required this.isFantasyEnabled,
        required this.livestreamEnabledGeo,
        required this.alertType,
        required this.shortStatus,
        required this.matchImageId,
    });

    factory MatchInfo.fromJson(Map<String, dynamic> json) => MatchInfo(
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
        team1: Team.fromJson(json["team1"]),
        team2: Team.fromJson(json["team2"]),
        series: Series.fromJson(json["series"]),
        umpire1: Referee.fromJson(json["umpire1"]),
        umpire2: Referee.fromJson(json["umpire2"]),
        umpire3: Referee.fromJson(json["umpire3"]),
        referee: Referee.fromJson(json["referee"]),
        tossResults: RevisedTarget.fromJson(json["tossResults"]),
        result: Result.fromJson(json["result"]),
        venue: Venue.fromJson(json["venue"]),
        status: json["status"],
        playersOfTheMatch: List<Player>.from(json["playersOfTheMatch"].map((x) => Player.fromJson(x))),
        playersOfTheSeries: List<dynamic>.from(json["playersOfTheSeries"].map((x) => x)),
        revisedTarget: RevisedTarget.fromJson(json["revisedTarget"]),
        matchTeamInfo: List<MatchTeamInfo>.from(json["matchTeamInfo"].map((x) => MatchTeamInfo.fromJson(x))),
        isMatchNotCovered: json["isMatchNotCovered"],
        hysEnabled: json["HYSEnabled"],
        livestreamEnabled: json["livestreamEnabled"],
        isFantasyEnabled: json["isFantasyEnabled"],
        livestreamEnabledGeo: List<dynamic>.from(json["livestreamEnabledGeo"].map((x) => x)),
        alertType: json["alertType"],
        shortStatus: json["shortStatus"],
        matchImageId: json["matchImageId"],
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
        "team1": team1.toJson(),
        "team2": team2.toJson(),
        "series": series.toJson(),
        "umpire1": umpire1.toJson(),
        "umpire2": umpire2.toJson(),
        "umpire3": umpire3.toJson(),
        "referee": referee.toJson(),
        "tossResults": tossResults.toJson(),
        "result": result.toJson(),
        "venue": venue.toJson(),
        "status": status,
        "playersOfTheMatch": List<dynamic>.from(playersOfTheMatch.map((x) => x.toJson())),
        "playersOfTheSeries": List<dynamic>.from(playersOfTheSeries.map((x) => x)),
        "revisedTarget": revisedTarget.toJson(),
        "matchTeamInfo": List<dynamic>.from(matchTeamInfo.map((x) => x.toJson())),
        "isMatchNotCovered": isMatchNotCovered,
        "HYSEnabled": hysEnabled,
        "livestreamEnabled": livestreamEnabled,
        "isFantasyEnabled": isFantasyEnabled,
        "livestreamEnabledGeo": List<dynamic>.from(livestreamEnabledGeo.map((x) => x)),
        "alertType": alertType,
        "shortStatus": shortStatus,
        "matchImageId": matchImageId,
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

class Player {
    int id;
    String name;
    String fullName;
    String nickName;
    bool captain;
    Role role;
    bool keeper;
    bool substitute;
    int teamId;
    BattingStyle battingStyle;
    String bowlingStyle;
    WinningTeam teamName;
    int faceImageId;

    Player({
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

    factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json["id"],
        name: json["name"],
        fullName: json["fullName"],
        nickName: json["nickName"],
        captain: json["captain"],
        role: roleValues.map[json["role"]]!,
        keeper: json["keeper"],
        substitute: json["substitute"],
        teamId: json["teamId"],
        battingStyle: battingStyleValues.map[json["battingStyle"]]!,
        bowlingStyle: json["bowlingStyle"],
        teamName: winningTeamValues.map[json["teamName"]]!,
        faceImageId: json["faceImageId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "fullName": fullName,
        "nickName": nickName,
        "captain": captain,
        "role": roleValues.reverse[role],
        "keeper": keeper,
        "substitute": substitute,
        "teamId": teamId,
        "battingStyle": battingStyleValues.reverse[battingStyle],
        "bowlingStyle": bowlingStyle,
        "teamName": winningTeamValues.reverse[teamName],
        "faceImageId": faceImageId,
    };
}

enum BattingStyle {
    EMPTY,
    LEFT_HAND_BAT,
    RIGHT_HAND_BAT
}

final battingStyleValues = EnumValues({
    " ": BattingStyle.EMPTY,
    "Left-hand bat": BattingStyle.LEFT_HAND_BAT,
    "Right-hand bat": BattingStyle.RIGHT_HAND_BAT
});

enum Role {
    BATSMAN,
    BATTING_ALLROUNDER,
    BOWLER,
    WK_BATSMAN
}

final roleValues = EnumValues({
    "Batsman": Role.BATSMAN,
    "Batting Allrounder": Role.BATTING_ALLROUNDER,
    "Bowler": Role.BOWLER,
    "WK-Batsman": Role.WK_BATSMAN
});

enum WinningTeam {
    AFGHANISTAN_U19,
    EMPTY,
    UNITED_ARAB_EMIRATES_U19
}

final winningTeamValues = EnumValues({
    "Afghanistan U19": WinningTeam.AFGHANISTAN_U19,
    " ": WinningTeam.EMPTY,
    "United Arab Emirates U19": WinningTeam.UNITED_ARAB_EMIRATES_U19
});

class Referee {
    int id;
    String name;
    String country;

    Referee({
        required this.id,
        required this.name,
        required this.country,
    });

    factory Referee.fromJson(Map<String, dynamic> json) => Referee(
        id: json["id"],
        name: json["name"],
        country: json["country"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country": country,
    };
}

class Result {
    String resultType;
    WinningTeam winningTeam;
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
        winningTeam: winningTeamValues.map[json["winningTeam"]]!,
        winningteamId: json["winningteamId"],
        winningMargin: json["winningMargin"],
        winByRuns: json["winByRuns"],
        winByInnings: json["winByInnings"],
    );

    Map<String, dynamic> toJson() => {
        "resultType": resultType,
        "winningTeam": winningTeamValues.reverse[winningTeam],
        "winningteamId": winningteamId,
        "winningMargin": winningMargin,
        "winByRuns": winByRuns,
        "winByInnings": winByInnings,
    };
}

class RevisedTarget {
    RevisedTarget();

    factory RevisedTarget.fromJson(Map<String, dynamic> json) => RevisedTarget(
    );

    Map<String, dynamic> toJson() => {
    };
}

class Series {
    int id;
    String name;
    String seriesType;
    int startDate;
    int endDate;
    String seriesFolder;
    String odiSeriesResult;
    String t20SeriesResult;
    String testSeriesResult;
    bool tournament;

    Series({
        required this.id,
        required this.name,
        required this.seriesType,
        required this.startDate,
        required this.endDate,
        required this.seriesFolder,
        required this.odiSeriesResult,
        required this.t20SeriesResult,
        required this.testSeriesResult,
        required this.tournament,
    });

    factory Series.fromJson(Map<String, dynamic> json) => Series(
        id: json["id"],
        name: json["name"],
        seriesType: json["seriesType"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        seriesFolder: json["seriesFolder"],
        odiSeriesResult: json["odiSeriesResult"],
        t20SeriesResult: json["t20SeriesResult"],
        testSeriesResult: json["testSeriesResult"],
        tournament: json["tournament"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "seriesType": seriesType,
        "startDate": startDate,
        "endDate": endDate,
        "seriesFolder": seriesFolder,
        "odiSeriesResult": odiSeriesResult,
        "t20SeriesResult": t20SeriesResult,
        "testSeriesResult": testSeriesResult,
        "tournament": tournament,
    };
}

class Team {
    int id;
    WinningTeam name;
    List<Player> playerDetails;
    String shortName;

    Team({
        required this.id,
        required this.name,
        required this.playerDetails,
        required this.shortName,
    });

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json["id"],
        name: winningTeamValues.map[json["name"]]!,
        playerDetails: List<Player>.from(json["playerDetails"].map((x) => Player.fromJson(x))),
        shortName: json["shortName"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": winningTeamValues.reverse[name],
        "playerDetails": List<dynamic>.from(playerDetails.map((x) => x.toJson())),
        "shortName": shortName,
    };
}

class Venue {
    int id;
    String name;
    String city;
    String country;
    String timezone;
    String latitude;
    String longitude;

    Venue({
        required this.id,
        required this.name,
        required this.city,
        required this.country,
        required this.timezone,
        required this.latitude,
        required this.longitude,
    });

    factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json["id"],
        name: json["name"],
        city: json["city"],
        country: json["country"],
        timezone: json["timezone"],
        latitude: json["latitude"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "city": city,
        "country": country,
        "timezone": timezone,
        "latitude": latitude,
        "longitude": longitude,
    };
}

class VenueInfo {
    int established;
    dynamic capacity;
    String knownAs;
    String ends;
    String city;
    String country;
    String timezone;
    String homeTeam;
    bool floodlights;
    String curator;
    dynamic profile;
    String imageUrl;
    String ground;
    int groundLength;
    int groundWidth;
    dynamic otherSports;

    VenueInfo({
        required this.established,
        required this.capacity,
        required this.knownAs,
        required this.ends,
        required this.city,
        required this.country,
        required this.timezone,
        required this.homeTeam,
        required this.floodlights,
        required this.curator,
        required this.profile,
        required this.imageUrl,
        required this.ground,
        required this.groundLength,
        required this.groundWidth,
        required this.otherSports,
    });

    factory VenueInfo.fromJson(Map<String, dynamic> json) => VenueInfo(
        established: json["established"],
        capacity: json["capacity"],
        knownAs: json["knownAs"],
        ends: json["ends"],
        city: json["city"],
        country: json["country"],
        timezone: json["timezone"],
        homeTeam: json["homeTeam"],
        floodlights: json["floodlights"],
        curator: json["curator"],
        profile: json["profile"],
        imageUrl: json["imageUrl"],
        ground: json["ground"],
        groundLength: json["groundLength"],
        groundWidth: json["groundWidth"],
        otherSports: json["otherSports"],
    );

    Map<String, dynamic> toJson() => {
        "established": established,
        "capacity": capacity,
        "knownAs": knownAs,
        "ends": ends,
        "city": city,
        "country": country,
        "timezone": timezone,
        "homeTeam": homeTeam,
        "floodlights": floodlights,
        "curator": curator,
        "profile": profile,
        "imageUrl": imageUrl,
        "ground": ground,
        "groundLength": groundLength,
        "groundWidth": groundWidth,
        "otherSports": otherSports,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
class TeamDetails {
  final int id;
  final int teamId;
  final String name; // <-- The attribute you want to fetch
  final String shortName;
  final List<PlayerDetails> playerDetails;

  TeamDetails({
    required this.id,
    required this.teamId,
    required this.name,
    required this.shortName,
    required this.playerDetails,
  });

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      id: json['id'],
      teamId: json['teamId'],
      name: json['name'],
      shortName: json['shortName'],
      playerDetails: (json['playerDetails'] as List)
          .map((player) => PlayerDetails.fromJson(player))
          .toList(),
    );
  }

  static String getNameFromJson(Map<String, dynamic> json) {
    return json['name'];
  }
}


class PlayerDetails {
  final int id;
  final String fullName;
  final String nickName;
  final bool captain;
  final bool keeper;
  final bool substitute;

  PlayerDetails({
    required this.id,
    required this.fullName,
    required this.nickName,
    required this.captain,
    required this.keeper,
    required this.substitute,
  });

  factory PlayerDetails.fromJson(Map<String, dynamic> json) {
    return PlayerDetails(
      id: json['id'],
      fullName: json['fullName'],
      nickName: json['nickName'] ?? '',
      captain: json['captain'] ?? false,
      keeper: json['keeper'] ?? false,
      substitute: json['substitute'] ?? false,
    );
  }
}
