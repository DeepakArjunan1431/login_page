import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_page/Screens/Home_Screen.dart';
import 'package:login_page/utils/Colours.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cricket Team',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: TeamSelectionPage(),
//     );
//   }
// }

class TeamSelectionPage extends StatefulWidget {
  @override
  _TeamSelectionPageState createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  Set<String> selectedTeams = Set();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD180),
        // title: Text('IPL Teams'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringtoColor("FFD180"), // Light orange at the top
                hexStringtoColor("FFE5C4"), // Light skin color at the bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select your favourite Team',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TeamCard(
                      teamName: 'Chennai Super Kings',
                      imageAsset: 'assets/iplteam/Team1.png',
                      isSelected: selectedTeams.contains('Chennai Super Kings'),
                      onTap: () {
                        toggleSelectedTeam('Chennai Super Kings');
                      },
                    ),
                    TeamCard(
                      teamName: 'Mumbai Indians',
                      imageAsset: 'assets/iplteam/Team3.png',
                      isSelected: selectedTeams.contains('Mumbai Indians'),
                      onTap: () {
                        toggleSelectedTeam('Mumbai Indians');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20), // Add spacing between rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TeamCard(
                      teamName: 'Royal Challengers Bangalore',
                      imageAsset: 'assets/iplteam/Team4.png',
                      isSelected:
                          selectedTeams.contains('Royal Challengers Bangalore'),
                      onTap: () {
                        toggleSelectedTeam('Royal Challengers Bangalore');
                      },
                    ),
                    TeamCard(
                      teamName: 'Kolkata Knight Riders',
                      imageAsset: 'assets/iplteam/Team8.png',
                      isSelected:
                          selectedTeams.contains('Kolkata Knight Riders'),
                      onTap: () {
                        toggleSelectedTeam('Kolkata Knight Riders');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20), // Add spacing between rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TeamCard(
                      teamName: 'kings XI Punjab',
                      imageAsset: 'assets/iplteam/Team5.png',
                      isSelected: selectedTeams.contains('kings XI Punjab'),
                      onTap: () {
                        toggleSelectedTeam('kings XI Punjab');
                      },
                    ),
                    TeamCard(
                      teamName: 'Delhi Capitals',
                      imageAsset: 'assets/iplteam/Team2.png',
                      isSelected: selectedTeams.contains('Delhi Capitals'),
                      onTap: () {
                        toggleSelectedTeam('Delhi Capitals');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TeamCard(
                      teamName: 'Lucknow Super Gaints',
                      imageAsset: 'assets/iplteam/Team7.png',
                      isSelected: selectedTeams.contains('Chennai Super Kings'),
                      onTap: () {
                        toggleSelectedTeam('Lucknow Super Gaints');
                      },
                    ),
                    TeamCard(
                      teamName: 'Gujarath Titans',
                      imageAsset: 'assets/iplteam/Team8.png',
                      isSelected: selectedTeams.contains('Gujarath Titans'),
                      onTap: () {
                        toggleSelectedTeam('Mumbai Indians');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedTeams.isNotEmpty) {
            addSelectedTeamsToFirestore();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          } else {
            print('No teams selected.');
          }
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  void toggleSelectedTeam(String teamName) {
    setState(() {
      if (selectedTeams.contains(teamName)) {
        selectedTeams.remove(teamName);
      } else {
        selectedTeams.add(teamName);
      }
    });
  }

  void addSelectedTeamsToFirestore() {
    // Get the current user's UID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Create a map to hold selected team names
      List<String> selectedTeamsList = selectedTeams.toList();

      // Update the 'selected_teams' field in the user document
      userDoc.update({
        'selected_teams': selectedTeamsList,
      }).then((_) {
        print('Selected teams added to user document in Firestore');
      }).catchError((error) {
        print(
            'Failed to add selected teams to user document in Firestore: $error');
      });
    } else {
      print('User not authenticated.');
    }
  }
}

class TeamCard extends StatelessWidget {
  final String teamName;
  final String imageAsset;
  final VoidCallback onTap;
  final bool isSelected;

  TeamCard({
    required this.teamName,
    required this.imageAsset,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 170,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color(0xFFaa8d6f),
          borderRadius: BorderRadius.circular(10.0),
          border:
              isSelected ? Border.all(color: Colors.green, width: 2.0) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              teamName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
