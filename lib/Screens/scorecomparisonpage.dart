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
  
  Future<ScoreCard>? _futureScoreCard;
  Future<List<Map<String, dynamic>>>? _futureSelectedPlayers;
  int _totalScore = 0; // New variable to keep track of total score

  @override
  void initState() {
    super.initState();
    _futureScoreCard = fetchScoreCard(widget.matchId);
    _futureSelectedPlayers = fetchSelectedPlayers();
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

  Future<List<Map<String, dynamic>>> fetchSelectedPlayers() async {
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

      List<Map<String, dynamic>> selectedPlayers = [];
      List<dynamic> teams = poolData['userJoins'][userId]['teams'] ?? [];
      for (var team in teams) {
        List<dynamic> players = team['players'] ?? [];
        for (var player in players) {
          int priority = player['Priority'] ?? 999;
          selectedPlayers.add({
            ...player,
            'priority': priority,
          });
        }
      }

      selectedPlayers.sort((a, b) => (b['priority'] as num).compareTo(a['priority'] as num));

      return selectedPlayers;
    } catch (e) {
      print('Error fetching selected players: $e');
      rethrow;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Comparison'),
      ),
      body: FutureBuilder(
        future: Future.wait([_futureScoreCard!, _futureSelectedPlayers!]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            ScoreCard scoreCard = snapshot.data![0];
            List<Map<String, dynamic>> selectedPlayers = snapshot.data![1];
            return _buildComparison(scoreCard, selectedPlayers);
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildComparison(ScoreCard scoreCard, List<Map<String, dynamic>> selectedPlayers) {
  _totalScore = 0; // Reset total score before building the list
  return ListView(
    padding: EdgeInsets.all(16.0),
    children: [
      Text('Match ID: ${widget.matchId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 16),
      Text('Player Comparisons:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      ...selectedPlayers.map((player) => _buildPlayerCard(player, scoreCard)),
      SizedBox(height: 16),
      // New Total Score UI
      _buildTotalScoreCard(), // Call the new method for the total score
    ],
  );
}

Widget _buildTotalScoreCard() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.greenAccent, Colors.blueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.6),
          spreadRadius: 3,
          blurRadius: 8,
          offset: Offset(2, 4), // changes position of shadow
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total Score',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '$_totalScore',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildPlayerCard(Map<String, dynamic> player, ScoreCard scoreCard) {
    String playerName = player['PlayerName'] ?? 'Unknown';
    String teamName = player['TeamName'] ?? 'Unknown';
    String playerId = player['PlayerId']?.toString() ?? 'N/A';
    int priority = player['priority'] ?? 999;
    
    var actualBatsman = scoreCard.innings.expand((innings) => innings.batTeamDetails.batsmenData.values)
        .firstWhere(
          (batsman) => batsman.batId.toString() == playerId,
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
    var actualBowler = scoreCard.innings.expand((innings) => innings.bowlTeamDetails.bowlersData.values)
        .firstWhere(
          (bowler) => bowler.bowlerId.toString() == playerId,
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

    int calculatedScore = _calculateScore(player, actualBatsman, actualBowler);
    _totalScore += calculatedScore; // Add to total score

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(playerName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Team: $teamName | Player ID: $playerId | Priority: $priority', 
                 style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('Runs', player['PredictedRuns']?.toString() ?? 'N/A', actualBatsman.runs.toString()),
                _buildStatColumn('Wickets', player['PredictedWickets']?.toString() ?? 'N/A', actualBowler.wickets.toString()),
              ],
            ),
            SizedBox(height: 12),
            Text('Calculated Score: $calculatedScore', 
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }


  int _calculateScore(Map<String, dynamic> player, BatsmenDatum actualBatsman, BowlerDatum actualBowler) {
  int priority = player['priority'] ?? 999;
  int predictedRunsLow = int.tryParse(player['PredictedRuns'].toString().split('-')[0]) ?? 0;
  int predictedRunsHigh = int.tryParse(player['PredictedRuns'].toString().split('-')[1]) ?? 0;
  int predictedWickets = int.tryParse(player['PredictedWickets'].toString()) ?? 0;
  int actualRuns = actualBatsman.runs;
  int actualWickets = actualBowler.wickets;

  bool runsMatch = actualRuns >= predictedRunsLow && actualRuns <= predictedRunsHigh;
  bool wicketsMatch = actualWickets == predictedWickets;

  if (runsMatch && wicketsMatch) {
    return priority;
  } else if (wicketsMatch && predictedWickets > 0) {
    return priority;  // This line ensures bowlers like Manan Sharma get their priority score
  } else if (runsMatch && (predictedRunsLow > 0 || predictedRunsHigh > 0)) {
    return priority;
  } else {
    return 0;
  }
}
  Widget _buildStatColumn(String label, String predicted, String actual) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Predicted:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text('Actual:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(predicted, style: TextStyle(fontSize: 14)),
                Text(actual, style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}