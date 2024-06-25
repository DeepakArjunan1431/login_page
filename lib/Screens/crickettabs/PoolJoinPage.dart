import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PoolJoinPage extends StatefulWidget {
  final String matchId;
  final int poolIndex;
  final String poolName;
  final int joinedSlots;
  final int totalSlots;

  PoolJoinPage({
    required this.matchId,
    required this.poolIndex,
    required this.poolName,
    required this.joinedSlots,
    required this.totalSlots,
  });

  @override
  _PoolJoinPageState createState() => _PoolJoinPageState();
}

class _PoolJoinPageState extends State<PoolJoinPage> {
  int _newJoinedSlots = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join ${widget.poolName} Pool'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pool Name: ${widget.poolName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Joined Slots: $_newJoinedSlots of ${widget.totalSlots}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Perform join operation
                int newJoinedSlots = widget.joinedSlots + 1;

                try {
                  String poolType = '';
                  if (widget.poolIndex == 0) {
                    poolType = 'Mega';
                  } else if (widget.poolIndex == 1) {
                    poolType = 'Large';
                  } else if (widget.poolIndex == 2) {
                    poolType = 'Mini';
                  }

                  await FirebaseFirestore.instance
                      .collection('Pool')
                      .doc('${widget.matchId}_$poolType')
                      .set({
                    'joined_slots': newJoinedSlots,
                  }, SetOptions(merge: true));

                  print('Updated joined slots for $poolType pool in Firestore');

                  // Set _newJoinedSlots for display
                  setState(() {
                    _newJoinedSlots = newJoinedSlots;
                  });

                  // Return updated joinedSlots to previous page
                  Navigator.pop(context, _newJoinedSlots);
                } catch (e) {
                  print('Error updating joined slots: $e');
                }
              },
              child: Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
