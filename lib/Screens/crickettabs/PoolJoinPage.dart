import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_page/Models/ModelMatchInfo.dart';

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
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final team = snapshot.data![index];
                      return ExpansionTile(
                        title: Text('${team.name} (${team.shortName})'),
                        subtitle: Text('Team ID: ${team.teamId}'),
                        children: team.fullName.map((playerName) => 
                          ListTile(title: Text(playerName))
                        ).toList(),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return CircularProgressIndicator();
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
}
class PlayerInfo {
  final int teamId;
  final String fullName;

  PlayerInfo({
    required this.teamId,
    required this.fullName,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      teamId: json['teamId'],
      fullName: json['fullName'],
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
      print('Raw JSON data: ${jsonData.toString().substring(0, 500)}...'); // Print first 500 characters

      print('testing:');
      final Welcome welcome = Welcome.fromJson(jsonData);


      List<TeamDetails> teams = [];

      // Extract team details
      for (var team in [welcome.matchInfo.team1, welcome.matchInfo.team2]) {
        teams.add(TeamDetails.fromTeam(team));
        // print('Added team: ${team.name}');
        print('Added team: ${teams}');
        // print('Team ID: ${team.id}');
      }

      // print('Total teams extracted: ${teams.length}');
      return teams;
    } else {
      print('API call failed with status code: ${response.statusCode ?? "Unknown"}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load team info. Status code: ${response.statusCode ?? "Unknown"}');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw Exception('Failed to load team info: $e');
  }
}