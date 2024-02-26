import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/Reusable%20Widgets/reusable_widgets.dart';
import 'package:login_page/Screens/Sign_in.dart';
import 'package:login_page/utils/Colours.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Sign_in()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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
