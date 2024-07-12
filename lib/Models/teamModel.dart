// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
    Players players;

    Welcome({
        required this.players,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        players: Players.fromJson(json["players"]),
    );

    Map<String, dynamic> toJson() => {
        "players": players.toJson(),
    };
}

class Players {
    List<Bench> playingXi;
    List<Bench> bench;

    Players({
        required this.playingXi,
        required this.bench,
    });

    factory Players.fromJson(Map<String, dynamic> json) => Players(
        playingXi: List<Bench>.from(json["playing XI"].map((x) => Bench.fromJson(x))),
        bench: List<Bench>.from(json["bench"].map((x) => Bench.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "playing XI": List<dynamic>.from(playingXi.map((x) => x.toJson())),
        "bench": List<dynamic>.from(bench.map((x) => x.toJson())),
    };
}

class Bench {
    int id;
    String name;
    String fullName;
    String nickName;
    bool captain;
    String role;
    bool keeper;
    bool substitute;
    int teamId;
    BattingStyle battingStyle;
    String bowlingStyle;
    TeamName teamName;
    int faceImageId;

    Bench({
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

    factory Bench.fromJson(Map<String, dynamic> json) => Bench(
        id: json["id"],
        name: json["name"],
        fullName: json["fullName"],
        nickName: json["nickName"],
        captain: json["captain"],
        role: json["role"],
        keeper: json["keeper"],
        substitute: json["substitute"],
        teamId: json["teamId"],
        battingStyle: battingStyleValues.map[json["battingStyle"]]!,
        bowlingStyle: json["bowlingStyle"],
        teamName: teamNameValues.map[json["teamName"]]!,
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
        "battingStyle": battingStyleValues.reverse[battingStyle],
        "bowlingStyle": bowlingStyle,
        "teamName": teamNameValues.reverse[teamName],
        "faceImageId": faceImageId,
    };
}

enum BattingStyle {
    LEFT_HAND_BAT,
    RIGHT_HAND_BAT
}

final battingStyleValues = EnumValues({
    "Left-hand bat": BattingStyle.LEFT_HAND_BAT,
    "Right-hand bat": BattingStyle.RIGHT_HAND_BAT
});

enum TeamName {
    ENGLAND
}

final teamNameValues = EnumValues({
    "England": TeamName.ENGLAND
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
