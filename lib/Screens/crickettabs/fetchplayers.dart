import 'package:flutter/material.dart';

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
  Map<String, String> predictedRuns = {}; // Changed to String to store ranges
  Map<String, int> predictedWickets = {};
  Map<String, int?> priorities = {}; // Track priorities for each player
  Map<String, String> playerRoles = {};//  map to store player roles
  int currentPriority = 12; // Start with the highest priority

 
   @override
  void initState() {
    super.initState();
    widget.preSelectedPlayers.forEach((key, value) {
      if (key != 'poolName' && key != 'joinedSlots' && key != 'totalSlots') {
        String role = value.split(' - ')[1].split('(')[0].trim().toLowerCase();
        playerRoles[key] = role; // Store the role for each player

        if (role.contains('batsman') || role.contains('allrounder')) {
          predictedRuns[key] = '0-10';
        }
        if (role.contains('bowler') || role.contains('allrounder')) {
          predictedWickets[key] = 1;
        }
        priorities[key] = null;
      }
    });
  }
  void togglePriority(String playerId) {
    setState(() {
      if (priorities[playerId] == null && currentPriority > 0) {
        // Assign the next available priority when the checkbox is checked
        priorities[playerId] = currentPriority;
        currentPriority--;
      } else if (priorities[playerId] != null) {
        // Uncheck the priority and reset it when the checkbox is unchecked
        int uncheckingPriority = priorities[playerId]!;
        // Reset the priorities for all players that have a higher or equal priority
        priorities.forEach((key, value) {
          if (value != null && value <= uncheckingPriority) {
            priorities[key] = null;
            currentPriority++; // Increment currentPriority back for each unchecked priority
          }
        print('Priority toggled for player $playerId. New priorities: $priorities'); // Added print statement
    });
      }
    });
  }

  bool allPrioritiesAssigned() {
    // Check if all players have an assigned priority
    return priorities.values.every((priority) => priority != null);
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
          // Display preselected players with dropdowns and priority checkboxes
          ...widget.preSelectedPlayers.entries.map((entry) {
            if (entry.key != 'poolName' && entry.key != 'joinedSlots' && entry.key != 'totalSlots') {
              String roleAndTeam = entry.value.split(' - ')[1]; // Contains both role and team name
              String role = roleAndTeam.split('(')[0].trim();  // Extract just the role
              String teamName = roleAndTeam.split('(')[1].replaceAll(')', '').trim(); // Extract just the team name

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
                    // First column: Player details
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.split(' - ')[0], // Display full name
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Player ID: ${entry.key}, Role: $role, Team: $teamName', // Display role and team name
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
// Add space between the two columns
    SizedBox(width:5), // Adjust the width to your desired spacing
                    // Second column: Dropdowns and priority checkbox stacked vertically
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Runs and Wickets dropdowns
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (role.toLowerCase().contains('batsman') || role.toLowerCase().contains('allrounder'))
                                SizedBox(
                                  width: 90, // Increased width to accommodate longer text
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
                                    style: TextStyle(fontSize: 14, color: Colors.black), // Text color
                                  ),
                                ),
                              if (role.toLowerCase().contains('bowler') || role.toLowerCase().contains('allrounder'))
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
                                    style: TextStyle(fontSize: 14, color: Colors.black), // Text color
                                  ),
                                ),
                            ],
                          ),
                          
                          SizedBox(height: 8.0), // Spacing between dropdowns and checkbox

                          // Priority checkbox and label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox(
                                value: priorities[entry.key] != null, // Check if player has a priority
                                onChanged: (value) {
                                  togglePriority(entry.key); // Toggle priority when checked/unchecked
                                },
                                activeColor: Colors.green,
                              ),
                              if (priorities[entry.key] != null)
                                Text(
                                  'Priority: ${priorities[entry.key]}', // Display assigned priority
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

          // Confirm Selection Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              child: Text('Confirm Selection'),
              onPressed: allPrioritiesAssigned()
                  ? () {
                      Map<String, dynamic> detailedPlayers = {};
                      widget.preSelectedPlayers.forEach((key, value) {
                        if (key != 'poolName' && key != 'joinedSlots' && key != 'totalSlots') {
                          String playerName = value.split(' - ')[0];
                          String roleAndTeam = value.split(' - ')[1];
                          String role = roleAndTeam.split('(')[0].trim();
                          String teamName = roleAndTeam.split('(')[1].replaceAll(')', '').trim();

                          // Create player data based on their role
                          Map<String, dynamic> playerData = {
                            'PlayerName': playerName,
                            'TeamName': teamName,
                            'Priority': priorities[key],
                          };

                          if (role.toLowerCase().contains('batsman')) {
                            playerData['PredictedRuns'] = predictedRuns[key] ?? '0-10';
                          } else if (role.toLowerCase().contains('bowler')) {
                            playerData['PredictedWickets'] = predictedWickets[key] ?? 0;
                          } else if (role.toLowerCase().contains('allrounder')) {
                            playerData['PredictedRuns'] = predictedRuns[key] ?? '0-10';
                            playerData['PredictedWickets'] = predictedWickets[key] ?? 0;
                          }

                          detailedPlayers[key] = playerData;
                        }
                      });

                      print('Confirmed selection: $detailedPlayers'); // For debugging

                      Navigator.pop(context, {
                        'poolName': widget.preSelectedPlayers['poolName'],
                        'joinedSlots': widget.preSelectedPlayers['joinedSlots'],
                        'totalSlots': widget.preSelectedPlayers['totalSlots'],
                        'players': detailedPlayers,
                      });
                    }
                  : null, // Disable button if not all priorities are assigned
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => allPrioritiesAssigned() ? const Color.fromARGB(255, 2, 38, 67) : Colors.grey, // Change button color based on state
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}