import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
// import 'firebase_options.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // Not needed if no Firebase init
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parcel Partner',
      theme: ThemeData.dark(),
      home: const LoginScreen(), // Set LoginScreen as the initial screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(), // Make sure this is SignUpScreen
      },
    );
  }
}


