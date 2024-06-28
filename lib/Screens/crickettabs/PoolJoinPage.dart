import 'package:flutter/material.dart';

class JoinPoolPage extends StatelessWidget {
  final String poolName;
  final int joinedSlots;
  final int totalSlots;

  JoinPoolPage({
    required this.poolName,
    required this.joinedSlots,
    required this.totalSlots,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join $poolName'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Join $poolName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('$joinedSlots of $totalSlots slots joined'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (joinedSlots < totalSlots) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('This pool is full')),
                  );
                }
              },
              child: Text('Confirm Join'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFE5C4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
