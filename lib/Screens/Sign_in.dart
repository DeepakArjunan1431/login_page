import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/Screens/Home_Screen.dart';
import 'package:login_page/Screens/Sign_up.dart';
import 'package:login_page/Screens/reset_password.dart';
import 'package:login_page/utils/Colours.dart';
import 'package:login_page/Reusable%20Widgets/reusable_widgets.dart';

class Sign_in extends StatefulWidget {
  const Sign_in({Key? key});

  @override
  State<Sign_in> createState() => _Sign_inState();
}

class _Sign_inState extends State<Sign_in> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if user is already signed in
    // checkCurrentUser();
  }

  void checkCurrentUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showQuitConfirmationDialog,
      child: Scaffold(
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
                children: <Widget>[
                  LogoWidget("assets/images/app-store.png"),
                  const SizedBox(
                    height: 30,
                  ),
                  reusableTextField("Enter UserName", Icons.person_outline,
                      false, _emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter Password", Icons.lock_outline, true,
                      _passwordTextController),
                  const SizedBox(
                    height: 5,
                  ),
                  forgetPassword(context),
                  firebaseUIButton(context, true, () {
                    return FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    )
                        .then((value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                    });
                  }),
                  signUpOption(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showQuitConfirmationDialog() async {
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

Row signUpOption(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have account?", style: TextStyle(color: Colors.black)),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context as BuildContext, // Use the context directly
            MaterialPageRoute(builder: (context) => const Sign_up()),
          );
        },
        child: const Text(
          " Sign Up",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}

Widget forgetPassword(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 35,
    alignment: Alignment.bottomRight,
    child: TextButton(
      child: const Text(
        "Forgot Password?",
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.right,
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetPassword()),
      ),
    ),
  );
}

// void main() {
//   runApp(MaterialApp(
//     home: Sign_in(),
//   ));
// }

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
          // onPressed: ()
          //  {
          //   Navigator.of(context)
          //       .pop(true); // Dismiss the dialog and return true
          // },
          onPressed: () =>
              SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
          child: Text('Quit'),
        ),
      ],
    );
  }
}
