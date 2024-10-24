import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:login_page/Screens/Sign_in.dart';
import 'package:login_page/Screens/SplashScreen.dart';
import 'package:login_page/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a loading indicator while Firebase initializes
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              // Handle error if Firebase initialization fails
              return Text('Error initializing Firebase');
            } else {
              // Check authentication state
              return SplashScreen(); // You may change this to your initial loading screen
            }
          }
        },
      ),
    );
  }
}
