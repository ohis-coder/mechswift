import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _carModelController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to increment MechCoins for the currently logged-in user
  Future<void> incrementMechCoins(String userId) async {
    try {
      DocumentReference userDoc = _firestore.collection('cars').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        await userDoc.update({
          'mechCoins': FieldValue.increment(1), // Increment by 1
        });
      } else {
        print("User document not found.");
      }
    } catch (e) {
      print("Error updating mechCoins: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating mechCoins: ${e.toString()}")),
      );
    }
  }

  // Sign up function
  Future<void> _signUp() async {
    try {
      // Create a new user using Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _phoneController.text.trim() + '@mechswift.com', // using phone as pseudo email
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid; // Get new user's ID

      // Store additional user data in Firestore under "cars" collection
      await _firestore.collection('cars').doc(userId).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'carModel': _carModelController.text.trim(),
        'mechCoins': 0, // Initialize mechCoins in the new user's document
      });

      // Get the currently logged-in user's ID
      User? currentUser = _auth.currentUser;
      String loggedInUserId = currentUser!.uid; // Get logged-in user ID

      // Increment mechCoins for the logged-in user
      await incrementMechCoins(loggedInUserId); // Increment mechCoins for the logged-in user

      // Navigate to the dashboard after successful sign-up
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print(e); // Handle errors (display to user if needed)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        // Removed the leading back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address"),
              ),
              TextField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: "Car Model"),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp, // Trigger the sign-up process
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _carModelController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
