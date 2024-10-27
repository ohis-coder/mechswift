import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _mechCoins = 0; // Variable to hold Mech Coins

  // Stream to listen to MechCoins changes from the cars collection
  Stream<DocumentSnapshot> _mechCoinsStream() {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      // Fetch the document from the cars collection using the user ID
      return FirebaseFirestore.instance.collection('cars').doc(user.uid).snapshots();
    }
    return Stream.empty(); // Return an empty stream if no user is logged in
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the user
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _mechCoinsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading indicator while waiting for data
            }

            if (snapshot.hasError) {
              return Text("Error fetching Mech Coins.");
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text("User document does not exist in the cars collection.");
            }

            // Get MechCoins from the snapshot
            _mechCoins = (snapshot.data!.data() as Map<String, dynamic>)['mechCoins'] ?? 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to MechSwift Dashboard",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                // Display Mech Coins
                Text(
                  "Mech Coins: $_mechCoins", 
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/available-mechanics'); // Navigate to nearby mechanics screen
                  },
                  child: Text("Find Nearby Mechanics"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign_up_mech'); // Navigate to sign-up screen for registering mechanics
                  },
                  child: Text("Register a Mechanic and Earn Mech Coins"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
