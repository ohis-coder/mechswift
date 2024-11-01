import 'package:flutter/material.dart';
import 'screens/loading_screen.dart'; // Import the new loading screen
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sign_up_mech.dart';
import 'screens/available_mechanics_screen.dart';
import 'screens/mechcoins_trade_store_screen.dart'; // Import MechCoins Trade Store screen
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      home: LoadingScreen(), // Set LoadingScreen as the home screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/available-mechanics': (context) => AvailableMechanicsScreen(),
        '/sign_up_mech': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return SignUpMechScreen(userId: user.uid);
          } else {
            return LoginScreen();
          }
        },
        '/mechcoins_trade_store': (context) => MechCoinsTradeStoreScreen(), // Add the new route here
      },
    );
  }
}
