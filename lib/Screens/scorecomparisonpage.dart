import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_page/Models/CricketModel.dart';

class ScoreComparisonPage extends StatefulWidget {
  final int matchId;
  final String poolType;
  final String poolName;

  ScoreComparisonPage({
    required this.matchId,
    required this.poolType,
    required this.poolName,
  });

  @override
  _ScoreComparisonPageState createState() => _ScoreComparisonPageState();
}

class _ScoreComparisonPageState extends State<ScoreComparisonPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late Future<ScoreCard> futureScoreCard;
  late Future<Map<String, dynamic>> futurePredictedScores;

  @override
  void initState() {
    super.initState();
    futureScoreCard = fetchScoreCard(widget.matchId);
    futurePredictedScores = fetchPredictedScores();
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

  Future<Map<String, dynamic>> fetchPredictedScores() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user is currently signed in');
      }

      DocumentSnapshot poolSnapshot = await _firestore
          .collection('Pool')
          .doc(widget.poolType)
          .get();

      if (!poolSnapshot.exists) {
        throw Exception('Pool does not exist');
      }

      Map<String, dynamic>? data = poolSnapshot.data() as Map<String, dynamic>?;
      Map<String, dynamic> matches = data?['matches'] ?? {};

      if (!matches.containsKey(widget.matchId.toString())) {
        throw Exception('Match not found in pool');
      }

      Map<String, dynamic> matchData = matches[widget.matchId.toString()];
      if (!matchData.containsKey(widget.poolName)) {
        throw Exception('Pool name not found in match');
      }

      Map<String, dynamic> poolData = matchData[widget.poolName];
      if (!poolData['userJoins'].containsKey(userId)) {
        throw Exception('User not found in pool');
      }

      return poolData['userJoins'][userId];
    } catch (e) {
      print('Error fetching predicted scores: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Comparison'),
      ),
      body: FutureBuilder(
        future: Future.wait([futureScoreCard, futurePredictedScores]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            ScoreCard scoreCard = snapshot.data![0];
            Map<String, dynamic> predictedScores = snapshot.data![1];
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Match ID: ${widget.matchId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    for (var innings in scoreCard.innings)
                      _buildInningsComparison(innings, predictedScores),
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

 Widget _buildInningsComparison(InningsDetails innings, Map<String, dynamic> predictedScores) {
    Set<String> allPlayers = Set<String>();
    allPlayers.addAll(innings.batTeamDetails.batsmenData.values.map((batsman) => batsman.batName));
    allPlayers.addAll(innings.bowlTeamDetails.bowlersData.values.map((bowler) => bowler.bowlName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(innings.batTeamDetails.batTeamName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Actual Score: ${innings.scoreDetails.runs}/${innings.scoreDetails.wickets} (${innings.scoreDetails.overs} overs)'),
        SizedBox(height: 16),
        Text('Player Comparisons:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          columnWidths: {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: ['Player', 'Pred. Runs', 'Actual Runs', 'Pred. Wkts', 'Actual Wkts']
                  .map((e) => TableCell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(e, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ))
                  .toList(),
            ),
            ...allPlayers.map((playerName) {
              var predictedPlayer = _findPredictedPlayer(predictedScores, playerName);
              var actualBatsman = innings.batTeamDetails.batsmenData.values
                  .firstWhere(
                    (batsman) => batsman.batName == playerName,
                    orElse: () => BatsmenDatum(
                      batId: 0,
                      batName: playerName,
                      runs: 0,
                      balls: 0,
                      fours: 0,
                      sixes: 0,
                      strikeRate: 0.0,
                      outDesc: '',
                      isCaptain: false,
                      isKeeper: false,
                    ),
                  );
              var actualBowler = innings.bowlTeamDetails.bowlersData.values
                  .firstWhere(
                    (bowler) => bowler.bowlName == playerName,
                    orElse: () => BowlerDatum(
                      bowlerId: 0,
                      bowlName: playerName,
                      overs: 0,
                      maidens: 0,
                      runs: 0,
                      wickets: 0,
                      economy: 0.0,
                      isCaptain: false,
                      isKeeper: false,
                    ),
                  );
              
              return TableRow(
                children: [
                  TableCell(child: Text(playerName)),
                  TableCell(child: Text(predictedPlayer?['PredictedRuns']?.toString() ?? 'N/A')),
                  TableCell(child: Text(actualBatsman.runs.toString())),
                  TableCell(child: Text(predictedPlayer?['PredictedWickets']?.toString() ?? 'N/A')),
                  TableCell(child: Text(actualBowler.wickets.toString())),
                ],
              );
            }),
          ],
        ),
        SizedBox(height: 32),
      ],
    );
  }

  Map<String, dynamic>? _findPredictedPlayer(Map<String, dynamic> predictedScores, String playerName) {
    List<dynamic> teams = predictedScores['teams'] ?? [];
    for (var team in teams) {
      List<dynamic> players = team['players'] ?? [];
      for (var player in players) {
        if (player['PlayerName'] == playerName) {
          return player;
        }
      }
    }
    return null;
  }
}
