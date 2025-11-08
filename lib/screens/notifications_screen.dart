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
        children: const [
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('New order received'),
            subtitle: Text('From: Mumbai, To: Delhi'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Driver assigned'),
            subtitle: Text('Anoop Seth is on the way'),
          ),
          ListTile(
            leading: Icon(Icons.delivery_dining),
            title: Text('Parcel delivered'),
            subtitle: Text('Your parcel has been delivered to its destination'),
          ),
        ],
      ),
    );
  }
}
