import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              var mechanic = mechanics[index].data() as Map<String, dynamic>; // Cast to map
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
                      _showBookingDialog(context, mechanic['name']);
                    },
                    child: Text('Book'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBookingDialog(BuildContext context, String mechanicName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book $mechanicName'),
          content: Text('Are you sure you want to book this mechanic?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showRatingDialog(context, mechanicName); // Open rating dialog after booking
              },
              child: Text('Book'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, String mechanicName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate $mechanicName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please leave a rating and review.'),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(hintText: 'Leave a comment'),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              DropdownButton<int>(
                value: 5, // Default rating
                onChanged: (newValue) {
                  // Handle rating change (can be stored in state)
                },
                items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value Stars'),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the rating dialog
                // Handle saving the review and rating (to Firestore or other backend)
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
