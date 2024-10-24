import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class PoolSelectionPage extends StatefulWidget {
  final String matchId;
  final int teamId1;
  final int teamId2;
  final List<Map<String, dynamic>> pools;
  final Map<String, dynamic> preSelectedPlayers;

  PoolSelectionPage({
    required this.matchId,
    required this.teamId1,
    required this.teamId2,
    required this.pools,
    required this.preSelectedPlayers,
  });

  @override
  _PoolSelectionPageState createState() => _PoolSelectionPageState();
}

class _PoolSelectionPageState extends State<PoolSelectionPage> {
  Map<String, String> predictedRuns = {};
  Map<String, int> predictedWickets = {};
  Map<String, int?> priorities = {};
  Map<String, String> playerRoles = {};
  int currentPriority = 12;

  @override
  void initState() {
    super.initState();
    widget.preSelectedPlayers.forEach((key, value) {
      if (key != 'poolName' && key != 'joinedSlots' && key != 'totalSlots') {
        String role = value.split(' - ')[1].split('(')[0].trim().toLowerCase();
        playerRoles[key] = role;

        // Only set predictions based on specific roles
        if (role.contains('batsman')) {
          predictedRuns[key] = '0-10';
          predictedWickets.remove(key); // Ensure wickets is null for batsmen
        } else if (role.contains('bowler')) {
          predictedWickets[key] = 1;
          predictedRuns.remove(key); // Ensure runs is null for bowlers
        } else if (role.contains('allrounder')) {
          predictedRuns[key] = '0-10';
          predictedWickets[key] = 1;
        }
        priorities[key] = null;
      }
    });
  }


  void togglePriority(String playerId) {
    setState(() {
      if (priorities[playerId] == null && currentPriority > 0) {
        priorities[playerId] = currentPriority;
        currentPriority--;
      } else if (priorities[playerId] != null) {
        int uncheckingPriority = priorities[playerId]!;
        priorities.forEach((key, value) {
          if (value != null && value <= uncheckingPriority) {
            priorities[key] = null;
            currentPriority++;
          }
        });
      }
    });
  }

  bool allPrioritiesAssigned() {
    return priorities.values.every((priority) => priority != null);
  }

  Future<void> storeSelectedTeam(Map<String, dynamic> detailedPlayers) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      String teamId = const Uuid().v4(); // Add Uuid import at the top of the file

      // Convert detailedPlayers to the structured format
      List<Map<String, dynamic>> sortedPlayers = [];
      detailedPlayers.forEach((playerId, playerData) {
        sortedPlayers.add({
          'PlayerId': playerId,
          'PlayerName': playerData['PlayerName'],
          'PredictedRuns': playerData['PredictedRuns'],
          'PredictedWickets': playerData['PredictedWickets'],
          'TeamName': playerData['TeamName'],
          'Priority': playerData['Priority'],
        });
      });

      // Sort players by priority
      sortedPlayers.sort((a, b) => b['Priority'].compareTo(a['Priority']));

      Map<String, dynamic> teamSelection = {
        'teamId': teamId,
        'players': sortedPlayers
      };

