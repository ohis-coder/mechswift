import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        leading: null, // This removes the default back arrow
        automaticallyImplyLeading: false, // Ensures no back arrow is added
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Use the logout icon
            onPressed: () {
              // Handle logout action
              // For example, navigate back to the login screen
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to MechSwift Dashboard"),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/available-mechanics'); // Handle "Find Nearby Mechanics"
              },
              child: Text("Find Nearby Mechanics"),
            ),
          ],
        ),
      ),
    );
  }
}
