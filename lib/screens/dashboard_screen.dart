import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _mechCoins = 0; // Variable to hold Mech Coins
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to access Scaffold state

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
      key: _scaffoldKey, // Assigning the GlobalKey to Scaffold
      appBar: AppBar(
        title: Text('Dashboard'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the sidebar
          },
        ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'MechSwift Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Update User Information'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/update-user'); // Navigate to update user screen
              },
            ),
          ],
        ),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                // Display Mech Coins with a cinematic card view and onTap to navigate
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/mechcoins_trade_store'); // Navigate to MechCoins Trade Store
                  },
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.blueAccent, // Card background color
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Your Mech Coins",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "$_mechCoins",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
