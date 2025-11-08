import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/points_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parcel Partner',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/points': (context) => const PointsScreen(),
      },
    );
  }
}
