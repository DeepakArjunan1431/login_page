import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/Models/CricketModel.dart';
import 'dart:convert';

// import 'Models/CricketModel.dart';  // Ensure your CricketModel.dart contains ScoreCard and player data models

class ComparePredictionsPage extends StatefulWidget {
  final int matchId;

  ComparePredictionsPage({required this.matchId});

  @override
  _ComparePredictionsPageState createState() => _ComparePredictionsPageState();
}

class _ComparePredictionsPageState extends State<ComparePredictionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<ScoreCard> futureScoreCard;
  List<Map<String, dynamic>> predictedPlayers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPredictedTeam();
    futureScoreCard = fetchScoreCard(widget.matchId);
  }

  Future<void> fetchPredictedTeam() async {
    try {
      String userId = "YourUserId"; // replace with your user ID fetching logic

      // Fetch predicted team from Firestore
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('predictedTeams')
          .doc(widget.matchId.toString())
          .get();

      if (snapshot.exists) {
        setState(() {
          predictedPlayers = List<Map<String, dynamic>>.from(snapshot['players']);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching predicted team: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<ScoreCard> fetchScoreCard(int matchId) async {
    final url = 'https://cricbuzz-cricket.p.rapidapi.com/mcenter/v1/$matchId/scard';
    final headers = {
      'X-RapidAPI-Key': '01fed8d85dmsh775f48123e4a9fbp1bb2e5jsn73b9525de68c',
      'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ScoreCard.fromJson(jsonData);
    } else {
      throw Exception('Failed to load scorecard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Predictions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<ScoreCard>(
              future: futureScoreCard,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final scoreCard = snapshot.data!;
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      for (var predictedPlayer in predictedPlayers)
                        _buildComparisonRow(predictedPlayer, scoreCard)
                    ],
                  );
                } else {
                  return Center(child: Text('No score data available.'));
                }
              },
            ),
    );
  }

  Widget _buildComparisonRow(Map<String, dynamic> predictedPlayer, ScoreCard scoreCard) {
    final playerName = predictedPlayer['PlayerName'];
    final predictedRuns = predictedPlayer['PredictedRuns'];

    // Find the live data for this player from the scoreCard
  final BatsmenDatum? livePlayer = scoreCard.innings
    .expand((innings) => innings.batTeamDetails.batsmenData.values)
    .cast<BatsmenDatum?>() // Ensures the data type is properly handled
    .firstWhere(
      (batsman) => batsman?.batName == playerName,
      orElse: () => null, // return null if not found
    );

final actualRuns = livePlayer?.runs ?? 0;
final isCorrect = predictedRuns == actualRuns;


// final actualRuns = livePlayer.runs;  // livePlayer will never be null here
// final isCorrect = predictedRuns == actualRuns;

    return ListTile(
      title: Text(playerName),
      subtitle: Text('Predicted: $predictedRuns, Actual: $actualRuns'),
      tileColor: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
    );
  }
}
