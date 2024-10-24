import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Address"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle sign-up logic here
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
