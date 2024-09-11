import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Scorecard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cricket Scorecard'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('View Scorecard'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScoreDetailsPage(matchId: 40381)), // Example match ID
            );
          },
        ),
      ),
    );
  }
}

class ScoreCard {
  final BatTeamDetails batTeamDetails;
  final ScoreDetails scoreDetails;

  ScoreCard({
    required this.batTeamDetails,
    required this.scoreDetails,
  });

  factory ScoreCard.fromJson(Map<String, dynamic> json) {
    return ScoreCard(
      batTeamDetails: BatTeamDetails.fromJson(json['batTeamDetails']),
      scoreDetails: ScoreDetails.fromJson(json['scoreDetails']),
    );
  }
}

class BatTeamDetails {
  final int batTeamId;
  final String batTeamName;
  final String batTeamShortName;
  final Map<String, BatsmenDatum> batsmenData;

  BatTeamDetails({
    required this.batTeamId,
    required this.batTeamName,
    required this.batTeamShortName,
    required this.batsmenData,
  });

  factory BatTeamDetails.fromJson(Map<String, dynamic> json) {
    var batsmenMap = json['batsmenData'] as Map<String, dynamic>;
    Map<String, BatsmenDatum> batsmenDataMap = {};
    batsmenMap.forEach((key, value) {
      batsmenDataMap[key] = BatsmenDatum.fromJson(value);
    });

    return BatTeamDetails(
      batTeamId: json['batTeamId'],
      batTeamName: json['batTeamName'],
      batTeamShortName: json['batTeamShortName'],
      batsmenData: batsmenDataMap,
    );
  }
}

class BatsmenDatum {
  final int batId;
  final String batName;
  final bool isCaptain;
  final bool isKeeper;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final double strikeRate;
  final String outDesc;

  BatsmenDatum({
    required this.batId,
    required this.batName,
    required this.isCaptain,
    required this.isKeeper,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.outDesc,
  });

  factory BatsmenDatum.fromJson(Map<String, dynamic> json) {
    return BatsmenDatum(
      batId: json['batId'],
      batName: json['batName'],
      isCaptain: json['isCaptain'],
      isKeeper: json['isKeeper'],
      runs: json['runs'],
      balls: json['balls'],
      fours: json['fours'],
      sixes: json['sixes'],
      strikeRate: json['strikeRate'].toDouble(),
      outDesc: json['outDesc'],
    );
  }
}

class ScoreDetails {
  final int runs;
  final int wickets;
  final double overs;
  final double runRate;

  ScoreDetails({
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.runRate,
  });

  factory ScoreDetails.fromJson(Map<String, dynamic> json) {
    return ScoreDetails(
      runs: json['runs'],
      wickets: json['wickets'],
      overs: json['overs'].toDouble(),
      runRate: json['runRate'].toDouble(),
    );
  }
}

Future<ScoreCard> fetchScoreCard(int matchId) async {
  final url = 'https://cricbuzz-cricket.p.rapidapi.com/mcenter/v1/$matchId/scard';
  final headers = {
    'X-RapidAPI-Key': '01fed8d85dmsh775f48123e4a9fbp1bb2e5jsn73b9525de68c',
    'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Decoded JSON data: $jsonData');  // Add this line to print the full decoded JSON

      // For now, let's return a placeholder ScoreCard
      return ScoreCard(
        batTeamDetails: BatTeamDetails(
          batTeamId: 0,
          batTeamName: "Unknown",
          batTeamShortName: "UNK",
          batsmenData: {},
        ),
        scoreDetails: ScoreDetails(
          runs: 0,
          wickets: 0,
          overs: 0.0,
          runRate: 0.0,
        ),
      );
    } else {
      throw Exception('Failed to load scorecard: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching scorecard: $e');
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
                    Text('${snapshot.error}'),
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
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${snapshot.data!.batTeamDetails.batTeamName} - ${snapshot.data!.scoreDetails.runs}/${snapshot.data!.scoreDetails.wickets} (${snapshot.data!.scoreDetails.overs} overs)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Run Rate: ${snapshot.data!.scoreDetails.runRate.toStringAsFixed(2)}'),
                  ),
                  Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.batTeamDetails.batsmenData.length,
                    itemBuilder: (context, index) {
                      var batsman = snapshot.data!.batTeamDetails.batsmenData.values.elementAt(index);
                      return ListTile(
                        title: Text('${batsman.batName} ${batsman.isCaptain ? "(C)" : ""} ${batsman.isKeeper ? "(WK)" : ""}'),
                        subtitle: Text(batsman.outDesc),
                        trailing: Text('${batsman.runs} (${batsman.balls}) SR: ${batsman.strikeRate.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}