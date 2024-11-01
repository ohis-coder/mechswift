import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AvailableMechanicsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Mechanics'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No mechanics available"));
          }

          final mechanics = snapshot.data!.docs;

          return ListView.builder(
            itemCount: mechanics.length,
            itemBuilder: (context, index) {
              var mechanic = mechanics[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    mechanic['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Address: ${mechanic['address']}', style: TextStyle(color: Colors.grey[700])),
                      Text('Phone: ${mechanic['phone']}', style: TextStyle(color: Colors.grey[700])),
                      Text('Specialty: ${mechanic['specialty']}', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _callMechanic(context, mechanic['phone']);
                    },
                    child: Text('Call'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _callMechanic(BuildContext context, String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      // Show a snackbar if the number is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not launch $phoneNumber. Please check the number."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
