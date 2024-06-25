import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchDetailsPage extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final String matchId;

  MatchDetailsPage({
    required this.team1Name,
    required this.team2Name,
    required this.matchId,
  });

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  List<Map<String, dynamic>> pools = [];

  @override
  void initState() {
    super.initState();
    _fetchMaxSlotsForPools();
  }

  Future<void> _fetchMaxSlotsForPools() async {
    try {
      // Fetch max slots for Mega Pool
      DocumentSnapshot megaPoolSnapshot = await FirebaseFirestore.instance
          .collection('Pool')
          .doc('Pool') // Replace with your actual document name for Mega Pool
          .get();

      // Fetch max slots for Large Pool
      DocumentSnapshot largePoolSnapshot = await FirebaseFirestore.instance
          .collection('Pool')
          .doc('LargePool') // Replace with your actual document name for Large Pool
          .get();

      // Fetch max slots for Mini Pool
      DocumentSnapshot miniPoolSnapshot = await FirebaseFirestore.instance
          .collection('Pool')
          .doc('MiniPool') // Replace with your actual document name for Mini Pool
          .get();

      setState(() {
        pools = [
          {
            'name': 'Mega Pool 1',
            'joinedSlots': 0,
            'totalSlots': megaPoolSnapshot['max_size'] ?? 0,
            'nextPoolCreated': false, // Add flag for Mega Pool
          },
          {
            'name': 'Large Pool 1',
            'joinedSlots': 0,
            'totalSlots': largePoolSnapshot['max_size'] ?? 0,
            'nextPoolCreated': false, // Add flag for Large Pool
          },
          {
            'name': 'Mini Pool 1',
            'joinedSlots': 0,
            'totalSlots': miniPoolSnapshot['max_size'] ?? 0,
            'nextPoolCreated': false, // Add flag for Mini Pool
          },
        ];
      });
    } catch (e) {
      print('Error fetching max slots for pools: $e');
    }
  }

  void _handleJoinPressed(int index) {
    setState(() {
      int joinedSlots = pools[index]['joinedSlots'];
      int totalSlots = pools[index]['totalSlots'];

      if (joinedSlots < totalSlots) {
        pools[index]['joinedSlots'] += 1;
      } else {
        // Only create a new pool if it hasn't been created for the current pool
        if (!pools[index].containsKey('nextPoolCreated') || !pools[index]['nextPoolCreated']) {
          _createNewPool(index);
          pools[index]['nextPoolCreated'] = true;
        }
      }
    });
  }

  void _createNewPool(int index) {
    int newTotalSlots = pools[index]['totalSlots']; // Set total slots for the new pool
    String newPoolName = '';
    int newIndex = 0;

    String currentPoolName = pools[index]['name'];
    if (currentPoolName.startsWith('Mega Pool')) {
      newIndex = pools.where((pool) => pool['name'].startsWith('Mega Pool')).length + 1;
      newPoolName = 'Mega Pool $newIndex';
    } else if (currentPoolName.startsWith('Large Pool')) {
      newIndex = pools.where((pool) => pool['name'].startsWith('Large Pool')).length + 1;
      newPoolName = 'Large Pool $newIndex';
    } else if (currentPoolName.startsWith('Mini Pool')) {
      newIndex = pools.where((pool) => pool['name'].startsWith('Mini Pool')).length + 1;
      newPoolName = 'Mini Pool $newIndex';
    }

    // Debugging print statements
    print('Creating new pool...');
    print('Index: $index');
    print('New Index: $newIndex');
    print('New Pool Name: $newPoolName');

    setState(() {
      pools.add({
        'name': newPoolName,
        'joinedSlots': 0,
        'totalSlots': newTotalSlots,
        'nextPoolCreated': false, // Flag to ensure next pool is created only once
      });
      print('New pool added to the list: $newPoolName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE5C4), Color(0xFFFFD180)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,

                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.team1Name} vs ${widget.team2Name}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                        // SizedBox(height: 8.0),
                        // Text(
                        //   'Match ID: ${widget.matchId}',
                        //   style: TextStyle(
                        //     fontFamily: 'Roboto',
                        //     fontSize: 16.0,
                        //     color: Colors.white,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: pools.length,
        itemBuilder: (context, index) {
          String poolName = pools[index]['name'];
          int joinedSlots = pools[index]['joinedSlots'];
          int totalSlots = pools[index]['totalSlots'];
          double progressValue = totalSlots != 0 ? joinedSlots / totalSlots : 0.0;

          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poolName,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$joinedSlots of $totalSlots slots joined',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.0,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _handleJoinPressed(index),
                        child: Text(
                          'Join',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFE5C4)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}