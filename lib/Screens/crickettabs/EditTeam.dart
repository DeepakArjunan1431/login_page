import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// First, let's add the TeamDetails and PlayerDetails classes that we need
class TeamDetails {
  final int id;
  final int teamId;
  final String name;
  final String shortName;
  final List<PlayerDetails> playerDetails;

  TeamDetails({
    required this.id,
    required this.teamId,
    required this.name,
    required this.shortName,
    required this.playerDetails,
  });
}

class PlayerDetails {
  final int id;
  final String fullName;
  final String nickName;
  final bool captain;
  final bool keeper;
  final bool substitute;
  final String role;

  PlayerDetails({
    required this.id,
    required this.fullName,
    required this.nickName,
    required this.captain,
    required this.keeper,
    required this.substitute,
    required this.role,
  });
}

class PlayerReplacementDialog extends StatefulWidget {
  final String matchId;
  final String teamId;
  final Map<String, dynamic> currentPlayer;
  final List<dynamic> selectedPlayers;

  PlayerReplacementDialog({
    required this.matchId,
    required this.teamId,
    required this.currentPlayer,
    required this.selectedPlayers,
  });

  @override
  _PlayerReplacementDialogState createState() => _PlayerReplacementDialogState();
}

class _PlayerReplacementDialogState extends State<PlayerReplacementDialog> {
  late Future<List<TeamDetails>> futureTeamDetails;
  Set<int> alreadySelectedPlayerIds = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    futureTeamDetails = fetchPlayerInfo(widget.matchId);
    // Initialize already selected players
    for (var player in widget.selectedPlayers) {
      if (player['PlayerId'] != widget.currentPlayer['PlayerId']) {
        alreadySelectedPlayerIds.add(int.parse(player['PlayerId'].toString()));
      }
    }
  }

  Future<List<TeamDetails>> fetchPlayerInfo(String matchId) async {
    final String apiUrl = 'https://cricbuzz-cricket.p.rapidapi.com/mcenter/v1/$matchId';
    final String apiKey = '01fed8d85dmsh775f48123e4a9fbp1bb2e5jsn73b9525de68c';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final matchInfo = jsonData['matchInfo'];
        if (matchInfo == null) {
          throw Exception('No matchInfo found in JSON response');
        }

        List<TeamDetails> teams = [];

        for (var teamData in [matchInfo['team1'], matchInfo['team2']]) {
          List<PlayerDetails> playerDetails = (teamData['playerDetails'] as List).map((player) =>
            PlayerDetails(
              id: player['id'],
              fullName: player['fullName'],
              nickName: player['nickName'] ?? '',
              captain: player['captain'] ?? false,
              keeper: player['keeper'] ?? false,
              substitute: player['substitute'] ?? false,
              role: player['role'] ?? 'Unknown',
            )
          ).toList();

          teams.add(TeamDetails(
            id: teamData['id'],
            teamId: teamData['id'],
            name: teamData['name'],
            shortName: teamData['shortName'],
            playerDetails: playerDetails,
          ));
        }

        return teams;
      } else {
        throw Exception('Failed to load team info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load team info: $e');
    }
  }

 Future<void> _replacePlayer(PlayerDetails newPlayer, String teamName) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Determine the role of the current and new player
    String currentPlayerRole = widget.currentPlayer['Role'] ?? '';
    String newPlayerRole = newPlayer.role.toLowerCase();

    // Prepare the new player entry
    Map<String, dynamic> newPlayerEntry = {
      'PlayerId': newPlayer.id.toString(),
      'PlayerName': newPlayer.fullName,
      'TeamName': teamName,
      'Role': newPlayer.role,
      'Priority': widget.currentPlayer['Priority'],
    };

    // Set predictions based on the player's role
    if (newPlayerRole.contains('batsman')) {
      // For batsmen, predict runs, set wickets to null
      newPlayerEntry['PredictedRuns'] = '0-10';
      newPlayerEntry['PredictedWickets'] = null;
    } else if (newPlayerRole.contains('bowler')) {
      // For bowlers, predict wickets, set runs to null
      newPlayerEntry['PredictedRuns'] = null;
      newPlayerEntry['PredictedWickets'] = 1;
    } else if (newPlayerRole.contains('allrounder')) {
      // For all-rounders, predict both runs and wickets
      newPlayerEntry['PredictedRuns'] = '0-10';
      newPlayerEntry['PredictedWickets'] = 1;
    }

    // Get the current document
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('selected_team')
        .doc(user.uid)
        .get();

    if (!doc.exists) throw Exception('No teams found');

    // Get the current data structure
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Update the players list
    if (data.containsKey(widget.matchId)) {
      Map<String, dynamic> matchData = data[widget.matchId] as Map<String, dynamic>;
      if (matchData.containsKey('teams')) {
        Map<String, dynamic> teams = matchData['teams'] as Map<String, dynamic>;
        if (teams.containsKey(widget.teamId)) {
          List<dynamic> players = (teams[widget.teamId]['players'] as List<dynamic>)
              .map((player) => Map<String, dynamic>.from(player))
              .toList();

          // Find and replace the player
          int playerIndex = players.indexWhere(
            (p) => p['PlayerId'].toString() == widget.currentPlayer['PlayerId'].toString()
          );

          if (playerIndex != -1) {
            players[playerIndex] = newPlayerEntry;

            // Update Firestore with the complete path
            await FirebaseFirestore.instance
                .collection('selected_team')
                .doc(user.uid)
                .set({
              widget.matchId: {
                'teams': {
                  widget.teamId: {
                    'players': players
                  }
                }
              }
            }, SetOptions(merge: true));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Player replaced successfully'))
            );
            
            Navigator.pop(context, true);
            return;
          }
        }
      }
    }

    throw Exception('Could not find the correct data structure to update');

  } catch (e) {
    print('Error replacing player: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error replacing player: ${e.toString()}'),
        backgroundColor: Colors.red,
      )
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Replace ${widget.currentPlayer['PlayerName']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Current Player Stats:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Card(
              child: ListTile(
                title: Text(widget.currentPlayer['PlayerName']),
                subtitle: Text(
                  'Runs: ${widget.currentPlayer['PredictedRuns'] ?? 'N/A'}, '
                  'Wickets: ${widget.currentPlayer['PredictedWickets'] ?? 'N/A'}'
                ),
                leading: CircleAvatar(
                  child: Text('${widget.currentPlayer['Priority']}'),
                ),
              ),
            ),
            Divider(),
            Text(
              'Select New Player:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: FutureBuilder<List<TeamDetails>>(
                future: futureTeamDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No players available'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, teamIndex) {
                      TeamDetails team = snapshot.data![teamIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              team.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...team.playerDetails.map((player) {
                            bool isAlreadySelected = alreadySelectedPlayerIds.contains(player.id);
                            bool isCurrentPlayer = player.id.toString() == widget.currentPlayer['PlayerId'];

                            return Card(
                              color: isAlreadySelected ? Colors.grey[300] : null,
                              child: ListTile(
                                enabled: !isAlreadySelected || isCurrentPlayer,
                                leading: CircleAvatar(
                                  child: Icon(
                                    player.captain ? Icons.star :
                                    player.keeper ? Icons.sports_cricket :
                                    Icons.person
                                  ),
                                ),
                                title: Text(
                                  player.fullName,
                                  style: TextStyle(
                                    color: isAlreadySelected ? Colors.grey : null,
                                  ),
                                ),
                                subtitle: Text(
                                  '${player.role} ${player.captain ? "• Captain" : ""} ${player.keeper ? "• Keeper" : ""}',
                                  style: TextStyle(
                                    color: isAlreadySelected ? Colors.grey : null,
                                  ),
                                ),
                                trailing: isAlreadySelected ? 
                                  Icon(Icons.check_circle, color: Colors.grey) : null,
                                onTap: isAlreadySelected ? null : () async {
                                  bool? confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Player Replacement'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Replace:'),
                                          Text(
                                            widget.currentPlayer['PlayerName'],
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text('With:'),
                                          Text(
                                            player.fullName,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await _replacePlayer(player, team.name);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
class EditTeamDialog extends StatefulWidget {
  final String matchId;
  final String teamId;
  final List<dynamic> players;

  EditTeamDialog({
    required this.matchId,
    required this.teamId,
    required this.players,
  });

  @override
  _EditTeamDialogState createState() => _EditTeamDialogState();
}

class _EditTeamDialogState extends State<EditTeamDialog> {
  late List<Map<String, dynamic>> editablePlayers;
  Map<String, String?> selectedRuns = {};
  Map<String, String?> selectedWickets = {};
  bool isSaving = false;

  final List<String> runsRanges = [
    '0-10', '10-20', '20-30', '30-40', '40-50',
    '50-60', '60-70', '70-80', '80-90', '90-100'
  ];
  
  final List<String> wicketsRanges = List.generate(10, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    editablePlayers = List<Map<String, dynamic>>.from(widget.players);
    
    // Initialize selected values for each player
    for (var player in editablePlayers) {
      String playerId = player['PlayerId'].toString();
      
      var runs = player['PredictedRuns'];
      if (runs != null) {
        if (runs is double) {
          int rangeIndex = (runs ~/ 10).clamp(0, 9);
          selectedRuns[playerId] = runsRanges[rangeIndex];
        } else {
          selectedRuns[playerId] = runs.toString();
        }
      }
      
      var wickets = player['PredictedWickets'];
      if (wickets != null) {
        if (wickets is double) {
          selectedWickets[playerId] = wickets.round().toString();
        } else {
          selectedWickets[playerId] = wickets.toString();
        }
      }
    }
  }

  Future<void> _updatePlayerInFirestore(
    String playerId,
    String? runs,
    String? wickets,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      DocumentReference teamRef = FirebaseFirestore.instance
          .collection('selected_team')
          .doc(user.uid);

      DocumentSnapshot teamDoc = await teamRef.get();
      if (!teamDoc.exists) throw Exception('Team not found');

      Map<String, dynamic> data = teamDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> matchData = data[widget.matchId] as Map<String, dynamic>;
      Map<String, dynamic> teams = matchData['teams'] as Map<String, dynamic>;
      List<dynamic> players = teams[widget.teamId]['players'] as List<dynamic>;

      int playerIndex = players.indexWhere((p) => p['PlayerId'].toString() == playerId);
      if (playerIndex != -1) {
        players[playerIndex]['PredictedRuns'] = runs;
        players[playerIndex]['PredictedWickets'] = wickets;
      }

      await teamRef.update({
        '${widget.matchId}.teams.${widget.teamId}.players': players,
      });

    } catch (e) {
      throw Exception('Failed to update player: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!isSaving) {
          return true; // Allow back button to close dialog
        }
        return false; // Prevent closing while saving
      },
      child: Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Edit Team',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: editablePlayers.length,
                  itemBuilder: (context, index) {
                    final player = editablePlayers[index];
                    final playerId = player['PlayerId'].toString();
                    
                    final runsWasNull = widget.players[index]['PredictedRuns'] == null;
                    final wicketsWasNull = widget.players[index]['PredictedWickets'] == null;

                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Text(
                                  player['PlayerName'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.swap_horiz),
                              onPressed: isSaving ? null : () async {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => PlayerReplacementDialog(
                                    matchId: widget.matchId,
                                    teamId: widget.teamId,
                                    currentPlayer: player,
                                    selectedPlayers: editablePlayers,
                                  ),
                                );
                                if (result == true) {
                                  Navigator.pop(context, true);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedRuns[playerId],
                                    decoration: InputDecoration(
                                      labelText: 'Predicted Runs Range',
                                      border: OutlineInputBorder(),
                                      enabled: !runsWasNull && !isSaving,
                                      helperText: runsWasNull ? 'Not editable' : null,
                                    ),
                                    items: runsRanges.map((String range) {
                                      return DropdownMenuItem<String>(
                                        value: range,
                                        child: Text(range),
                                      );
                                    }).toList(),
                                    onChanged: (runsWasNull || isSaving) ? null : (String? newValue) {
                                      setState(() {
                                        selectedRuns[playerId] = newValue;
                                        player['PredictedRuns'] = newValue;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedWickets[playerId],
                                    decoration: InputDecoration(
                                      labelText: 'Predicted Wickets',
                                      border: OutlineInputBorder(),
                                      enabled: !wicketsWasNull && !isSaving,
                                      helperText: wicketsWasNull ? 'Not editable' : null,
                                    ),
                                    items: wicketsRanges.map((String wickets) {
                                      return DropdownMenuItem<String>(
                                        value: wickets,
                                        child: Text(wickets),
                                      );
                                    }).toList(),
                                    onChanged: (wicketsWasNull || isSaving) ? null : (String? newValue) {
                                      setState(() {
                                        selectedWickets[playerId] = newValue;
                                        player['PredictedWickets'] = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      setState(() {
                        isSaving = true;
                      });
                      
                      try {
                        // Update each player's predictions
                        for (var player in editablePlayers) {
                          String playerId = player['PlayerId'].toString();
                          
                          bool runsWasNull = widget.players.firstWhere(
                            (p) => p['PlayerId'] == playerId
                          )['PredictedRuns'] == null;
                          
                          bool wicketsWasNull = widget.players.firstWhere(
                            (p) => p['PlayerId'] == playerId
                          )['PredictedWickets'] == null;

                          await _updatePlayerInFirestore(
                            playerId,
                            runsWasNull ? null : selectedRuns[playerId],
                            wicketsWasNull ? null : selectedWickets[playerId],
                          );
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Team updated successfully'))
                        );
                        
                        setState(() {
                          isSaving = false;
                        });
                      } catch (e) {
                        setState(() {
                          isSaving = false;
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating team: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    },
                    child: isSaving 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}