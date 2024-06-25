import 'package:flutter/material.dart';

class JoinPage extends StatelessWidget {
  final VoidCallback onPressed;

  JoinPage({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text('Join'),
        ),
      ),
    );
  }
}
