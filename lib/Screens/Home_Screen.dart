import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_page/Screens/crickettabs/Livematches.dart';
import 'package:login_page/Screens/crickettabs/Recentmatches.dart';
import 'package:login_page/Screens/crickettabs/Upcomingmatches.dart';
import 'package:login_page/Screens/profileScreen.dart';

// import 'package:flutter/material.dart';

// import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import SystemNavigator

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
        body: WillPopScope(
          onWillPop: () async {
            return await _showQuitConfirmationDialog(context);
          },
          child: Column(
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
      ),
    );
  }

  Future<bool> _showQuitConfirmationDialog(BuildContext context) async {
    final bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuitConfirmationDialog();
      },
    );

    if (result != null && result) {
      // Exit the application
      SystemNavigator.pop();
    }
    return result ?? false;
  }
}

class QuitConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quit Application'),
      content: Text('Are you sure you want to quit the application?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(false); // Dismiss the dialog and return false
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(true); // Dismiss the dialog and return true
          },
          child: Text('Quit'),
        ),
      ],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
