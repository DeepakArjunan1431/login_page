import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScoreCard {
  final BatTeamDetails batTeamDetails;
  final BowlTeamDetails bowlTeamDetails;
  final ScoreDetails scoreDetails;
  final Map<String, WicketsDatum> wicketsData;

  ScoreCard({
    required this.batTeamDetails,
    required this.bowlTeamDetails,
    required this.scoreDetails,
    required this.wicketsData,
  });

  factory ScoreCard.fromJson(Map<String, dynamic> json) {
    var scoreCardData = json['scoreCard'][0];
    return ScoreCard(
      batTeamDetails: BatTeamDetails.fromJson(scoreCardData['batTeamDetails'] ?? {}),
      bowlTeamDetails: BowlTeamDetails.fromJson(scoreCardData['bowlTeamDetails'] ?? {}),
      scoreDetails: ScoreDetails.fromJson(scoreCardData['scoreDetails'] ?? {}),
      wicketsData: (scoreCardData['wicketsData'] as Map<String, dynamic>?)?.map(
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

Future<ScoreCard> fetchScoreCard(int matchId) async {
  final url = 'https://cricbuzz-cricket.p.rapidapi.com/mcenter/v1/$matchId/scard';
  final headers = {
    'X-RapidAPI-Key': '01fed8d85dmsh775f48123e4a9fbp1bb2e5jsn73b9525de68c',
    'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ScoreCard.fromJson(jsonData);
    } else {
      throw Exception('Failed to load scorecard: HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load scorecard: $e');
  }
}

class ScoreDetailsPage extends StatefulWidget {
  final int matchId;

  ScoreDetailsPage({required this.matchId});

  @override
  _ScoreDetailsPageState createState() => _ScoreDetailsPageState();
}

class _ScoreDetailsPageState extends State<ScoreDetailsPage> {
  late Future<ScoreCard> futureScoreCard;

  @override
  void initState() {
    super.initState();
    futureScoreCard = fetchScoreCard(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Details'),
      ),
      body: FutureBuilder<ScoreCard>(
        future: futureScoreCard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading scorecard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('${snapshot.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureScoreCard = fetchScoreCard(widget.matchId);
                        });
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final scoreCard = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scoreCard.batTeamDetails.batTeamName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${scoreCard.scoreDetails.runs}/${scoreCard.scoreDetails.wickets} (${scoreCard.scoreDetails.overs} overs)',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Text('Run Rate: ${scoreCard.scoreDetails.runRate.toStringAsFixed(2)}'),
                    SizedBox(height: 16),
                    Text('Batsmen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...scoreCard.batTeamDetails.batsmenData.values.map((batsman) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${batsman.batName} ${batsman.isCaptain ? "(C)" : ""} ${batsman.isKeeper ? "(WK)" : ""}'),
                            ),
                            Text('${batsman.runs} (${batsman.balls})'),
                            Text('SR: ${batsman.strikeRate.toStringAsFixed(2)}'),
                          ],
                        ),
                      )
                    ).toList(),
                    SizedBox(height: 16),
                    Text('Bowlers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...scoreCard.bowlTeamDetails.bowlersData.values.map((bowler) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${bowler.bowlName} ${bowler.isCaptain ? "(C)" : ""} ${bowler.isKeeper ? "(WK)" : ""}'),
                            ),
                            Text('${bowler.overs}-${bowler.maidens}-${bowler.runs}-${bowler.wickets}'),
                            Text('Econ: ${bowler.economy.toStringAsFixed(2)}'),
                          ],
                        ),
                      )
                    ).toList(),
                    SizedBox(height: 16),
                    Text('Wickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...scoreCard.wicketsData.values.map((wicket) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('${wicket.batName} - ${wicket.wicketDesc}'),
                      )
                    ).toList(),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}