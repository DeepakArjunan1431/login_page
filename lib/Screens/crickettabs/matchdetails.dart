import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_page/Screens/crickettabs/PoolJoinPage.dart';

class MatchDetailsPage extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final String matchId;
  final int teamId1;
  final int teamId2;

  MatchDetailsPage({
    required this.team1Name,
    required this.team2Name,
    required this.matchId,
     required this.teamId1,
    required this.teamId2,
  });

  @override
  _MatchDetailsPageState createState() {
    print('Creating MatchDetailsPage state with matchId: $matchId');
    return _MatchDetailsPageState();
  }
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  List<Map<String, dynamic>> pools = [];

  @override
  void initState() {
    super.initState();
    print('Initializing MatchDetailsPage state with matchId: ${widget.matchId}');
    print('Initializing MatchDetailsPage state with matchId: ${widget.matchId}');
  print('TeamId1: ${widget.teamId1}');
  print('TeamId2: ${widget.teamId2}');
    _initializePools();
    _fetchMaxSlotsForPools();
  }

  Future<void> _initializePools() async {
    try {
      List<String> poolTypes = ['Pool', 'LargePool', 'MiniPool'];

      for (String poolType in poolTypes) {
        DocumentSnapshot poolDoc = await FirebaseFirestore.instance.collection('Pool').doc(poolType).get();

        if (!poolDoc.exists) {
          print('Creating new pool document for $poolType');
          await FirebaseFirestore.instance.collection('Pool').doc(poolType).set({
            'max_size': _getMaxSizeForPoolType(poolType),
            'matches': {}
          });
        }

        Map<String, dynamic> existingData = poolDoc.data() as Map<String, dynamic>? ?? {};
        Map<String, dynamic> matches = existingData['matches'] ?? {};

        matches[widget.matchId] = {
          ...matches[widget.matchId] ?? {},
          'team1': widget.team1Name,
          'team2': widget.team2Name,
        };

        print('Ensuring match ${widget.matchId} exists in $poolType');
        await FirebaseFirestore.instance.collection('Pool').doc(poolType).set({
          'matches': matches,
        }, SetOptions(merge: true));
      }
    } catch (e, stackTrace) {
      print('Error initializing pools: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _fetchMaxSlotsForPools() async {
    print('Fetching max slots for pools. MatchId: ${widget.matchId}');
    try {
      List<String> poolDocs = ['Pool', 'LargePool', 'MiniPool'];
      List<Map<String, dynamic>> fetchedPools = [];

      for (String poolDoc in poolDocs) {
        DocumentSnapshot poolSnapshot = await FirebaseFirestore.instance
            .collection('Pool')
            .doc(poolDoc)
            .get();

        if (!poolSnapshot.exists) {
          print('Pool document $poolDoc does not exist');
          continue;
        }

        Map<String, dynamic> data = poolSnapshot.data() as Map<String, dynamic>;

        String poolType = _getPoolTypeName(poolDoc);
        int maxSize = _getMaxSizeForPoolType(poolDoc);

        if (!data.containsKey('matches')) {
          print('Matches key not found in $poolDoc');
          continue;
        }

        Map<String, dynamic> matchData = data['matches'][widget.matchId] ?? {};
        print('Raw match data for ${widget.matchId} in $poolDoc: $matchData');

        List<Map<String, dynamic>> poolsOfType = [];

        if (matchData.isNotEmpty) {
          matchData.forEach((poolName, poolData) {
            if (poolName != 'team1' && poolName != 'team2') {
              print('Raw pool data for $poolName: $poolData');
              int joinedSlots = 0;
              if (poolData is Map && poolData.containsKey('slots')) {
                var slots = poolData['slots'];
                if (slots is int) {
                  joinedSlots = slots;
                } else if (slots is String) {
                  joinedSlots = int.tryParse(slots) ?? 0;
                } else {
                  print('Unexpected type for slots: ${slots.runtimeType}');
                }
              }
              // Only add pools that are not full
              if (joinedSlots < maxSize) {
                poolsOfType.add({
                  'name': poolName,
                  'joinedSlots': joinedSlots,
                  'totalSlots': maxSize,
                  'type': poolType,
                });
              }
            }
          });
        }

        // If no pools of this type or all are full, create a new one
        if (poolsOfType.isEmpty) {
          int newIndex = (matchData.keys.where((k) => k.startsWith(poolType)).length + 1);
          String newPoolName = '$poolType $newIndex';
          poolsOfType.add({
            'name': newPoolName,
            'joinedSlots': 0,
            'totalSlots': maxSize,
            'type': poolType,
          });

          // Create the new pool in Firestore
          await FirebaseFirestore.instance.collection('Pool').doc(poolDoc).set({
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

        fetchedPools.addAll(poolsOfType);
      }

      fetchedPools.sort((a, b) => a['name'].compareTo(b['name']));

      setState(() {
        pools = fetchedPools;
      });

      print('Fetched pools: $fetchedPools');

    } catch (e, stackTrace) {
      print('Error fetching pool data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  int _getMaxSizeForPoolType(String poolType) {
    switch (poolType) {
      case 'Pool':
        return 100;
      case 'LargePool':
        return 50;
      case 'MiniPool':
        return 25;
      default:
        return 0;
    }
  }

  String _getPoolTypeName(String poolType) {
    switch (poolType) {
      case 'Pool':
        return 'Mega Pool';
      case 'LargePool':
        return 'Large Pool';
      case 'MiniPool':
        return 'Mini Pool';
      default:
        return '';
    }
  }

  String _getPoolDocName(String poolType) {
    switch (poolType) {
      case 'Mega Pool':
        return 'Pool';
      case 'Large Pool':
        return 'LargePool';
      case 'Mini Pool':
        return 'MiniPool';
      default:
        return '';
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

  void _navigateToJoinPool(String poolName, int joinedSlots, int totalSlots, String poolType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinPoolPage(
          poolName: poolName,
          joinedSlots: joinedSlots,
          totalSlots: totalSlots,
          matchId: widget.matchId,   // Pass matchId to JoinPoolPage
          teamId1: widget.teamId1,   // Pass teamId1 to JoinPoolPage
          teamId2: widget.teamId2,   // Pass teamId2 to JoinPoolPage

        ),
      ),
    );

    if (result == true) {
      try {
        String userId = await getCurrentUserId();
        String poolDoc = _getPoolDocName(poolType);

        if (joinedSlots >= totalSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This pool has reached its maximum capacity.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('Pool').doc(poolDoc).set({
          'matches': {
            widget.matchId: {
              poolName: {
                'slots': FieldValue.increment(1),
                'userJoins': {
                  userId: FieldValue.increment(1)
                }
              }
            }
          }
        }, SetOptions(merge: true));

        // Refresh the pools data, which will hide full pools and create new ones if needed
        await _fetchMaxSlotsForPools();

      } catch (e) {
        print('Error updating Firebase: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building MatchDetailsPage with matchId: ${widget.matchId}');
    
    // Group pools by type
    Map<String, List<Map<String, dynamic>>> groupedPools = {};
    for (var pool in pools) {
      if (!groupedPools.containsKey(pool['type'])) {
        groupedPools[pool['type']] = [];
      }
      groupedPools[pool['type']]!.add(pool);
    }

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
        itemCount: groupedPools.length,
        itemBuilder: (context, index) {
          String poolType = groupedPools.keys.elementAt(index);
          List<Map<String, dynamic>> poolsOfType = groupedPools[poolType]!;
          int totalJoinedSlots = poolsOfType.fold<int>(0, (sum, pool) {
            int slots = pool['joinedSlots'] is int ? pool['joinedSlots'] : int.parse(pool['joinedSlots'].toString());
            return sum + slots;
          });

          int totalSlots = poolsOfType.fold<int>(0, (sum, pool) {
            int slots = pool['totalSlots'] is int ? pool['totalSlots'] : int.parse(pool['totalSlots'].toString());
            return sum + slots;
          });

          double progressValue = totalSlots != 0 ? totalJoinedSlots / totalSlots : 0.0;

          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poolType,
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
                        '$totalJoinedSlots of $totalSlots slots joined',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.0,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToJoinPool(
                          poolsOfType[0]['name'],  // Use the first available pool of this type
                          poolsOfType[0]['joinedSlots'],
                          poolsOfType[0]['totalSlots'],
                          poolType,
                        ),
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
