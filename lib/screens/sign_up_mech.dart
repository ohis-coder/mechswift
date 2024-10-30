import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:geolocator/geolocator.dart'; // Import geolocator package

class SignUpMechScreen extends StatefulWidget {
  final String userId;

  SignUpMechScreen({required this.userId});

  @override
  _SignUpMechScreenState createState() => _SignUpMechScreenState();
}

class _SignUpMechScreenState extends State<SignUpMechScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a random password
  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
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
      ).timeout(Duration(seconds: 10)); // Add timeout

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      String readableAddress = "${place.street}, ${place.locality}, ${place.country}";
      _addressController.text = readableAddress;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: ${e.toString()}")),
      );
    }
  }

  // Pick an image from gallery or take a photo
  Future<void> _pickImage() async {
    final pickedSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Image Source"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text("Camera"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text("Gallery"),
          ),
        ],
      ),
    );

    if (pickedSource != null) {
      final pickedFile = await _picker.pickImage(source: pickedSource);
      if (pickedFile != null) {
        setState(() {
          _imageUrl = pickedFile.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No image selected.")),
        );
      }
    }
  }

  Future<void> _registerMechanic() async {
    try {
      String name = _nameController.text.trim();
      String address = _addressController.text.trim();
      String phone = _phoneController.text.trim();
      String specialty = _specialtyController.text.trim();

      if (name.isEmpty || address.isEmpty || phone.isEmpty || specialty.isEmpty || _imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill out all fields and select an image")),
        );
        return;
      }

      // Generate random password for the mechanic
      String randomPassword = _generateRandomPassword();

      // Add mechanic to 'users' collection
      DocumentReference mechanicRef = await _firestore.collection('users').add({
        'name': name,
        'address': address,
        'image_url': _imageUrl,
        'phone': phone,
        'specialty': specialty,
        'mechCoins': 0,
        'password': randomPassword,
      });

      // Award Mech Coins to the user who registered the mechanic (increase by 1)
      if (widget.userId.isNotEmpty) {
        DocumentSnapshot userDoc = await _firestore.collection('cars').doc(widget.userId).get();
        if (userDoc.exists) {
          await _firestore.collection('cars').doc(widget.userId).update({
            'mechCoins': FieldValue.increment(1),
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User ID does not correspond to an existing document.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User ID is not valid.")),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mechanic registered and Mech Coins awarded!")),
      );

      // Clear form fields after successful registration
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _specialtyController.clear();
      setState(() {
        _imageUrl = null;
      });

      Navigator.pop(context);
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
      appBar: AppBar(
        title: Text("Register a Mechanic"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextButton(
              onPressed: _pickImage,
              child: Text("Select Image from Gallery or Take a Photo"),
            ),
            if (_imageUrl != null)
              ClipOval(
                child: Image.file(
                  File(_imageUrl!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Mechanic's Name"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: "Mechanic's Address"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Mechanic's Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _specialtyController,
              decoration: InputDecoration(labelText: "Mechanic's Specialty"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerMechanic,
              child: Text("Register Mechanic"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }
}
