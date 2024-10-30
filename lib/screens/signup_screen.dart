import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

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
  bool _obscurePassword = true;
  bool _isSignUpEnabled = true; // Track if sign-up button is enabled
  int _countdown = 0; // Countdown timer variable

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Increment MechCoins for the currently logged-in user
  Future<void> incrementMechCoins(String userId) async {
    try {
      DocumentReference userDoc = _firestore.collection('cars').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        await userDoc.update({
          'mechCoins': FieldValue.increment(1),
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

  // Get current location and convert it to a readable address
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location services are disabled.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location permission denied.")),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      String readableAddress =
          "${place.street}, ${place.locality}, ${place.country}";
      _addressController.text = readableAddress;
    } catch (e) {
      print("Error getting location: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: ${e.toString()}")),
      );
    }
  }

  // Countdown timer for the "Sign Up" button
  void _startCountdown() {
    setState(() {
      _isSignUpEnabled = false;
      _countdown = 10;
    });

    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isSignUpEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  // Sign up function
  Future<void> _signUp() async {
    if (_isSignUpEnabled) {
      _startCountdown();
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _phoneController.text.trim() + '@mechswift.com',
          password: _passwordController.text.trim(),
        );

        String userId = userCredential.user!.uid;

        await _firestore.collection('cars').doc(userId).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'carModel': _carModelController.text.trim(),
          'mechCoins': 0,
        });

        User? currentUser = _auth.currentUser;
        String loggedInUserId = currentUser!.uid;
        await incrementMechCoins(loggedInUserId);

        Navigator.pushReplacementNamed(context, '/dashboard');
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: "Address"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),
              TextField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: "Car Model"),
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
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSignUpEnabled ? _signUp : null,
                child: _isSignUpEnabled
                    ? Text("Sign Up")
                    : Text("Wait $_countdown seconds"),
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
