import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:login_page/Models/ModelMatchInfo.dart';

class JoinPoolPage extends StatefulWidget {
  final String poolName;
  final int joinedSlots;
  final int totalSlots;
  final String matchId;
  final int teamId1;
  final int teamId2;

  JoinPoolPage({
    required this.poolName,
    required this.joinedSlots,
    required this.totalSlots,
    required this.matchId,
    required this.teamId1,
    required this.teamId2,
  });

  @override
  _JoinPoolPageState createState() => _JoinPoolPageState();
}

class _JoinPoolPageState extends State<JoinPoolPage> {
  late Future<List<TeamDetails>> futureTeamDetails;

  @override
  void initState() {
    super.initState();
    futureTeamDetails = fetchPlayerInfo(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join ${widget.poolName}'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Match ID: ${widget.matchId}'),
                Text('Pool Name: ${widget.poolName}'),
                Text('Joined Slots: ${widget.joinedSlots}'),
                Text('Total Slots: ${widget.totalSlots}'),
                Text('Team ID 1: ${widget.teamId1}'),
                Text('Team ID 2: ${widget.teamId2}'),
                SizedBox(height: 20),
                Text('Team Information:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          FutureBuilder<List<TeamDetails>>(
            future: futureTeamDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Column(
                  children: snapshot.data!.map((team) => buildTeamTile(team)).toList(),
                );
              } else {
                return Center(child: Text('No team information available for this match.'));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Implement join pool logic
                Navigator.pop(context, true);
              },
              child: Text('Join Pool'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeamTile(TeamDetails team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${team.name} (${team.shortName})', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: team.playerDetails.map((player) => buildPlayerCard(player)).toList(),
        ),
      ],
    );
  }

  Widget buildPlayerCard(PlayerDetails player) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(player.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(player.nickName),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (player.captain) Icon(Icons.star, size: 20),
                if (player.keeper) Icon(Icons.sports_cricket, size: 20),
                if (player.substitute) Icon(Icons.swap_horiz, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<TeamDetails>> fetchPlayerInfo(String matchId) async {
  final String apiUrl = 'https://cricbuzz-cricket.p.rapidapi.com/mcenter/v1/$matchId';
  final String apiKey = '01fed8d85dmsh775f48123e4a9fbp1bb2e5jsn73b9525de68c';

  print('Fetching data from: $apiUrl');

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
      },
    );

    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('API call successful');
      final jsonData = json.decode(response.body);
      print('Raw JSON data: ${jsonData.toString()}');

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
          )
        ).toList();

        TeamDetails team = TeamDetails(
          id: teamData['id'],
          teamId: teamData['id'],
          name: teamData['name'],
          shortName: teamData['shortName'],
          playerDetails: playerDetails,
        );
        teams.add(team);
        print('Added team: ${team.name}');
        print('Team ID: ${team.teamId}');
      }

      print('Total teams extracted: ${teams.length}');
      return teams;
    } else if (response.statusCode == 204) {
      print('No content available for this match ID');
      return [];
    } else {
      print('API call failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load team info. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw Exception('Failed to load team info: $e');
  }
}

// Make sure you have these classes defined in your ModelMatchInfo.dart file:

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

  PlayerDetails({
    required this.id,
    required this.fullName,
    required this.nickName,
    required this.captain,
    required this.keeper,
    required this.substitute,
  });
}