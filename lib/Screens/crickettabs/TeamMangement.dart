import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamManagementActions {
  static Future<void> updatePlayerScores(
    BuildContext context,
    String matchId,
    String teamId,
    String playerId,
    String? runsRange,    // Changed from double? to String?
    String? wickets,      // Changed from double? to String?
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Get the current document
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('selected_team')
          .doc(user.uid)
          .get();

      if (!doc.exists) throw Exception('No teams found');

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, dynamic> matchData = data[matchId] ?? {};
      Map<String, dynamic> teams = matchData['teams'] ?? {};
      Map<String, dynamic> team = teams[teamId] ?? {};
      List<dynamic> players = team['players'] ?? [];

      // Find and update the specific player
      int playerIndex = players.indexWhere((p) => p['PlayerId'].toString() == playerId);
      if (playerIndex != -1) {
        // Only update if values are not null
        if (runsRange != null) {
          players[playerIndex]['PredictedRuns'] = runsRange;  // Store the range as a string
        }
        if (wickets != null) {
          players[playerIndex]['PredictedWickets'] = wickets; // Store wickets as a string
        }

        // Update Firestore with the modified data
        await FirebaseFirestore.instance
            .collection('selected_team')
            .doc(user.uid)
            .set({
          matchId: {
            'teams': {
              teamId: {
                'players': players
              }
            }
          }
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Player scores updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating player scores: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating scores. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> replacePlayer(
    BuildContext context,
    String matchId,
    String teamId,
    String oldPlayerId,
    Map<String, dynamic> newPlayer,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('selected_team')
          .doc(user.uid)
          .get();

      if (!doc.exists) throw Exception('No teams found');

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, dynamic> matchData = data[matchId] ?? {};
      Map<String, dynamic> teams = matchData['teams'] ?? {};
      Map<String, dynamic> team = teams[teamId] ?? {};
      List<dynamic> players = team['players'] ?? [];

      // Replace the old player with the new one
      int playerIndex = players.indexWhere((p) => p['PlayerId'].toString() == oldPlayerId);
      if (playerIndex != -1) {
        players[playerIndex] = newPlayer;

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('selected_team')
            .doc(user.uid)
            .set({
          matchId: {
            'teams': {
              teamId: {
                'players': players
              }
            }
          }
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Player replaced successfully')),
        );
      }
    } catch (e) {
      print('Error replacing player: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error replacing player. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> deleteTeam(
    BuildContext context,
    String matchId,
    String teamId,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete the team from Firestore
      await FirebaseFirestore.instance
          .collection('selected_team')
          .doc(user.uid)
          .set({
        matchId: {
          'teams': {
            teamId: FieldValue.delete()
          }
        }
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team deleted successfully')),
      );
    } catch (e) {
      print('Error deleting team: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting team. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}