      // Get the current document
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('selected_team')
          .doc(userId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> matchData = data[widget.matchId] as Map<String, dynamic>? ?? {};
        Map<String, dynamic> teams = matchData['teams'] as Map<String, dynamic>? ?? {};

        // Check if the number of teams is less than 6
        if (teams.length < 6) {
          await FirebaseFirestore.instance
              .collection('selected_team')
              .doc(userId)
              .set({
            widget.matchId: {
              'teams': {
                ...teams,
                teamId: teamSelection,
              },
            }
          }, SetOptions(merge: true));

          print('Selected team stored successfully for user $userId');
        } else {
          print('Maximum limit of 6 teams reached in storage. Oldest team will be replaced.');
          // Remove the oldest team and add the new one
          var oldestTeamId = teams.keys.first;
          teams.remove(oldestTeamId);
          teams[teamId] = teamSelection;

          await FirebaseFirestore.instance
              .collection('selected_team')
              .doc(userId)
              .set({
            widget.matchId: {
              'teams': teams,
            }
          }, SetOptions(merge: true));

          print('New team stored, replacing the oldest one for user $userId');
        }
      } else {
        // If the document doesn't exist, create it with the first team
        await FirebaseFirestore.instance
            .collection('selected_team')
            .doc(userId)
            .set({
          widget.matchId: {
            'teams': {
              teamId: teamSelection,
            },
          }
        });

        print('First team stored successfully for user $userId');
      }
    } else {
      print('No user currently signed in');
    }
  } catch (e) {
    print('Error storing selected team: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Selection'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ...widget.preSelectedPlayers.entries.map((entry) {
            if (entry.key != 'poolName' && entry.key != 'joinedSlots' && entry.key != 'totalSlots') {
              String roleAndTeam = entry.value.split(' - ')[1];
              String role = roleAndTeam.split('(')[0].trim().toLowerCase();
              String teamName = roleAndTeam.split('(')[1].replaceAll(')', '').trim();

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.split(' - ')[0],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Player ID: ${entry.key}, Role: $role, Team: $teamName',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                         Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (role.contains('batsman') || role.contains('allrounder'))
                                SizedBox(
                                  width: 90,
                                  child: DropdownButtonFormField<String>(
                                    value: predictedRuns[entry.key],
                                    items: [
                                      for (int i = 0; i < 100; i += 10)
                                        DropdownMenuItem(value: '$i-${i+10}', child: Text('$i-${i+10}'))
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        predictedRuns[entry.key] = value!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Runs',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      border: OutlineInputBorder(),
                                    ),
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              if (role.contains('bowler') || role.contains('allrounder'))
                                SizedBox(
                                  width: 70,
                                  child: DropdownButtonFormField<int>(
                                    value: predictedWickets[entry.key],
                                    items: [for (int i = 1; i <= 10; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                                    onChanged: (value) {
                                      setState(() {
                                        predictedWickets[entry.key] = value!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Wickets',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      border: OutlineInputBorder(),
                                    ),
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                ),
                            ],
                                ),
                            
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox(
                                value: priorities[entry.key] != null,
                                onChanged: (value) {
                                  togglePriority(entry.key);
                                },
                                activeColor: Colors.green,
                              ),
                              if (priorities[entry.key] != null)
                                Text(
                                  'Priority: ${priorities[entry.key]}',
                                  style: TextStyle(fontSize: 14, color: Colors.blue),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }).toList(),

        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              child: Text('Confirm Selection'),
              onPressed: allPrioritiesAssigned()
                  ? () async {
                      Map<String, dynamic> detailedPlayers = {};
                      widget.preSelectedPlayers.forEach((key, value) {
                        if (key != 'poolName' && key != 'joinedSlots' && key != 'totalSlots') {
                          String playerName = value.split(' - ')[0];
                          String roleAndTeam = value.split(' - ')[1];
                          String role = roleAndTeam.split('(')[0].trim().toLowerCase();
                          String teamName = roleAndTeam.split('(')[1].replaceAll(')', '').trim();

                          Map<String, dynamic> playerData = {
                            'PlayerName': playerName,
                            'TeamName': teamName,
                            'Priority': priorities[key],
                          };

                          // Set predictions based on role
                          if (role.contains('batsman')) {
                            playerData['PredictedRuns'] = predictedRuns[key] ?? '0-10';
                            playerData['PredictedWickets'] = null;  // Explicitly set to null for batsmen
                          } else if (role.contains('bowler')) {
                            playerData['PredictedRuns'] = null;  // Explicitly set to null for bowlers
                            playerData['PredictedWickets'] = predictedWickets[key] ?? 0;
                          } else if (role.contains('allrounder')) {
                            playerData['PredictedRuns'] = predictedRuns[key] ?? '0-10';
                            playerData['PredictedWickets'] = predictedWickets[key] ?? 0;
                          }

                          detailedPlayers[key] = playerData;
                        }
                      });

                      await storeSelectedTeam(detailedPlayers);

                      Navigator.of(context).pop({
                        'poolName': widget.preSelectedPlayers['poolName'],
                        'joinedSlots': widget.preSelectedPlayers['joinedSlots'],
                        'totalSlots': widget.preSelectedPlayers['totalSlots'],
                        'players': detailedPlayers,
                      });
                    }
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => allPrioritiesAssigned() ? const Color.fromARGB(255, 2, 38, 67) : Colors.grey,
                ),
              ),
            ),
        ),
        ],
      ),
    );
  }
}