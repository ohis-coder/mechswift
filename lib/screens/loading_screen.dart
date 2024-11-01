import 'package:flutter/material.dart';
import 'package:mechswift/screens/login_screen.dart'; // Make sure to import your login screen

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to the login screen after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/mechswift_logo.png', // Change this to your MechSwift logo path
              height: 200, // Adjust size as needed
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // Set loading indicator color to black
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
