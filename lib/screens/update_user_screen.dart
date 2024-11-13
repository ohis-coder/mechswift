import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_screen.dart'; // Import the Dashboard screen

class UpdateUserScreen extends StatefulWidget {
  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _carMakeController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carYearController = TextEditingController();
  final TextEditingController _carVinController = TextEditingController(); // Optional VIN

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get current location and convert to address
  Future<void> _getCurrentAddress() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // Permissions denied
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _addressController.text =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      } else {
        _addressController.text = 'Address not found';
      }

      setState(() {});
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  // Method to save updates to Firestore
  Future<void> _saveChanges() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('cars').doc(user.uid).update({
          'phone': _phoneController.text,
          'address': _addressController.text,
          'car_details': {
            'make': _carMakeController.text.trim(),
            'model': _carModelController.text.trim(),
            'year': _carYearController.text.trim(),
            'vin': _carVinController.text.trim() // Optional VIN
          },
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Information updated successfully')),
        );

        // Navigate back to the Dashboard screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    } catch (e) {
      print("Failed to save updates: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: _getCurrentAddress,
                  ),
                ),
              ),
              TextField(
                controller: _carMakeController,
                decoration: InputDecoration(labelText: 'Car Make'),
              ),
              TextField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: 'Car Model'),
              ),
              TextField(
                controller: _carYearController,
                decoration: InputDecoration(labelText: 'Car Year'),
              ),
              TextField(
                controller: _carVinController,
                decoration: InputDecoration(labelText: 'VIN (Optional)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
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
    _addressController.dispose();
    _carMakeController.dispose();
    _carModelController.dispose();
    _carYearController.dispose();
    _carVinController.dispose();
    super.dispose();
  }
}
