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
  bool _obscurePassword = true; // Variable to toggle password visibility

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login function
  Future<void> _login() async {
    try {
      // Get the phone number and raw password
      String phone = _phoneController.text.trim();
      String password = _passwordController.text.trim();

      // Sign the user in using Firebase Auth (pseudo email from phone)
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: '$phone@mechswift.com', // phone number as pseudo email
        password: password, // raw password for Firebase auth
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
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword; // Toggle password visibility
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword, // Use the variable to hide/show password
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
