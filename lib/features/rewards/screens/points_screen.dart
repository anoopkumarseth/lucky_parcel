import 'package:flutter/material.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Points'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '1,250',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
              'points',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
