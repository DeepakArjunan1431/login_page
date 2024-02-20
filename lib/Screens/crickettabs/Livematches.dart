import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/Models/Model.dart';

class Livematches extends StatefulWidget {
  final String apiUrl =
      'https://cricbuzz-cricket.p.rapidapi.com/matches/v1/live';

  Livematches({Key? key}) : super(key: key);

  @override
  _LivematchesState createState() => _LivematchesState();
}

class _LivematchesState extends State<Livematches> {
  late Future<List<String>> _futureTeamNames;

  @override
  void initState() {
    super.initState();
    _futureTeamNames = fetchData();
  }

  Future<List<String>> fetchData() async {
    final headers = {
      'X-RapidAPI-Key': 'f34add8855mshf4b90cd3962b3f2p1700bbjsn7d596a05fe4c',
    };

    final response = await http.get(Uri.parse(widget.apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final parsedData = welcomeFromJson(response.body);

      final teamNames = parsedData.typeMatches
          .map((typeMatch) => typeMatch.seriesMatches.map((seriesMatch) {
                final team1Name = seriesMatch.seriesAdWrapper?.matches
                        .map((match) => match.matchInfo.team1.teamName) ??
                    [];
                final team2Name = seriesMatch.seriesAdWrapper?.matches
                        .map((match) => match.matchInfo.team2.teamName) ??
                    [];
                return '$team1Name vs $team2Name';
              }).toList())
          .expand((element) => element)
          .toList();
      return teamNames;
    } else {
      throw Exception(
          'Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Matches'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _futureTeamNames = fetchData();
              });
            },
            child: const Text('Refresh Data'),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _futureTeamNames,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final teamNames = snapshot.data!;
                  if (teamNames.isEmpty) {
                    return Center(child: Text('No team names available'));
                  } else {
                    return ListView.builder(
                      itemCount: teamNames.length,
                      itemBuilder: (context, index) {
                        final matchInfo = teamNames[index].split(' vs ');
                        final team1Name = matchInfo[0];
                        final team2Name = matchInfo[1];
                        return Card(
                          elevation: 2.0,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: Icon(
                                Icons.sports_soccer), // Add an appropriate icon
                            title: Text(
                              '$team1Name vs $team2Name',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle:
                                Text('Match details here'), // Add match details
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Handle actions when this button is pressed
                              },
                              child: Text('Join'), // Customize the button text
                            ),
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
