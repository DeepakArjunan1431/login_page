 import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/Models/CricketModel.dart';
import 'dart:convert';

Future<ScoreCard> fetchScoreCard(int matchId) async {
  final url = 'https://cricbuzz-cricket.p.rapidapi.com/mcenter/v1/$matchId/scard';
  final headers = {
    'X-RapidAPI-Key': '01fed8d85dmsh775f48123e4a9fbp1bb2e5jsn73b9525de68c',
    'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ScoreCard.fromJson(jsonData);
    } else {
      throw Exception('Failed to load scorecard: HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load scorecard: $e');
  }
}

class ScoreDetailsPage extends StatefulWidget {
  final int matchId;

  ScoreDetailsPage({required this.matchId});

  @override
  _ScoreDetailsPageState createState() => _ScoreDetailsPageState();
}

class _ScoreDetailsPageState extends State<ScoreDetailsPage> {
  late Future<ScoreCard> futureScoreCard;

  @override
  void initState() {
    super.initState();
    futureScoreCard = fetchScoreCard(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Details'),
      ),
      body: FutureBuilder<ScoreCard>(
        future: futureScoreCard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          } else if (snapshot.hasData) {
            final scoreCard = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < scoreCard.innings.length; i++)
                      _buildInningsDetails(scoreCard.innings[i], i + 1),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading scorecard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('$error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  futureScoreCard = fetchScoreCard(widget.matchId);
                });
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInningsDetails(InningsDetails innings, int inningsNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Innings $inningsNumber',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          innings.batTeamDetails.batTeamName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '${innings.scoreDetails.runs}/${innings.scoreDetails.wickets} (${innings.scoreDetails.overs} overs)',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text('Run Rate: ${innings.scoreDetails.runRate.toStringAsFixed(2)}'),
        SizedBox(height: 16),
        _buildBatsmenTable(innings.batTeamDetails.batsmenData),
        SizedBox(height: 16),
        _buildBowlersTable(innings.bowlTeamDetails.bowlersData),
        SizedBox(height: 16),
        _buildWicketsTable(innings.wicketsData),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBatsmenTable(Map<String, BatsmenDatum> batsmenData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Batsmen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          columnWidths: {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: ['Batsman', 'R', 'B', 'SR']
                  .map((e) => TableCell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(e, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ))
                  .toList(),
            ),
            ...batsmenData.values.map((batsman) => TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${batsman.batName} ${batsman.isCaptain ? "(C)" : ""} ${batsman.isKeeper ? "(WK)" : ""}'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${batsman.runs}'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${batsman.balls}'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${batsman.strikeRate.toStringAsFixed(2)}'),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildBowlersTable(Map<String, BowlerDatum> bowlersData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bowlers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          columnWidths: {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: ['Bowler', 'O', 'M', 'R', 'W']
                  .map((e) => TableCell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(e, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ))
                  .toList(),
            ),
            ...bowlersData.values.map((bowler) => TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${bowler.bowlName} ${bowler.isCaptain ? "(C)" : ""} ${bowler.isKeeper ? "(WK)" : ""}'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${bowler.overs}'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${bowler.maidens}'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${bowler.runs}'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${bowler.wickets}'),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildWicketsTable(Map<String, WicketsDatum> wicketsData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              children: ['Batsman', 'Dismissal']
                  .map((e) => TableCell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(e, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ))
                  .toList(),
            ),
            ...wicketsData.values.map((wicket) => TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(wicket.batName),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(wicket.wicketDesc),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }
}