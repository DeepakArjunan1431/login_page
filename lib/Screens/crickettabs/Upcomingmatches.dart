import 'package:flutter/material.dart';
import 'package:login_page/Models/Model.dart'; // Ensure this import is correct based on your project structure
import 'package:http/http.dart' as http;
import 'matchdetails.dart'; // Import the match details page

class Upcomingmatches extends StatefulWidget {
  final String apiUrl =
      'https://cricbuzz-cricket.p.rapidapi.com/matches/v1/upcoming';

  Upcomingmatches({Key? key}) : super(key: key);

  @override
  _UpcomingmatchesState createState() => _UpcomingmatchesState();
}

class _UpcomingmatchesState extends State<Upcomingmatches> {
  late Future<List<matchdata>> _futureMatchDetails;

  @override
  void initState() {
    super.initState();
    _futureMatchDetails = fetchData();
  }

  Future<List<matchdata>> fetchData() async {
    final headers = {
      'X-RapidAPI-Key': 'f34add8855mshf4b90cd3962b3f2p1700bbjsn7d596a05fe4c',
    };

    final response = await http.get(Uri.parse(widget.apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final parsedData = welcomeFromJson(response.body);

      final matchDetails = parsedData.typeMatches
          .expand((typeMatch) => typeMatch.seriesMatches)
          .expand((seriesMatch) => seriesMatch.seriesAdWrapper?.matches ?? [])
          .where((match) => match.matchInfo.state.toLowerCase() != "upcoming")
          .map((match) {
            final team1Name = match.matchInfo.team1?.teamName ?? 'Unknown';
            final team2Name = match.matchInfo.team2?.teamName ?? 'Unknown';
            final matchId = match.matchInfo.matchId;
            final teamId1 = match.matchInfo.team1?.teamId ?? 0;
            final teamId2 = match.matchInfo.team2?.teamId ?? 0;
            final state = match.matchInfo.state;

            return matchdata(
              matchId: matchId,
              teamId1: teamId1,
              teamId2: teamId2,
              team1: team1Name,
              team2: team2Name,
              state: state,
            );
          }).toList();

      return matchDetails;
    } else {
      throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Matches'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _futureMatchDetails = fetchData();
              });
            },
            child: const Text('Refresh Data'),
          ),
          Expanded(
            child: FutureBuilder<List<matchdata>>(
              future: _futureMatchDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final matchDetails = snapshot.data!;
                  if (matchDetails.isEmpty) {
                    return Center(child: Text('No matches available'));
                  } else {
                    return ListView.builder(
                      itemCount: matchDetails.length,
                      itemBuilder: (context, index) {
                        final matchDetail = matchDetails[index];
                        return Card(
                          elevation: 2.0,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: Icon(Icons.sports_soccer),
                            title: Text(
                              '${matchDetail.team1} vs ${matchDetail.team2}',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Team ID: ${matchDetail.teamId1} vs ${matchDetail.teamId2}'),
                                Text('State: ${matchDetail.state}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MatchDetailsPage(
                                      team1Name: matchDetail.team1,
                                      team2Name: matchDetail.team2,
                                      matchId: matchDetail.matchId.toString(),
                                      teamId1: matchDetail.teamId1,
                                      teamId2: matchDetail.teamId2,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Join',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
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

class matchdata {
  final int matchId;
  final int teamId1;
  final int teamId2;
  final String team1;
  final String team2;
  final String state;

  const matchdata({
    required this.matchId,
    required this.teamId1,
    required this.teamId2,
    required this.team1,
    required this.team2,
    required this.state,
  });
}