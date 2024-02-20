import 'package:flutter/material.dart';
import 'package:login_page/Models/modelforbatterscore.dart';
import 'package:http/http.dart' as http;

class Scorecard extends StatefulWidget {
  final String apiCardUrl =
      'https://cricbuzz-cricket.p.rapidapi.com/mcenter/v1/75476/scard';
  Scorecard({Key? key}) : super(key: key);

  @override
  _ScoreCard createState() => _ScoreCard();
}

class _ScoreCard extends State<Scorecard> {
  late Future<List<ScoreCard>> _futureScoreCard;

  @override
  void initState() {
    super.initState();
    _futureScoreCard = fetchCard();
  }

  Future<List<ScoreCard>> fetchCard() async {
    final headers = {
      'X-RapidAPI-Key': 'f34add8855mshf4b90cd3962b3f2p1700bbjsn7d596a05fe4c',
    };
    final responseForCard =
        await http.get(Uri.parse(widget.apiCardUrl), headers: headers);
    if (responseForCard.statusCode == 200) {
      final parsedDataOfCard = welcomedFromJson(responseForCard.body);
      final scorecardWidget = parsedDataOfCard.scoreCard
          .map((ScoreCard scoreCard) => scoreCard)
          .toList();
      print(responseForCard.body);

      return scorecardWidget;
    } else {
      throw Exception(
          'Failed to Fetch Data. Status Code : ${responseForCard.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ScoreCard>>(
        future: _futureScoreCard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // You can use the snapshot.data to display the scorecard data
            final scorecardData = snapshot.data; // Safely access snapshot.data
            if (scorecardData != null && scorecardData.isNotEmpty) {
              return buildScoreCardUI(scorecardData);
            } else {
              return Text('No data available');
            }
          }
        },
      ),
    );
  }

  Widget buildScoreCardUI(List<ScoreCard> scorecardData) {
    // Build and return your UI components using the scorecardData
    return Text(scorecardData[0].batTeamDetails.batTeamName);
  }
}
