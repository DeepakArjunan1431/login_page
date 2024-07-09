import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'matchdetails.dart'; // Adjust this import based on your file structure

class MatchListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches'),
        backgroundColor: Color(0xFFFFD180),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('matches').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('${data['team1']} vs ${data['team2']}'),
                  subtitle: Text('Tap to view details'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchDetailsPage(
                          team1Name: data['team1'],
                          team2Name: data['team2'],
                          matchId: doc.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}