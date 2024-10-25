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

  // Sign up function
  Future<void> _signUp() async {
    try {
      // Create a new user using Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _phoneController.text.trim() + '@mechswift.com', // using phone as pseudo email
        password: _passwordController.text.trim(),
      );

      // Store additional user data in Firestore under "cars" collection
      await _firestore.collection('cars').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'carModel': _carModelController.text.trim(),
      });

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
