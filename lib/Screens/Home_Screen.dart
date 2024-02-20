// import 'package:flutter/material.dart';
// import 'package:login_page/Screens/crickettabs/Livematches.dart';
// import 'package:login_page/Screens/crickettabs/Recentmatches.dart';
// import 'package:login_page/Screens/crickettabs/Upcomingmatches.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           child: const Text("Logout"),
//           onPressed: () {
//             FirebaseAuth.instance.signOut().then((value) {
//               print("Signed Out");
//               Navigator.push(
//                   context, MaterialPageRoute(builder: (context) => const Sign_in()));
//             });
//           },
//         ),
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//             title: const Text(
//               'FORESAY',
//             ),
//             centerTitle: true),
//         body: Column(
//           children: [
//             const TabBar(
//               tabs: [
//                 Tab(
//                   icon: Icon(
//                     Icons.home,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 Tab(
//                   icon: Icon(
//                     Icons.settings,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 Tab(
//                   icon: Icon(
//                     Icons.person,
//                     color: Colors.deepPurple,
//                   ),
//                 )
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   // 1st tab
//                   Livematches(),
//                   // 2nd tab
//                   Recentmatches(),
//                   // //3rd tab
//                   Upcomingmatches()
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'FORESAY',
//           ),
//           centerTitle: true,
//           leading: IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () {
//               FirebaseAuth.instance.signOut().then((value) {
//                 print("Signed Out");
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => Sign_in()),
//                 );
//               });
//             },
//           ),
//         ),
//         body: Column(
//           children: [
//             TabBar(
//               tabs: [
//                 Tab(
//                   icon: Icon(
//                     Icons.home,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 Tab(
//                   icon: Icon(
//                     Icons.settings,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 Tab(
//                   icon: Icon(
//                     Icons.person,
//                     color: Colors.deepPurple,
//                   ),
//                 )
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   // 1st tab
//                   Livematches(),
//                   // 2nd tab
//                   Recentmatches(),
//                   // //3rd tab
//                   Upcomingmatches()
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_page/Screens/crickettabs/Livematches.dart';
import 'package:login_page/Screens/crickettabs/Recentmatches.dart';
import 'package:login_page/Screens/crickettabs/Upcomingmatches.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'FORESAY',
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.home,
                    color: Colors.deepPurple,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.deepPurple,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.person,
                    color: Colors.deepPurple,
                  ),
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // 1st tab
                  Livematches(),
                  // 2nd tab
                  Recentmatches(),
                  // //3rd tab
                  Upcomingmatches()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class ProfileScreen extends StatefulWidget {
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   late User? _user;
//   late Map<String, dynamic> _userData = {};
//   bool _isLoading = true;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _user = FirebaseAuth.instance.currentUser;
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     for (var retryAttempt = 1; retryAttempt <= 3; retryAttempt++) {
//       try {
//         final userSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(_user!.uid)
//             .get();
//         final userData = userSnapshot.data() as Map<String, dynamic>?;
//         if (userData != null) {
//           setState(() {
//             _userData = userData;
//             _isLoading = false;
//           });
//           return;
//         }
//       } catch (e) {
//         print('Error fetching user data: $e');
//         if (retryAttempt < 3) {
//           await Future.delayed(Duration(seconds: retryAttempt * 2));
//           print('Retrying...');
//         } else {
//           setState(() {
//             _isLoading = false;
//             _hasError = true;
//           });
//           return;
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Profile'),
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     } else if (_hasError) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Profile'),
//         ),
//         body: Center(
//           child: Text('Error fetching user data. Please try again later.'),
//         ),
//       );
//     } else {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Profile'),
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('UID: ${_user!.uid}'),
//             Text('Username: ${_userData['username']}'),
//             Text('Email: ${_user!.email}'),
//           ],
//         ),
//       );
//     }
//   }
// }

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user;
  late Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    for (var retryAttempt = 1; retryAttempt <= 3; retryAttempt++) {
      try {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
        final userData = userSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            _userData = userData;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('Error fetching user data: $e');
        if (retryAttempt < 3) {
          await Future.delayed(Duration(seconds: retryAttempt * 2));
          print('Retrying...');
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Text('Error fetching user data. Please try again later.'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text('UID: ${_user!.uid}'), // Removed UID display
            Text('Username: ${_userData['username']}'),
            Text('Email: ${_user!.email}'),
          ],
        ),
      );
    }
  }
}
