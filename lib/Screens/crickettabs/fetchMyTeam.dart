import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExistingTeamSelection extends StatefulWidget {
  final String matchId;
  final String poolType;
  final String team1Name;
  final String team2Name;

  ExistingTeamSelection({
    required this.matchId,
    required this.poolType,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  _ExistingTeamSelectionState createState() => _ExistingTeamSelectionState();
}

class _ExistingTeamSelectionState extends State<ExistingTeamSelection> {
  List<Map<String, dynamic>> existingTeams = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExistingTeams();
  }
Future<void> _fetchExistingTeams() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('selected_team')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        
        if (data != null && data.containsKey(widget.matchId)) {
          var matchData = data[widget.matchId];

          if (matchData != null && matchData is Map<String, dynamic> && matchData.containsKey('teams')) {
            Map<String, dynamic> teams = matchData['teams'];
            List<Map<String, dynamic>> fetchedTeams = [];
            
            teams.forEach((teamId, teamData) {
              try {
                List<Map<String, dynamic>> playersList = [];
                
                if (teamData is Map<String, dynamic> && teamData.containsKey('players')) {
                  var playersData = teamData['players'];
                  if (playersData is List) {
                    for (var player in playersData) {
                      if (player is Map<String, dynamic>) {
                        // Preserve null values for PredictedRuns and PredictedWickets
                        dynamic predictedRuns = player['PredictedRuns'];
                        dynamic predictedWickets = player['PredictedWickets'];

                        playersList.add({
                          'PlayerId': player['PlayerId'] ?? '',
                          'PlayerName': player['PlayerName'] ?? '',
                          'PredictedRuns': predictedRuns, // Keep as null if stored as null
                          'PredictedWickets': predictedWickets, // Keep as null if stored as null
                          'TeamName': player['TeamName'] ?? '',
                          'Priority': player['Priority'] ?? 0,
                        });
                      }
                    }
                  }
                }

                fetchedTeams.add({
                  'teamId': teamId,
                  'players': playersList,
                });
              } catch (e) {
                print('Error processing team $teamId: $e');
              }
            });

            setState(() {
              existingTeams = fetchedTeams;
              isLoading = false;
            });
            return;
          }
        }
      }

	      setState(() {
        errorMessage = 'No teams found';
        isLoading = false;
      });

    } catch (e) {
      print('Error fetching teams: $e');
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }


  String _getPoolDocName(String poolType) {
    switch (poolType.toLowerCase()) {
      case 'mega pool':
        return 'Pool';
      case 'large pool':
        return 'LargePool';
      case 'mini pool':
        return 'MiniPool';
      default:
        return 'Pool';
    }
  }

  int _getMaxSizeForPoolType(String poolType) {
    switch (poolType.toLowerCase()) {
      case 'mega pool':
        return 100;
      case 'large pool':
        return 50;
      case 'mini pool':
        return 25;
      default:
        return 100;
    }
  }

 Future<void> _joinPoolWithExistingTeam(Map<String, dynamic> team) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      String poolDoc = _getPoolDocName(widget.poolType);
      
      DocumentSnapshot poolSnapshot = await FirebaseFirestore.instance
          .collection('Pool')
          .doc(poolDoc)
          .get();

      if (!poolSnapshot.exists) {
        throw Exception('Pool document does not exist');
      }

      Map<String, dynamic> data = poolSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> matches = data['matches'] ?? {};
      Map<String, dynamic> matchData = matches[widget.matchId] ?? {};

      String? selectedPoolName;
      int? selectedPoolSlots;
      int maxSize = _getMaxSizeForPoolType(widget.poolType);

      matchData.forEach((poolName, poolData) {
        if (poolName != 'team1' && poolName != 'team2') {
          int currentSlots = poolData['slots'] ?? 0;
          if (currentSlots < maxSize && selectedPoolName == null) {
            selectedPoolName = poolName;
            selectedPoolSlots = currentSlots;
          }
        }
      });

      if (selectedPoolName == null) {
        int newIndex = matchData.keys.where((k) => k.startsWith(widget.poolType)).length + 1;
        selectedPoolName = '${widget.poolType} $newIndex';
        selectedPoolSlots = 0;
      }

      // Prepare player data while preserving null values
      List<Map<String, dynamic>> playersList = [];
      if (team.containsKey('players') && team['players'] is List) {
        List<dynamic> players = team['players'];
        for (var player in players) {
          if (player is Map<String, dynamic>) {
            Map<String, dynamic> playerData = {
              'PlayerId': player['PlayerId'] ?? '',
              'PlayerName': player['PlayerName'] ?? '',
              'TeamName': player['TeamName'] ?? '',
              'Priority': player['Priority'] ?? 0,
            };

            // Only add PredictedRuns and PredictedWickets if they're not null
            if (player['PredictedRuns'] != null) {
              playerData['PredictedRuns'] = player['PredictedRuns'];
            }
            if (player['PredictedWickets'] != null) {
              playerData['PredictedWickets'] = player['PredictedWickets'];
            }

            playersList.add(playerData);
          }
        }
      }

      // Sort players by priority
      playersList.sort((a, b) => (b['Priority'] ?? 0).compareTo(a['Priority'] ?? 0));

      String newTeamId = '${team['teamId']}_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> teamSelection = {
        'teamId': newTeamId,
        'players': playersList,
        'team1': widget.team1Name,
        'team2': widget.team2Name,
      };

      DocumentSnapshot userPoolSnapshot = await FirebaseFirestore.instance
          .collection('Pool')
          .doc(poolDoc)
          .get();

      List<dynamic> currentTeams = [];
      if (userPoolSnapshot.exists) {
        var userData = userPoolSnapshot.data() as Map<String, dynamic>;
        var matchesData = userData['matches'] ?? {};
        var matchSpecificData = matchesData[widget.matchId] ?? {};
        var poolData = matchSpecificData[selectedPoolName] ?? {};
        var userJoins = poolData['userJoins'] ?? {};
        var userSpecificData = userJoins[user.uid] ?? {};
        currentTeams = userSpecificData['teams'] ?? [];
      }

      currentTeams = [...currentTeams, teamSelection];

      await FirebaseFirestore.instance.collection('Pool').doc(poolDoc).set({
        'matches': {
          widget.matchId: {
            selectedPoolName: {
              'slots': FieldValue.increment(1),
              'userJoins': {
                user.uid: {
                  'joinCount': FieldValue.increment(1),
                  'teams': currentTeams
                }
              }
            }
          }
        }
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added team to pool!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      print('Error joining pool with team: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining the pool. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.team1Name} vs ${widget.team2Name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchExistingTeams,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(errorMessage!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchExistingTeams,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : existingTeams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_cricket, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No teams found', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: existingTeams.length,
                      itemBuilder: (context, index) {
                        var team = existingTeams[index];
                        List<dynamic> players = team['players'] ?? [];
                        
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            title: Text('Team ${index + 1}'),
                            subtitle: Text('${players.length} Players'),
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: players.length,
                                itemBuilder: (context, playerIndex) {
                                  var player = players[playerIndex];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${player['Priority']}'),
                                    ),
                                    title: Text(player['PlayerName'] ?? ''),
                                    subtitle: Text(
                                      'Runs: ${player['PredictedRuns'] ?? 'N/A'}, ' +
                                      'Wickets: ${player['PredictedWickets'] ?? 'N/A'}',
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: ElevatedButton(
                                  onPressed: () => _joinPoolWithExistingTeam(team),
                                  child: Text('Select This Team'),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Color(0xFFFFE5C4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}