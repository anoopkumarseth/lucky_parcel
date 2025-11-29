import 'package:flutter/material.dart';
import 'package:lucky_parcel/features/auth/screens/login_screen.dart';
import 'package:lucky_parcel/features/auth/screens/signup_screen.dart';
import 'package:lucky_parcel/features/home/screens/welcome_screen.dart';
import 'package:lucky_parcel/features/orders/screens/orders_screen.dart';
import 'package:lucky_parcel/features/profile/screens/profile_screen.dart';
import 'package:lucky_parcel/features/rewards/screens/points_screen.dart';
import 'package:lucky_parcel/features/notifications/screens/notifications_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String welcome = '/welcome';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String points = '/points';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case points:
        return MaterialPageRoute(builder: (_) => const PointsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
