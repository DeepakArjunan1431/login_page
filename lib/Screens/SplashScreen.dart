import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_page/Reusable%20Widgets/reusable_widgets.dart';
import 'package:login_page/Screens/Home_Screen.dart';
import 'package:login_page/Screens/Sign_in.dart';
import 'package:login_page/utils/Colours.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // Delay for 3 seconds before checking authentication
    Future.delayed(const Duration(seconds: 3), () {
      // Check authentication state
      checkAuthentication();
    });
  }

  void checkAuthentication() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      // User is not signed in, navigate to sign-in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Sign_in(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // Your existing UI code
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringtoColor("FFD180"), // Light orange at the top
              hexStringtoColor("FFE5C4"), // Light skin color at the bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoWidget("assets/images/app-store.png"),
            const SizedBox(
              height: 50,
            ),
            Text(
              'Forsae',
              style: TextStyle(color: Colors.black, fontSize: 35),
            )
          ],
        ),
      ),
    );
  }
}
