import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_page/Screens/scorecomparisonpage.dart';

class UserPoolsPage extends StatefulWidget {
  @override
  _UserPoolsPageState createState() => _UserPoolsPageState();
}

class _UserPoolsPageState extends State<UserPoolsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> userPools = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserPools();
  }

  Future<void> fetchUserPools() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user is currently signed in');
      }

      List<String> poolTypes = ['Pool', 'LargePool', 'MiniPool'];
      List<Map<String, dynamic>> fetchedPools = [];

      for (String poolType in poolTypes) {
        DocumentSnapshot poolSnapshot = await _firestore.collection('Pool').doc(poolType).get();
        
        if (poolSnapshot.exists) {
          Map<String, dynamic>? data = poolSnapshot.data() as Map<String, dynamic>?;
          Map<String, dynamic> matches = data?['matches'] ?? {};

          matches.forEach((matchId, matchData) {
            if (matchData is Map<String, dynamic>) {
              matchData.forEach((poolName, poolData) {
                if (poolData is Map && poolData['userJoins'] is Map && 
                    poolData['userJoins'][userId] is Map) {
                  Map<String, dynamic> userJoinData = poolData['userJoins'][userId];
                  List<dynamic> teams = userJoinData['teams'] ?? [];

                  for (var team in teams) {
                    if (team is Map<String, dynamic>) {
                      fetchedPools.add({
                        'matchId': matchId,
                        'poolType': poolType,
                        'poolName': poolName,
                        'team': team,
                      });
                    }
                  }
                }
              });
            }
          });
        }
      }

      setState(() {
        userPools = fetchedPools;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user pools: $e');
      setState(() {
        errorMessage = 'Failed to load pools. Please try again later.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pools'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : userPools.isEmpty
                  ? Center(child: Text('No pools joined yet.'))
                  : ListView.builder(
                      itemCount: userPools.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> pool = userPools[index];
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Match ID: ${pool['matchId']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pool Type: ${pool['poolType']}'),
                                Text('Pool Name: ${pool['poolName']}'),
                                Text('Players:'),
                                ..._buildPlayerList(pool['team']),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreComparisonPage(
                                    matchId: int.parse(pool['matchId']),
                                    poolType: pool['poolType'],
                                    poolName: pool['poolName'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }

 List<Widget> _buildPlayerList(Map<String, dynamic> team) {
  List<dynamic>? players = team['players'] as List<dynamic>?;
  if (players == null || players.isEmpty) {
    return [Text('  No players data available')];
  }
  return players.map((player) {
    if (player is Map<String, dynamic>) {
      return Text(
        '  ${player['PlayerName'] ?? 'Unknown'} - '
        'Team: ${player['TeamName'] ?? 'Unknown'}, ' // Display the team name
        'Runs: ${player['PredictedRuns'] ?? 'N/A'}, '
        'Wickets: ${player['PredictedWickets'] ?? 'N/A'}'
      );
    }
    return Text('  Invalid player data');
  }).toList();
}

}