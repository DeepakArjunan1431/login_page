import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  final int matchId;
  final String poolType;
  final String poolName;

  LeaderboardPage({
    required this.matchId,
    required this.poolType,
    required this.poolName,
  });

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get the pool document
      DocumentSnapshot poolSnapshot = await _firestore
          .collection('Pool')
          .doc(widget.poolType)
          .get();

      if (!poolSnapshot.exists) {
        throw Exception('Pool does not exist');
      }

      Map<String, dynamic>? data = poolSnapshot.data() as Map<String, dynamic>?;
      Map<String, dynamic> matches = data?['matches'] ?? {};

      // Get the specific match data
      Map<String, dynamic>? matchData = matches[widget.matchId.toString()];
      if (matchData == null) {
        throw Exception('Match not found');
      }

      // Get the specific pool data
      Map<String, dynamic>? poolData = matchData[widget.poolName];
      if (poolData == null) {
        throw Exception('Pool not found');
      }

      // Get all user joins
      Map<String, dynamic> userJoins = poolData['userJoins'] ?? {};

      List<Map<String, dynamic>> leaderboardEntries = [];

      // Process each user's teams
      for (var userId in userJoins.keys) {
        var userTeams = userJoins[userId]['teams'] as List?;
        if (userTeams != null) {
          for (var team in userTeams) {
            if (team['totalScore'] != null) { // Only include teams with scores
              leaderboardEntries.add({
                'userId': userId,
                'teamId': team['teamId'],
                'totalScore': team['totalScore'],
                'userName': userJoins[userId]['userName'] ?? 'Unknown User',
                'timestamp': team['scoreCard']?['matchCompleteTimestamp'] ?? 0,
              });
            }
          }
        }
      }

      // Sort by total score in descending order
      leaderboardEntries.sort((a, b) => (b['totalScore'] as num).compareTo(a['totalScore'] as num));

      // Add rank to each entry
      for (int i = 0; i < leaderboardEntries.length; i++) {
        leaderboardEntries[i]['rank'] = i + 1;
      }

      setState(() {
        _leaderboardData = leaderboardEntries;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching leaderboard data: $e');
      setState(() {
        _errorMessage = 'Failed to load leaderboard: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchLeaderboardData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_leaderboardData.isEmpty) {
      return Center(child: Text('No scores available yet'));
    }

    return Column(
      children: [
        _buildLeaderboardHeader(),
        Expanded(child: _buildLeaderboardList()),
      ],
    );
  }

  Widget _buildLeaderboardHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match ID: ${widget.matchId}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Pool: ${widget.poolName}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Total Participants: ${_leaderboardData.length}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      itemCount: _leaderboardData.length,
      itemBuilder: (context, index) {
        final entry = _leaderboardData[index];
        final isTopThree = entry['rank'] <= 3;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: isTopThree ? _getTopThreeColor(entry['rank']) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isTopThree ? Colors.transparent : Colors.grey[200],
              child: isTopThree
                  ? Icon(_getTopThreeIcon(entry['rank']), color: Colors.white)
                  : Text(entry['rank'].toString()),
            ),
            title: Text(
              entry['userName'],
              style: TextStyle(
                fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                color: isTopThree ? Colors.white : null,
              ),
            ),
            subtitle: Text(
              'Team ID: ${entry['teamId']}',
              style: TextStyle(
                color: isTopThree ? Colors.white70 : Colors.grey[600],
              ),
            ),
            trailing: Text(
              'Score: ${entry['totalScore']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTopThree ? Colors.white : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTopThreeColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!;
      case 2:
        return Colors.blueGrey[700]!;
      case 3:
        return Colors.brown[700]!;
      default:
        return Colors.white;
    }
  }

  IconData _getTopThreeIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.person;
    }
  }
}