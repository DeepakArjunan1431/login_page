import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:login_page/Reusable%20Widgets/reusable_widgets.dart';
import 'package:login_page/Screens/SelectSport.dart';
import 'package:login_page/utils/Colours.dart';

class Sign_up extends StatefulWidget {
  const Sign_up({super.key});

  @override
  State<Sign_up> createState() => _Sign_upState();
}

class _Sign_upState extends State<Sign_up> {
  // final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _NameTextController = TextEditingController();
  late TextEditingController _passwordTextController;
  bool _isPasswordVisible = false;
  bool _showPasswordAlert = false;

  @override
  void initState() {
    super.initState();
    _passwordTextController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringtoColor("FFD180"), // Light orange at the top
            hexStringtoColor("FFE5C4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Name", Icons.person_rounded, false,
                    _NameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter UserName", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Enter Email Id", Icons.mail, false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                // reusableTextField("Enter Password", Icons.lock_outlined, true,
                //     _passwordTextController),
                // const SizedBox(
                //   height: 20,
                // ),
                TextField(
                  controller: _passwordTextController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.black.withOpacity(0.4),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
                            width: 0, style: BorderStyle.none)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _showPasswordAlert = value.length < 8;
                    });
                  },
                ),
                if (_showPasswordAlert)
                  const Text(
                    'Password must be at least 8 characters long',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Create user in Firebase Authentication
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text);

                      // Save user details to Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userCredential.user?.uid)
                          .set({
                        'username': _userNameTextController.text,
                        'email': _emailTextController.text,
                        'name': _NameTextController.text,
                      });

                      print("Created New Account");

                      // Navigate to HomeScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectSport(),
                        ),
                      );
                    } catch (e) {
                      print("Error $e");
                      // Handle errors
                    }
                  },
                  child: Text('Sign Up'),
                ),

                // firebaseUIButton(context, false, () async {
                //   try {
                //     // Create user in Firebase Authentication
                //     UserCredential userCredential = await FirebaseAuth.instance
                //         .createUserWithEmailAndPassword(
                //             email: _emailTextController.text,
                //             password: _passwordTextController.text);

                //     // Save user details to Firestore
                //     await FirebaseFirestore.instance
                //         .collection('users')
                //         .doc(userCredential.user?.uid)
                //         .set({
                //       'username': _userNameTextController.text,
                //       'email': _emailTextController.text,
                //       'name': _NameTextController.text,
                //     });

                //     print("Created New Account");

                //     // Navigate to HomeScreen
                //     // Navigator.pushReplacement(
                //     //   context,
                //     //   MaterialPageRoute(
                //     //     builder: (context) => SelectSport(),
                //     //   ),
                //     // );
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => const SelectSport()),
                //     );
                //   } catch (e) {
                //     print("Error $e");
                //     // Handle errors
                //   }
                // })
              ],
            ),
          ))),
    );
  }
}
