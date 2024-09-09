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
  Map<String, int> predictedRuns = {};
  Map<String, int> predictedWickets = {};

  @override
  void initState() {
    super.initState();
    // Initialize the maps with default values to avoid null issues
    widget.preSelectedPlayers.forEach((key, value) {
      if (key != 'poolName' && key != 'joinedSlots' && key != 'totalSlots') {
        String role = value.split(' - ')[1];
        if (role.toLowerCase().contains('batsman') || role.toLowerCase().contains('allrounder')) {
          predictedRuns[key] = 10; // Default value
        }
        if (role.toLowerCase().contains('bowler') || role.toLowerCase().contains('allrounder')) {
          predictedWickets[key] = 1; // Default value
        }
      }
    });
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
          // Display preselected players with dropdowns
          ...widget.preSelectedPlayers.entries.map((entry) {
            if (entry.key != 'poolName' && entry.key != 'joinedSlots' && entry.key != 'totalSlots') {
              String roleAndTeam = entry.value.split(' - ')[1]; // This now contains both role and team name
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
                    Expanded(
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
                    if (role.toLowerCase().contains('batsman') || role.toLowerCase().contains('allrounder'))
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<int>(
                          value: predictedRuns[entry.key],
                          items: [for (int i = 10; i <= 100; i += 10) DropdownMenuItem(value: i, child: Text('$i'))],
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
                        width: 100,
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
              );
            }
            return SizedBox.shrink();
          }).toList(),
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 16.0),
  child: ElevatedButton(
    child: Text('Confirm Selection'),
    onPressed: () {
      // Pass detailed player data back to previous page
      Map<String, dynamic> detailedPlayers = {};
      widget.preSelectedPlayers.forEach((key, value) {
        if (key != 'poolName' && key != 'joinedSlots' && key != 'totalSlots') {
          String playerName = value.split(' - ')[0];  // Extract the player's name
          String roleAndTeam = value.split(' - ')[1]; // Contains both role and team name
          String role = roleAndTeam.split('(')[0].trim();  // Extract just the role
          String teamName = roleAndTeam.split('(')[1].replaceAll(')', '').trim(); // Extract the team name
          
          detailedPlayers[key] = {
            'PlayerName': playerName,
            'PredictedRuns': predictedRuns[key] ?? 0,
            'PredictedWickets': predictedWickets[key] ?? 0,
            'TeamName': teamName,  // Add the team name to the map
          };
        }
      });
      Navigator.pop(context, {
        'poolName': widget.preSelectedPlayers['poolName'],
        'joinedSlots': widget.preSelectedPlayers['joinedSlots'],
        'totalSlots': widget.preSelectedPlayers['totalSlots'],
        'players': detailedPlayers
      });
    },
  ),
)


        ],
      ),
    );
  }
}
