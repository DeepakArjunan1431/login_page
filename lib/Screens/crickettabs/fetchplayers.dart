import 'package:flutter/material.dart';
import 'package:login_page/Screens/crickettabs/PoolJoinPage.dart';

class PoolSelectionPage extends StatelessWidget {
  final String matchId;
  final int teamId1;
  final int teamId2;
  final List<Map<String, dynamic>> pools;
  final Map<String, String> preSelectedPlayers;

  PoolSelectionPage({
    required this.matchId,
    required this.teamId1,
    required this.teamId2,
    required this.pools,
    required this.preSelectedPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Selection'),
      ),
      body: ListView(
        children: [
          // Display preselected players
          ...preSelectedPlayers.entries.map((entry) {
            if (entry.key != 'poolName' && entry.key != 'joinedSlots' && entry.key != 'totalSlots') {
              return ListTile(
                title: Text(entry.value),
                subtitle: Text('Player ID: ${entry.key}'),
              );
            }
            return SizedBox.shrink();
          }),
          ElevatedButton(
            child: Text('Confirm Selection'),
            onPressed: () {
              Navigator.pop(context, preSelectedPlayers);
            },
          ),
        ],
      ),
    );
  }
}