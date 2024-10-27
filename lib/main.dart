import 'package:flutter/material.dart';
import 'screens/login_screen.dart';  // Correct path
import 'screens/signup_screen.dart'; // Correct path
import 'screens/dashboard_screen.dart'; // Correct path
import 'screens/sign_up_mech.dart'; 
import 'screens/available_mechanics_screen.dart'; // Import the screen
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MechSwiftApp());
}

class MechSwiftApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechSwift',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/available-mechanics': (context) => AvailableMechanicsScreen(),
        '/sign_up_mech': (context) {
          // Get the current user
          final user = FirebaseAuth.instance.currentUser;
          
          // Check if the user is logged in
          if (user != null) {
            // Pass the user ID to SignUpMechScreen
            return SignUpMechScreen(userId: user.uid);
          } else {
            // Handle case where user is not logged in
            return LoginScreen(); // Navigate to login screen if not logged in
          }
        },
      },
    );
  }
}
