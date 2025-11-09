import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('You have no orders yet.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final vehicle = order['vehicle'] as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.local_shipping),
                  title: Text('Order to ${order['driverName']}'),
                  subtitle: Text(
                    'Vehicle: ${vehicle['name']}\n'
                    'Price: ₹${vehicle['price'].toStringAsFixed(2)}\n'
                    'Status: ${order['status']}',
                  ),
                  trailing: Text('OTP: ${order['otp']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
