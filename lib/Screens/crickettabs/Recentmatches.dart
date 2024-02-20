import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/Models/Model.dart';

class Recentmatches extends StatefulWidget {
  final String apiUrl =
      'https://cricbuzz-cricket.p.rapidapi.com/matches/v1/recent';

  Recentmatches({Key? key}) : super(key: key);

  @override
  _RecentMatchesState createState() => _RecentMatchesState();
}

class _RecentMatchesState extends State<Recentmatches> {
  late Future<List<Match>> _futureRecentMatches;

  @override
  void initState() {
    super.initState();
    _futureRecentMatches = fetchData();
  }

  Future<List<Match>> fetchData() async {
    final headers = {
      'X-RapidAPI-Key': 'f34add8855mshf4b90cd3962b3f2p1700bbjsn7d596a05fe4c',
    };

    final response = await http.get(Uri.parse(widget.apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final parsedData = welcomeFromJson(response.body);
      final recentMatches = parsedData.typeMatches
          .map((typeMatch) => typeMatch.seriesMatches
              .map((seriesMatch) {
                if (seriesMatch.seriesAdWrapper != null) {
                  return seriesMatch.seriesAdWrapper?.matches.toList() ?? [];
                } else {
                  return <Match>[];
                }
              })
              .expand((element) => element)
              .toList())
          .expand((element) => element)
          .toList();
      print(response.body);
      return recentMatches;
    } else {
      throw Exception(
          'Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Matches'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _futureRecentMatches = fetchData();
              });
            },
            child: const Text('Refresh Data'),
          ),
          Expanded(
            child: FutureBuilder<List<Match>>(
              future: _futureRecentMatches,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final recentMatches = snapshot.data ?? [];
                  if (recentMatches.isEmpty) {
                    return Center(child: Text('No recent matches available'));
                  } else {
                    return ListView.builder(
                      itemCount: recentMatches.length,
                      itemBuilder: (context, index) {
                        final match = recentMatches[index];
                        return GestureDetector(
                          onTap: () {
                            // Define the action to take when the card is tapped.
                            // For example, you can navigate to a new page.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MatchDetailsPage(
                                  match: match,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2.0,
                            margin: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '${match.matchInfo.seriesName}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${match.matchInfo.team1.teamName}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'vs', // Your center text
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${match.matchInfo.team2.teamName}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

class MatchDetailsPage extends StatefulWidget {
  final Match match;

  MatchDetailsPage({required this.match});

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  bool isTeam1DropdownOpen = false;
  bool isTeam2DropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Series: ${widget.match.matchInfo.seriesName}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  isTeam1DropdownOpen = !isTeam1DropdownOpen;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.match.matchInfo.team1.teamName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.match.matchScore?.team1Score.inngs1?.runs}/${widget.match.matchScore?.team1Score.inngs1?.wickets}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Overs: ${widget.match.matchScore?.team1Score.inngs1?.overs}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // Icon(
                  //   isTeam1DropdownOpen
                  //       ? Icons.arrow_drop_up
                  //       : Icons.arrow_drop_down,
                  // ),
                ],
              ),
            ),
            if (isTeam1DropdownOpen)
              DropdownButton<String>(
                items: <String>['Option 1', 'Option 2', 'Option 3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Handle dropdown item selection
                },
              ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  isTeam2DropdownOpen = !isTeam2DropdownOpen;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.match.matchInfo.team2.teamName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.match.matchScore?.team2Score?.inngs1?.runs}/${widget.match.matchScore?.team2Score?.inngs1?.wickets}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Overs: ${widget.match.matchScore?.team2Score?.inngs1?.overs}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // Icon(
                  //   isTeam2DropdownOpen
                  //       ? Icons.arrow_drop_up
                  //       : Icons.arrow_drop_down,
                  // ),
                ],
              ),
            ),
            if (isTeam2DropdownOpen)
              DropdownButton<String>(
                items: <String>['Option A', 'Option B', 'Option C']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Handle dropdown item selection
                },
              ),
            SizedBox(height: 20),
            Text(
              'Status: ${widget.match.matchInfo.status}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            // You can add more details as needed
          ],
        ),
      ),
    );
  }
}
