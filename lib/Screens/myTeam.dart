import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTeamPage extends StatefulWidget {
  final String matchId;
  final int teamId1;
  final int teamId2;

  MyTeamPage({
    required this.matchId,
    required this.teamId1,
    required this.teamId2,
  });

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  Map<String, Map<String, dynamic>> teamsData = {
    'team1': {},
    'team2': {}
  };

  @override
  void initState() {
    super.initState();
    _fetchTeamData();
  }

  Future<void> _fetchTeamData() async {
    try {
      String poolDoc = _getPoolDocName(); // Implement this method if needed
      var docSnapshot = await FirebaseFirestore.instance
          .collection('Pool')
          .doc(poolDoc)
          .collection('matches')
          .doc(widget.matchId)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data != null) {
          setState(() {
            teamsData['team1'] = Map<String, dynamic>.from(data['team1'] ?? {});
            teamsData['team2'] = Map<String, dynamic>.from(data['team2'] ?? {});
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data found for the selected match.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching team data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching team data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getPoolDocName() {
    // Implement logic to generate or fetch the pool document name if needed
    return 'example_pool_doc_name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Team'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildTeamSection('Team 1', teamsData['team1'] ?? {}),
                  _buildTeamSection('Team 2', teamsData['team2'] ?? {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(String teamName, Map<String, dynamic> team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...team.entries.map((entry) {
          var playerId = entry.key;
          var playerData = entry.value;
          var playerName = playerData['name'];
          var predictedRuns = playerData['predictedRuns'] ?? '-';
          var predictedWickets = playerData['predictedWickets'] ?? '-';

          return Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  playerName,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Runs: $predictedRuns, Wickets: $predictedWickets',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }).toList(),
        SizedBox(height: 20),
      ],
    );
  }
}
