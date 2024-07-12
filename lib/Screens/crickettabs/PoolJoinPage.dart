import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_page/Models/ModelMatchInfo.dart';
// import 'package:login_page/Models/teaminfomodel.dart';

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
      body: SingleChildScrollView(
        child: Column(
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
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    children: snapshot.data!.map((team) => buildTeamTile(team)).toList(),
                  );
                } else {
                  return Text('No team information available for this match.');
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Implement join pool logic
                Navigator.pop(context, true);
              },
              child: Text('Join Pool'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTeamTile(TeamDetails team) {
    return ExpansionTile(
      title: Text('${team.name} (${team.shortName})'),
      subtitle: Text('Team ID: ${team.teamId}'),
      children: team.playerDetails.map((player) =>
        ListTile(
          title: Text(player.fullName),
          subtitle: Text(player.nickName),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (player.captain) Icon(Icons.star, size: 20),
              if (player.keeper) Icon(Icons.sports_cricket, size: 20),
              if (player.substitute) Icon(Icons.swap_horiz, size: 20),
            ],
          ),
        )
      ).toList(),
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
      print('Raw JSON data: ${jsonData.toString()}'); // Print entire JSON data

      // Extract matchInfo
      final matchInfo = jsonData['matchInfo'];
      if (matchInfo == null) {
        throw Exception('No matchInfo found in JSON response');
      }
     final team1Players = matchInfo['team1']['playerDetails'] as List<dynamic>?;

if (team1Players != null) {
  final team1PlayerNames = team1Players.map((player) => player['fullName'] as String).toList();
  if (team1PlayerNames.isNotEmpty) {
    print('Team 1 players:');
    team1PlayerNames.forEach((playerName) => print(playerName));
  } else {
    print('No players found for Team 1');
  }
} else {
  print('No players found for Team 12');
}


// Similar logic for team2
final team2Players = matchInfo['team2']['playerDetails'] as List<dynamic>?;

if (team2Players != null && team2Players.isNotEmpty) {
  final team2PlayerNames = team2Players.map((player) => player['fullName'] as String).toList();
  print('Team 2 players:');
  team2PlayerNames.forEach((playerName) => print(playerName));
} else {
  print('No players found for Team 2');
}

      List<TeamDetails> teams = [];

      // Extract team details
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
      return []; // Return an empty list instead of throwing an exception
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
