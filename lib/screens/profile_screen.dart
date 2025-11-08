import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $userName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: ${user?.email ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
