import 'package:flutter/material.dart';
import 'screens/login_screen.dart';  // Correct path
import 'screens/signup_screen.dart'; // Correct path
import 'screens/dashboard_screen.dart'; // Correct path
import 'screens/available_mechanics_screen.dart'; // Import the screen
import 'package:firebase_core/firebase_core.dart';


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
      },
    );
  }
}
