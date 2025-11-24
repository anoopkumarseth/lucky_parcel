import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.local_shipping_outlined, color: Theme.of(context).primaryColor),
              title: const Text('New order received'),
              subtitle: const Text('From: Mumbai, To: Delhi'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.person_pin_circle_outlined, color: Theme.of(context).primaryColor),
              title: const Text('Driver assigned'),
              subtitle: const Text('Anoop Seth is on the way'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('Parcel delivered'),
              subtitle: const Text('Your parcel has been delivered to its destination'),
            ),
          ),
        ],
      ),
    );
  }
}
