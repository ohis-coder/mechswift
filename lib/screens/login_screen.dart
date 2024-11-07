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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center, // Align elements to center
            children: [
              SizedBox(height: 100), // Add space before the header
              Text(
                "Welcome to MechSwift",
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30), // Add space between text and fields
              _buildPhoneTextField(),
              SizedBox(height: 20), // Add space between fields
              _buildPasswordTextField(),
              SizedBox(height: 30), // Add space before button
              _buildLoginButton(),
              SizedBox(height: 20),
              _buildSignUpLink(),
              SizedBox(height: 30),
              _buildSavedPhoneNumbersTitle(),
              SizedBox(height: 10),
              _buildSavedPhoneNumbersList(),
            ],
          ),
        ),
      ),
    );
  }

  // Phone number input field
  Widget _buildPhoneTextField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: "Phone Number",
        labelStyle: TextStyle(),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  // Password input field
  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword; // Toggle password visibility
            });
          },
        ),
      ),
    );
  }

  // Login button
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 12.0),
        backgroundColor: Colors.blue, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text(
        "Login",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // Sign-up link
  Widget _buildSignUpLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: Text(
        "Don't have an account? Sign Up",
      ),
    );
  }

  // Title for saved phone numbers section
  Widget _buildSavedPhoneNumbersTitle() {
    return Text(
      "Saved Phone Numbers:",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // List of saved phone numbers
  Widget _buildSavedPhoneNumbersList() {
    return ListView.builder(
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
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              _phoneController.text = savedPhoneNumbers[index]; // Autofill phone number
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
