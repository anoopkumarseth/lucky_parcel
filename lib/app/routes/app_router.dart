import 'package:flutter/material.dart';
import 'package:lucky_parcel/features/home/screens/main_screen.dart';
import 'package:lucky_parcel/features/notifications/screens/notifications_screen.dart';

import '../../features/auth/screens/auth_screen.dart';

class AppRouter {
  static const String auth = '/auth';
  static const String main = '/main';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
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
