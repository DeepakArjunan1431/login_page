import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_page/Screens/crickettabs/PoolJoinPage.dart';

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
    _initializePools();
    _fetchMaxSlotsForPools();
  }

  Future<void> _initializePools() async {
    await FirebaseFirestore.instance.collection('Pool').doc('Pool').set({
      'max_size': 100,
      'matches': {}
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('Pool').doc('LargePool').set({
      'max_size': 50,
      'matches': {}
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('Pool').doc('MiniPool').set({
      'max_size': 25,
      'matches': {}
    }, SetOptions(merge: true));
  }

 Future<void> _fetchMaxSlotsForPools() async {
  try {
    List<String> poolDocs = ['Pool', 'LargePool', 'MiniPool'];
    List<Map<String, dynamic>> fetchedPools = [];

    for (String poolDoc in poolDocs) {
      DocumentSnapshot poolSnapshot = await FirebaseFirestore.instance
          .collection('Pool')
          .doc(poolDoc)
          .get();

      Map<String, dynamic> data = poolSnapshot.data() as Map<String, dynamic>;
      
      String poolType;
      if (poolDoc == 'Pool') poolType = 'Mega Pool';
      else if (poolDoc == 'LargePool') poolType = 'Large Pool';
      else poolType = 'Mini Pool';

      var matchData = data['matches']?[widget.matchId];
      
      if (matchData is Map) {
        matchData.forEach((poolName, poolData) {
          fetchedPools.add({
            'name': poolName,
            'joinedSlots': poolData['slots'] ?? 0,
            'totalSlots': data['max_size'] ?? 0,
            'type': poolType,
          });
        });
      } else {
        // If no pools exist for this match, create the first one
        fetchedPools.add({
          'name': '$poolType 1',
          'joinedSlots': 0,
          'totalSlots': data['max_size'] ?? 0,
          'type': poolType,
        });
      }
    }

    // Sort pools by name to ensure they're in order
    fetchedPools.sort((a, b) => a['name'].compareTo(b['name']));

    setState(() {
      pools = fetchedPools;
    });
  } catch (e) {
    print('Error fetching pool data: $e');
  }
}
 Future<String> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user currently signed in');
    }
  }

void _navigateToJoinPool(int index) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => JoinPoolPage(
        poolName: pools[index]['name'],
        joinedSlots: pools[index]['joinedSlots'],
        totalSlots: pools[index]['totalSlots'],
      ),
    ),
  );

  if (result == true) {
    try {
      String userId = await getCurrentUserId();

      String poolDoc;
      if (pools[index]['type'] == 'Mega Pool') {
        poolDoc = 'Pool';
      } else if (pools[index]['type'] == 'Large Pool') {
        poolDoc = 'LargePool';
      } else if (pools[index]['type'] == 'Mini Pool') {
        poolDoc = 'MiniPool';
      } else {
        print('Unknown pool type');
        return;
      }

      // Check if the pool has reached its maximum capacity
      if (pools[index]['joinedSlots'] >= pools[index]['totalSlots']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This pool has reached its maximum capacity.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // If the pool is not full, proceed with joining
      await FirebaseFirestore.instance.collection('Pool').doc(poolDoc).set({
        'matches': {
          widget.matchId: {
            pools[index]['name']: {
              'slots': FieldValue.increment(1),
              'userJoins': {
                userId: FieldValue.increment(1)
              }
            }
          }
        }
      }, SetOptions(merge: true));

      setState(() {
        pools[index]['joinedSlots']++;
        if (pools[index]['joinedSlots'] == pools[index]['totalSlots']) {
          _createNewPool(pools[index]['type']);
        }
      });

    } catch (e) {
      print('Error updating Firebase: $e');
      // You might want to show an error message to the user here
    }
  }
}
  void _createNewPool(String poolType) {
  int newIndex = pools.where((pool) => pool['type'] == poolType).length + 1;
  String newPoolName = '$poolType $newIndex';
  int totalSlots = pools.firstWhere((pool) => pool['type'] == poolType)['totalSlots'];

  setState(() {
    pools.add({
      'name': newPoolName,
      'joinedSlots': 0,
      'totalSlots': totalSlots,
      'type': poolType,
    });
    // Sort pools to ensure they're in order
    pools.sort((a, b) => a['name'].compareTo(b['name']));
  });

  // Create the new pool in Firestore
  String poolDoc;
  if (poolType == 'Mega Pool') {
    poolDoc = 'Pool';
  } else if (poolType == 'Large Pool') {
    poolDoc = 'LargePool';
  } else {
    poolDoc = 'MiniPool';
  }

  FirebaseFirestore.instance.collection('Pool').doc(poolDoc).set({
    'matches': {
      widget.matchId: {
        newPoolName: {
          'slots': 0,
          'userJoins': {}
        }
      }
    }
  }, SetOptions(merge: true));
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
                        onPressed: () => _navigateToJoinPool(index),
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