import 'package:flutter/material.dart';
import 'package:login_page/Reusable%20Widgets/reusable_widgets.dart';
import 'package:login_page/Screens/fanbase.dart';
import 'package:login_page/utils/Colours.dart';

class SelectSport extends StatefulWidget {
  const SelectSport({super.key});

  @override
  State<SelectSport> createState() => _SelectSportState();
}

class _SelectSportState extends State<SelectSport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: [
                LogoWidget("assets/images/app-store.png"),
                const SizedBox(
                  height: 50,
                ),
                Text("Select your Favourite Sports",
                    style: TextStyle(fontSize: 24, color: Colors.black)),
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TeamSelectionPage()),
                    );
                    // Handle tap on Cricket container
                    print('Cricket container tapped');
                  },
                  child: Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF8B0000),
                      borderRadius:
                          BorderRadius.circular(10), // Set border radius
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_cricket,
                          color: Colors.white,
                        ),
                        SizedBox(
                            width: 5), // Add some spacing between icon and text
                        Text(
                          'Cricket',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MyApp()),
                    // );
                    // Handle tap on Football container
                    print('Football container tapped');
                  },
                  child: Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF2f1b12),
                      borderRadius:
                          BorderRadius.circular(10), // Set border radius
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          color: Colors.white,
                        ),
                        SizedBox(
                            width: 5), // Add some spacing between icon and text
                        Text(
                          'Football',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
