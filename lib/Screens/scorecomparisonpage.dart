import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_page/Models/CricketModel.dart';
import 'package:login_page/Screens/LeaderboardPage.dart';

class ScoreComparisonPage extends StatefulWidget {
  final int matchId;
  final String poolType;
  final String poolName;
  final String teamId; 

  ScoreComparisonPage({
    required this.matchId,
    required this.poolType,
    required this.poolName,
    required this.teamId, 
  });

  @override
  _ScoreComparisonPageState createState() => _ScoreComparisonPageState();
}

class _ScoreComparisonPageState extends State<ScoreComparisonPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late Future<Map<String, dynamic>> _futureData;
  int _totalScore = 0;
  bool _isMatchCompleted = false;
  bool _scoreUpdated = false;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }
  

 Future<Map<String, dynamic>> _loadData() async {
    final scoreCard = await fetchScoreCard(widget.matchId);
    final selectedTeam = await fetchSelectedTeam();
    return {
      'scoreCard': scoreCard,
      'selectedTeam': selectedTeam,
    };
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

 Future<Map<String, dynamic>> fetchSelectedTeam() async {
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

    List<dynamic> teams = poolData['userJoins'][userId]['teams'] ?? [];
    Map<String, dynamic>? selectedTeam = teams.firstWhere(
      (team) => team['teamId'] == widget.teamId,
      orElse: () => null,
    );

    if (selectedTeam == null) {
      throw Exception('Selected team not found');
    }

    // Ensure that each player in the selected team has a priority
    selectedTeam['players'] = (selectedTeam['players'] as List<dynamic>).map((player) {
      if (player['priority'] == null) {
        // If priority is missing, you might want to set a default value or fetch it from another source
        player['priority'] = 0; // or any other appropriate default value
      }
      return player;
    }).toList();

    return selectedTeam;
  } catch (e) {
    print('Error fetching selected team: $e');
    rethrow;
  }
}
void _calculateAndUpdateScore(ScoreCard scoreCard, List<dynamic> players) {
  _isMatchCompleted = scoreCard.matchHeader.state.toLowerCase() == 'complete';
  if (_isMatchCompleted && !_scoreUpdated) {
    _calculateTotalScore(players, scoreCard);
    updateFirebaseScore(_totalScore, players, scoreCard);
  }
}

  void _calculateTotalScore(List<dynamic> players, ScoreCard scoreCard) {
    _totalScore = 0;
    for (var player in players) {
      var actualBatsman = _findActualBatsman(player, scoreCard);
      var actualBowler = _findActualBowler(player, scoreCard);
      _totalScore += _calculateScore(player, actualBatsman, actualBowler) ?? 0;
    }
  }


 Future<void> updateFirebaseScore(int totalScore, List<dynamic> players, ScoreCard scoreCard) async {
    if (_scoreUpdated) return; // Prevent multiple updates

    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user is currently signed in');
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference poolRef = _firestore
            .collection('Pool')
            .doc(widget.poolType);

        DocumentSnapshot poolSnapshot = await transaction.get(poolRef);

        if (!poolSnapshot.exists) {
          throw Exception('Pool document does not exist');
        }

        Map<String, dynamic> poolData = poolSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> matchData = poolData['matches'][widget.matchId.toString()];
        Map<String, dynamic> userJoinData = matchData[widget.poolName]['userJoins'][userId];

        List<dynamic> teams = List.from(userJoinData['teams']);
        
        int teamIndex = teams.indexWhere((team) => team['teamId'] == widget.teamId);

        if (teamIndex == -1) {
          throw Exception('Team not found for this match (teamId: ${widget.teamId})');
        }

        // Prepare the updated team data
        Map<String, dynamic> updatedTeamData = {
          ...teams[teamIndex], // Spread the existing team data
          'totalScore': totalScore,
          'scoreCard': {
            'matchId': widget.matchId,
            'matchState': scoreCard.matchHeader.state,
            // 'team1': scoreCard.matchHeader.team1.name,
            // 'team2': scoreCard.matchHeader.team2.name,
            'result': scoreCard.matchHeader.status,
          },
          'selectedPlayers': players.map((player) => {
            'PlayerId': player['PlayerId'],
            'PlayerName': player['PlayerName'],
            'TeamName': player['TeamName'],
            'PredictedRuns': player['PredictedRuns'],
            'PredictedWickets': player['PredictedWickets'],
            'Priority': player['Priority'],
            'actualScore': _calculateScore(player, 
              _findActualBatsman(player, scoreCard), 
              _findActualBowler(player, scoreCard)),
          }).toList(),
        };

        // Update the specific team in the array
        teams[teamIndex] = updatedTeamData;

        // Update the entire teams array
        transaction.update(poolRef, {
          'matches.${widget.matchId}.${widget.poolName}.userJoins.$userId.teams': teams,
        });
      });

      setState(() {
        _scoreUpdated = true;
      });

      print('Score and player data updated in Firebase for team (teamId: ${widget.teamId}): $totalScore');
    } catch (e) {
      print('Error updating score in Firebase: $e');
      print('Error details: ${e.toString()}');
    }
  }

  String _getMatchState(String state) {
    switch (state.toLowerCase()) {
      case 'preview':
        return 'Preview';
      case 'complete':
        return 'Complete';
      default:
        return 'In Progress';
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'preview':
        return Colors.blue;
      case 'complete':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  // void _calculateAndUpdateScore(ScoreCard scoreCard, List<Map<String, dynamic>> selectedPlayers) {
  //   setState(() {
  //     _isMatchCompleted = scoreCard.matchHeader.state.toLowerCase() == 'complete';
  //     if (_isMatchCompleted && !_scoreUpdated) {
  //       _calculateTotalScore(selectedPlayers, scoreCard);
  //       updateFirebaseScore(_totalScore);
  //     }
  //   });
  // }

    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Comparison'),
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardPage(
                    matchId: widget.matchId,
                    poolType: widget.poolType,
                    poolName: widget.poolName,
                  ),
                ),
              );
            },
            tooltip: 'View Leaderboard',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final scoreCard = snapshot.data!['scoreCard'] as ScoreCard;
            final selectedTeam = snapshot.data!['selectedTeam'] as Map<String, dynamic>;
            _calculateAndUpdateScore(scoreCard, selectedTeam['players']);
            return _buildComparison(scoreCard, selectedTeam);
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  // void _calculateTotalScore(List<Map<String, dynamic>> selectedPlayers, ScoreCard scoreCard) {
  //   _totalScore = 0;
  //   for (var player in selectedPlayers) {
  //     var actualBatsman = _findActualBatsman(player, scoreCard);
  //     var actualBowler = _findActualBowler(player, scoreCard);
  //     _totalScore += _calculateScore(player, actualBatsman, actualBowler);
  //   }
  // }
  

 BatsmenDatum _findActualBatsman(Map<String, dynamic> player, ScoreCard scoreCard) {
  String playerId = player['PlayerId']?.toString() ?? 'N/A';
  return scoreCard.innings.expand((innings) => innings.batTeamDetails.batsmenData.values)
      .firstWhere(
        (batsman) => batsman.batId.toString() == playerId,
        orElse: () => BatsmenDatum(
          batId: 0,
          batName: player['PlayerName'] ?? 'Unknown',
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
}

BowlerDatum _findActualBowler(Map<String, dynamic> player, ScoreCard scoreCard) {
  String playerId = player['PlayerId']?.toString() ?? 'N/A';
  return scoreCard.innings.expand((innings) => innings.bowlTeamDetails.bowlersData.values)
      .firstWhere(
        (bowler) => bowler.bowlerId.toString() == playerId,
        orElse: () => BowlerDatum(
          bowlerId: 0,
          bowlName: player['PlayerName'] ?? 'Unknown',
          overs: 0,
          maidens: 0,
          runs: 0,
          wickets: 0,
          economy: 0.0,
          isCaptain: false,
          isKeeper: false,
        ),
      );
}

  Widget _buildComparison(ScoreCard scoreCard, Map<String, dynamic> selectedTeam) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text('Match ID: ${widget.matchId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Team ID: ${widget.teamId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Match Start: ${_formatTimestamp(scoreCard.matchHeader.matchStartTimestamp)}', 
             style: TextStyle(fontSize: 16)),
        Text('Match Complete: ${_formatTimestamp(scoreCard.matchHeader.matchCompleteTimestamp)}', 
             style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text('Match State: ${_getMatchState(scoreCard.matchHeader.state)}', 
             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getStateColor(scoreCard.matchHeader.state))),
        SizedBox(height: 16),
        Text('Player Comparisons:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...(selectedTeam['players'] as List<dynamic>).map((player) => _buildPlayerCard(player, scoreCard)),
        SizedBox(height: 16),
        _buildTotalScoreCard(scoreCard),
      ],
    );
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return 'N/A';
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Widget _buildTotalScoreCard(ScoreCard scoreCard) {
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
            offset: Offset(2, 4),
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
                  _isMatchCompleted ? '$_totalScore' : 'Pending',
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

  Widget _buildPlayerCard(dynamic player, ScoreCard scoreCard) {
  String playerName = player['PlayerName'] ?? 'Unknown';
  String teamName = player['TeamName'] ?? 'Unknown';
  String playerId = player['PlayerId']?.toString() ?? 'N/A';
  int priority = player['Priority'] ?? 0;
  
  var actualBatsman = _findActualBatsman(player, scoreCard);
  var actualBowler = _findActualBowler(player, scoreCard);

  String role = _determineRole(actualBatsman, actualBowler);

  int? calculatedScore = _calculateScore(player, actualBatsman, actualBowler);

  return Card(
    margin: EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(playerName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Team: $teamName', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text('ID: $playerId', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Role: $role', style: TextStyle(fontSize: 14, color: Colors.blue)),
              Text('Priority: $priority', style: TextStyle(fontSize: 14, color: Colors.orange)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Runs', player['PredictedRuns']?.toString() ?? 'N/A', actualBatsman.runs.toString()),
              _buildStatColumn('Wickets', player['PredictedWickets']?.toString() ?? 'N/A', actualBowler.wickets.toString()),
            ],
          ),
          SizedBox(height: 12),
          Text('Calculated Score: ${_isMatchCompleted ? calculatedScore : "Pending"}', 
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Text('Runs Match: ${_isRunsMatch(player, actualBatsman.runs)}', style: TextStyle(fontSize: 14)),
          Text('Wickets Match: ${_isWicketsMatch(player, actualBowler.wickets)}', style: TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );
}

String _determineRole(BatsmenDatum batsman, BowlerDatum bowler) {
    List<String> roles = [];
    
    if (batsman.isCaptain || bowler.isCaptain) {
      roles.add('Captain');
    }
    if (batsman.isKeeper || bowler.isKeeper) {
      roles.add('Wicket-keeper');
    }
    
    // Check if the player is a batsman
    if (batsman.runs > 0 || batsman.balls > 0) {
      roles.add('Batsman');
    }
    
    // Check if the player is a bowler
    if (bowler.overs > 0 || bowler.wickets > 0) {
      roles.add('Bowler');
    }
    
    // If no specific role is detected, mark as All-rounder or Unknown
    if (roles.isEmpty) {
      return 'All-rounder';
    } else if (roles.length == 1 && (roles[0] == 'Captain' || roles[0] == 'Wicket-keeper')) {
      roles.add('Unknown');
    }
    
    return roles.join(' & ');
  }



bool _isRunsMatch(dynamic player, int actualRuns) {
  String predictedRunsRange = player['PredictedRuns']?.toString() ?? '0-0';
  List<String> runsParts = predictedRunsRange.split('-');
  int predictedRunsLow = int.tryParse(runsParts[0]) ?? 0;
  int predictedRunsHigh = int.tryParse(runsParts.length > 1 ? runsParts[1] : runsParts[0]) ?? 0;
  return actualRuns >= predictedRunsLow && actualRuns <= predictedRunsHigh;
}

bool _isWicketsMatch(dynamic player, int actualWickets) {
  int predictedWickets = int.tryParse(player['PredictedWickets']?.toString() ?? '0') ?? 0;
  return actualWickets == predictedWickets;
}


 int? _calculateScore(Map<String, dynamic> player, BatsmenDatum actualBatsman, BowlerDatum actualBowler) {
  int priority = player['Priority'] ?? 0;
  String? predictedRunsRange = player['PredictedRuns']?.toString();
  String? predictedWicketsRange = player['PredictedWickets']?.toString();
  int actualRuns = actualBatsman.runs;
  int actualWickets = actualBowler.wickets;

  bool runsMatch = false;
  bool wicketsMatch = false;

  // Check if both predicted runs and wickets are null
  if (predictedRunsRange == null && predictedWicketsRange == null) {
    return null;
  }

  // Handle predicted runs
  if (predictedRunsRange != null && predictedRunsRange.toLowerCase() != 'n/a') {
    List<String> runsParts = predictedRunsRange.split('-');
    int predictedRunsLower = int.tryParse(runsParts[0]) ?? 0;
    int predictedRunsUpper = int.tryParse(runsParts.length > 1 ? runsParts[1] : runsParts[0]) ?? 0;
    runsMatch = actualRuns >= predictedRunsLower && actualRuns <= predictedRunsUpper;
  }

  // Handle predicted wickets
  if (predictedWicketsRange != null && predictedWicketsRange.toLowerCase() != 'n/a') {
    List<String> wicketsParts = predictedWicketsRange.split('-');
    int predictedWicketsLower = int.tryParse(wicketsParts[0]) ?? 0;
    int predictedWicketsUpper = int.tryParse(wicketsParts.length > 1 ? wicketsParts[1] : wicketsParts[0]) ?? 0;
    wicketsMatch = actualWickets >= predictedWicketsLower && actualWickets <= predictedWicketsUpper;
  }

  // Debug logging
  print('Player: ${player['PlayerName']}, Priority: $priority');
  print('Predicted Runs: $predictedRunsRange, Actual: $actualRuns');
  print('Predicted Wickets: $predictedWicketsRange, Actual: $actualWickets');
  print('Runs Match: $runsMatch, Wickets Match: $wicketsMatch');

  // Score calculation logic
  if (predictedRunsRange == null || predictedRunsRange.toLowerCase() == 'n/a') {
    // Only compare wickets
    return wicketsMatch ? priority : 0;
  } else if (predictedWicketsRange == null || predictedWicketsRange.toLowerCase() == 'n/a') {
    // Only compare runs
    return runsMatch ? priority : 0;
  } else {
    // Compare both runs and wickets
    return (runsMatch && wicketsMatch) ? priority : 0;
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