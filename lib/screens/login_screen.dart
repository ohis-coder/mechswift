import 'dart:convert'; // For utf8.encode
import 'package:crypto/crypto.dart'; // For sha256 hashing
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login function
  Future<void> _login() async {
    try {
      // Get the phone number and hash the password
      String phone = _phoneController.text.trim();
      String hashedPassword = _hashPassword(_passwordController.text.trim());

      // Fetch user details from Firestore 'cars' collection
      QuerySnapshot snapshot = await _firestore.collection('cars')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("User not found");
      }

      var userData = snapshot.docs.first.data() as Map<String, dynamic>;

      // Check if the hashed password matches the one in Firestore
      if (userData['password'] != hashedPassword) {
        throw Exception("Incorrect password");
      }

      // Sign the user in using Firebase Auth (pseudo email from phone)
      await _auth.signInWithEmailAndPassword(
        email: '$phone@mechswift.com', // phone number as pseudo email
        password: _passwordController.text.trim(), // raw password for Firebase auth
      );

      // Navigate to the dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to MechSwift",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login, // Handle login logic here
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
