import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // Variable to toggle password visibility
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> savedPhoneNumbers = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPhoneNumbers(); // Load saved phone numbers
  }

  Future<void> _loadSavedPhoneNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPhoneNumbers = prefs.getStringList('saved_phone_numbers') ?? [];
    });
  }

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

      // Save phone number to preferences if not already saved
      if (!savedPhoneNumbers.contains(phone)) {
        savedPhoneNumbers.add(phone);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('saved_phone_numbers', savedPhoneNumbers);
      }

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
      body: SingleChildScrollView( // Enable scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // Align elements to the left
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2), // Add space at the top
              Text(
                "Welcome to MechSwift",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16), // Add space between text and fields
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
              ),
              SizedBox(height: 16), // Add space between fields
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
              SizedBox(height: 20),
              // Display saved phone numbers in a modern style
              Text("Saved Phone Numbers:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              // Display saved phone numbers in a list
              ListView.builder(
                itemCount: savedPhoneNumbers.length,
                shrinkWrap: true, // Use shrinkWrap to fit the ListView height
                physics: NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    elevation: 4, // Shadow effect for modern look
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: ListTile(
                      title: Text(savedPhoneNumbers[index]),
                      trailing: Icon(Icons.arrow_forward, color: Colors.blue),
                      onTap: () {
                        _phoneController.text = savedPhoneNumbers[index]; // Autofill phone number
                      },
                    ),
                  );
                },
              ),
            ],
          ),
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
